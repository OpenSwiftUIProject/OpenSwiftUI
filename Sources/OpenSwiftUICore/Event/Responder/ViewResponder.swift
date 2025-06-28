//
//  ViewResponder.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: 5DC9CCF050AF89FBA971AEC7E32C63B6 (SwiftUICore)

public import Foundation
import OpenGraphShims

// MARK: - ViewRespondersKey [6.5.4]

package struct ViewRespondersKey: PreferenceKey {
    package static var defaultValue: [ViewResponder] { [] }
    
    package static var _includesRemovedValues: Bool { true }
    
    package static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

extension PreferencesInputs {
    @inline(__always)
    var requiresViewResponders: Bool {
        get { contains(ViewRespondersKey.self) }
        set {
            if newValue {
                add(ViewRespondersKey.self)
            } else {
                remove(ViewRespondersKey.self)
            }
        }
    }
}

extension PreferencesOutputs {
    @inline(__always)
    var viewResponders: Attribute<[ViewResponder]>? {
        get { self[ViewRespondersKey.self] }
        set { self[ViewRespondersKey.self] = newValue }
    }
}

// MARK: - ViewResponder [6.5.4] [WIP]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
open class ViewResponder: ResponderNode, CustomStringConvertible/*, CustomRecursiveStringConvertible*/ {
    final private(set) package weak var host: ViewGraphDelegate? = nil

    final package weak var parent: ViewResponder? = nil {
        willSet {
            guard let parent, newValue == nil else {
                return
            }
            guard let host, let eventGraphHost = host.as(EventGraphHost.self) else {
                return
            }
            eventGraphHost.eventBindingManager.willRemoveResponder(self)
            resetGesture()
        }
    }

    override public init() {
        host = ViewGraph.current.delegate
    }

    override final public var nextResponder: ResponderNode? { parent }

    open var gestureContainer: AnyObject? { nil }

    open var opacity: Double { 1.0 }

    open var allowHitTesting: Bool { true }

    package struct ContainsPointsCache {
        var storage: (key: UInt32?, value: ContainsPointsResult)?

        package init() {
            storage = nil
        }

        package mutating func fetch(
            key: UInt32?,
            _ body: () -> ContainsPointsResult
        ) -> ContainsPointsResult {
            guard let storage, let storageKey = storage.key, let key, storageKey == key else {
                let result = body()
                storage = (key, result)
                return result
            }
            return storage.value
        }
    }

    package static let gestureContainmentPriority: Double = 16.0

    public struct ContainsPointsOptions: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        package static let allowDisabledViews: ContainsPointsOptions = .init(rawValue: 1 << 0)

        package static let useZDistanceAsPriority: ContainsPointsOptions = .init(rawValue: 1 << 1)

        package static let disablePointCloudHitTesting: ContainsPointsOptions = .init(rawValue: 1 << 2)

        package static let allow3DResponders: ContainsPointsOptions = .init(rawValue: 1 << 3)

        package static let crossingServerIDBoundary: ContainsPointsOptions = .init(rawValue: 1 << 4)

        public static var platformDefault: ViewResponder.ContainsPointsOptions { [] }
    }

    public struct ContainsPointsResult {
        package var mask: BitVector64
        package var priority: Double
        package var children: [ViewResponder]
    }

    open func containsGlobalPoints(
        _ points: [PlatformPoint],
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> ContainsPointsResult {
        ContainsPointsResult(mask: .init(), priority: 0, children: children)
    }

    open func addContentPath(
        to path: inout Path,
        kind: ContentShapeKinds,
        in space: CoordinateSpace,
        observer: (any ContentPathObserver)?
    ) {}

    open func addObserver(_ observer: any ContentPathObserver) {}

    open var children: [ViewResponder] { [] }

    open var descriptionName: String {
        // recursiveDescriptionName(Self.self)
        preconditionFailure("TODO")
    }

    public var description: String {
        "node(\(self) \(descriptionName))"
    }

    @inline(never)
    final package func printTree(depth: Int = 0) {
        // Log.eventDebug
        preconditionFailure("TODO")
    }

    open func extendPrintTree(string: inout String) {}
}

private func indentString(_ depth: Int) -> String {
    var result = ""
    var depth = depth
    while depth > 0 {
        result.append("| ")
        depth -= 1
    }
    return result
}

extension ViewGraph {
    package static var eventGraphHost: (any EventGraphHost)? {
        ViewGraph.current.delegate?.as(EventGraphHost.self)
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension ViewResponder: Sendable {}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension ViewResponder.ContainsPointsOptions: Sendable {}

// FIXME
package struct HitTestBindingModifier: ViewModifier, /*MultiViewModifier,*/ PrimitiveViewModifier {
    nonisolated package static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        // preconditionFailure("TODO")
        return body(_Graph(), inputs)
    }
    
    package typealias Body = Never
}
