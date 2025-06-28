//
//  ViewResponder.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: 5DC9CCF050AF89FBA971AEC7E32C63B6 (SwiftUICore)

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

    // TODO

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
