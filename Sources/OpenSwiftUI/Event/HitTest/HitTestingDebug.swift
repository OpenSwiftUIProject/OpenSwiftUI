//
//  HitTestingDebug.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: DB5E6F06E13FF0259F656B4E03BE4F79 (SwiftUI)

import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - HitTestTracing

private protocol HitTestTracing {
    var propertiesAffectingHitTest: [(key: String?, value: String)] { get }
    func isEqual(to other: Self) -> Bool
}

// MARK: - HitTestTrace

private struct HitTestTrace<Value> where Value: HitTestTracing {
    let value: Value
    let name: String
    let identifier: String
    let point: CGPoint
    let result: Value?
    let children: [HitTestTrace<Value>]

    func map<Other: HitTestTracing>(_ transform: (Value) -> Other) -> HitTestTrace<Other> {
        HitTestTrace<Other>(
            value: transform(value),
            name: name,
            identifier: identifier,
            point: point,
            result: result.map(transform),
            children: children.map { $0.map(transform) }
        )
    }

    func recursiveDescription(annotating values: [Value], depth: Int = 0) -> String {
        let annotated = values.contains { value.isEqual(to: $0) }
        let prefix = String(repeating: annotated ? "├─" : "│ ", count: depth)
            + (annotated ? "▶" : result == nil ? "✕" : "✓")
        let properties = value.propertiesAffectingHitTest.map { key, value in
            key.map { "\($0): \(value)" } ?? value
        }
        let description = "\(name)(\(([identifier] + properties).joined(separator: ", ")))"
        return (["\(prefix) \(point) \(description)"] + children.map {
            $0.recursiveDescription(annotating: values, depth: depth + 1)
        }).joined(separator: "\n")
    }
}

// MARK: - ViewResponder + HitTestTracing

extension ViewResponder: HitTestTracing {
    fileprivate var propertiesAffectingHitTest: [(key: String?, value: String)] {
        var properties: [(key: String?, value: String)] = []
        if self is any AnyGestureContainingResponder, let container = gestureContainer {
            properties.append(contentsOf: [
                ("gestureRecognizerContainer", "\(type(of: container))(\(address(of: container)))")
            ])
        }
        if !(self is any AnyGestureResponder) {
            var string = ""
            extendPrintTree(string: &string)
            if !string.isEmpty {
                properties.append(contentsOf: [(nil, string)])
            }
        }
        return properties
    }

    fileprivate func isEqual(to other: ViewResponder) -> Bool {
        self === other
    }

    fileprivate func traceHitTest(
        point: CGPoint,
        radius: CGFloat,
        options: ContainsPointsOptions,
        result: ViewResponder?
    ) -> HitTestTrace<ViewResponder> {
        let name = String(describing: type(of: self))
        let identifier = "\(address(of: self))"
        let hit = hitTest(globalPoint: point, radius: radius, cacheKey: nil, options: options)
        let children = children.compactMap { child -> HitTestTrace<ViewResponder>? in
            let containment = child.containsGlobalPoints([point], cacheKey: nil, options: [])
            guard containment.mask != [] || result?.isDescendant(of: self) == true else {
                return nil
            }
            return child.traceHitTest(
                point: point,
                radius: radius,
                options: .platformDefault,
                result: result
            )
        }
        return HitTestTrace(
            value: self,
            name: name,
            identifier: identifier,
            point: point,
            result: hit,
            children: children
        )
    }
}

// MARK: - ResponderBasedHitTestTracing

private enum ResponderBasedHitTestTracing: HitTestTracing {
    case view(PlatformView)
    case responder(ViewResponder)

    var propertiesAffectingHitTest: [(key: String?, value: String)] {
        switch self {
        case let .view(view): view.propertiesAffectingHitTest
        case let .responder(responder): responder.propertiesAffectingHitTest
        }
    }

    func isEqual(to other: Self) -> Bool {
        switch (self, other) {
        case let (.view(lhs), .view(rhs)): lhs === rhs
        case let (.responder(lhs), .responder(rhs)): lhs === rhs
        default: false
        }
    }

    func traceHitTest(
        point: CGPoint,
        radius: CGFloat,
        options: ViewResponder.ContainsPointsOptions,
        result: Self?
    ) -> HitTestTrace<Self> {
        let trace: HitTestTrace<Self>
        switch self {
        case let .view(view):
            let viewResult: PlatformView? = if case let .view(value) = result {
                value
            } else {
                nil
            }
            trace = view.traceHitTest(point: point, radius: radius, result: viewResult).map(Self.view)
        case let .responder(responder):
            let responderResult: ViewResponder? = if case let .responder(value) = result {
                value
            } else {
                nil
            }
            trace = responder.traceHitTest(
                point: point, radius: radius, options: options, result: responderResult
            ).map(Self.responder)
        }
        let children: [HitTestTrace<Self>]? = {
            switch self {
            case let .view(view):
                if let leaf = view as? any HitTestingLeafPlatformView {
                    return Update.perform {
                        guard let responder = leaf.responderForHitTesting else {
                            return nil
                        }
                        // [AI] Both identity operands read the responder's host view.
                        if let viewResponder = responder as? PlatformViewResponder,
                           let hostView = viewResponder.hostView,
                           hostView === viewResponder.hostView
                        {
                            return nil
                        }
                        return [Self.responder(responder).traceHitTest(
                            point: view.convert(point, to: nil), radius: radius, options: options, result: result
                        )]
                    }
                }
            case let .responder(responder):
                if let viewResponder = responder as? PlatformViewResponder,
                   let hostView = viewResponder.hostView,
                   hostView.window != nil
                {
                    if !trace.children.isEmpty {
                        guard case let .view(resultView) = result else {
                            break
                        }
                        if let hitResponder = responder.hitTest(
                            globalPoint: point, radius: radius, cacheKey: nil, options: options
                        ) as? PlatformViewResponder,
                           hitResponder !== responder,
                           let hitView = hitResponder.hostView,
                           resultView.isDescendant(of: hitView)
                        {
                            break
                        }
                    }
                    return [Self.view(hostView).traceHitTest(
                        point: hostView.convert(point, from: nil), radius: radius, options: options, result: result
                    )]
                }
            }
            return nil
        }()
        return HitTestTrace(
            value: trace.value, name: trace.name, identifier: trace.identifier,
            point: trace.point, result: trace.result,
            children: children ?? trace.children.map {
                $0.value.traceHitTest(point: $0.point, radius: radius, options: options, result: result)
            }
        )
    }
}
