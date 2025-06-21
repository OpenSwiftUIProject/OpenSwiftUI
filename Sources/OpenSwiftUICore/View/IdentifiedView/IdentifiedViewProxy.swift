//
//  IdentifiedViewProxy.swift
//  OpenSwiftUICore
//
//  Status: Complete

public import Foundation
import OpenGraphShims

// MARK: - _IdentifiedViewProxy [6.4.41]

@available(OpenSwiftUI_v1_0, *)
public struct _IdentifiedViewProxy {
    public var identifier: AnyHashable
    package var size: CGSize
    package var position: CGPoint
    package var transform: ViewTransform
    package var adjustment: ((inout CGRect) -> ())?
    package var accessibilityNodeStorage: Any?
    package var platform: _IdentifiedViewProxy.Platform
    
    package init(identifier: AnyHashable, size: CGSize, position: CGPoint, transform: ViewTransform, accessibilityNode: Any?, platform: _IdentifiedViewProxy.Platform) {
        self.identifier = identifier
        self.size = size
        self.position = position
        self.transform = transform
        self.accessibilityNodeStorage = accessibilityNode
        self.platform = platform
    }
        
    public var boundingRect: CGRect {
        var rect = CGRect(origin: .zero, size: size)
        rect.convert(to: .global, transform: transform.withPosition(position))
        adjustment?(&rect)
        return rect
    }
}

@available(*, unavailable)
extension _IdentifiedViewProxy: Sendable {}

// MARK: - IdentifiedViewPlatformInputs [6.4.41]

package struct IdentifiedViewPlatformInputs {
    package init(inputs: _ViewInputs, outputs: _ViewOutputs) {}
}

extension _IdentifiedViewProxy {
    package struct Platform {
        package init(_ inputs: IdentifiedViewPlatformInputs) {}
    }
}

// MARK: - IdentifierProvider [6.4.41]

package protocol IdentifierProvider {
    func matchesIdentifier<I>(_ identifier: I) -> Bool where I: Hashable
}

extension _BenchmarkHost {
    public func viewForIdentifier<I, V>(
        _ identifier: I,
        _ type: V.Type
    ) -> V? where I: Hashable, V: View {
        guard let render = self as? ViewRendererHost else {
            return nil
        }
        return render.findIdentifier(identifier, root: nil) { attribute in
            var predicate = ViewValuePredicate<V>(view: nil)
            _ = attribute.breadthFirstSearch(options: ._2) { anyAttribute in
                predicate.apply(to: anyAttribute)
            }
            return predicate.view
        }
    }

    public func stateForIdentifier<I, S, V>(
        _ id: I,
        type stateType: S.Type,
        in viewType: V.Type
    ) -> Binding<S>? where I: Hashable, V: View {
        guard let render = self as? ViewRendererHost else {
            return nil
        }
        return render.stateForIdentifier(id, type: stateType, in: viewType)
    }
}

extension ViewRendererHost {
    func stateForIdentifier<I, S, V>(
        _ id: I,
        type stateType: S.Type,
        in viewType: V.Type
    ) -> Binding<S>? where I: Hashable, V: View {
        findIdentifier(id, root: nil) { attribute in
            var predicate = ViewStatePredicate<V, S>()
            _ = attribute.breadthFirstSearch(options: ._2) { anyAttribute in
                predicate.apply(to: anyAttribute)
            }
            return predicate.state
        }
    }

    func findIdentifier<I, V>(
        _ identifier: I,
        root: AnyAttribute?,
        filter: (AnyAttribute) -> V?
    ) -> V? where I: Hashable {
        let root = root ?? viewGraph.rootView
        var v: V? = nil
        _ = root.breadthFirstSearch(options: ._2) { attribute in
            func project(type: any Any.Type) -> Bool {
                // FIXME: type
                guard let provider = attribute._bodyPointer as? IdentifierProvider else {
                    return false
                }
                guard provider.matchesIdentifier(identifier),
                      let value = filter(attribute) else {
                    return false
                }
                v = value
                return true
            }
            return project(type: attribute._bodyType)
        }
        return v
    }
}
