//
//  AnyView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: A96961F3546506F21D8995C6092F15B5 (SwiftUI)
//  ID: 7578D05D331D7F1A2E0C2F8DEF38AAD4 (SwiftUICore)

package import OpenGraphShims
import OpenSwiftUI_SPI

// MARK: - AnyView

/// A type-erased view.
///
/// An `AnyView` allows changing the type of view used in a given view
/// hierarchy. Whenever the type of view used with an `AnyView` changes, the old
/// hierarchy is destroyed and a new hierarchy is created for the new type.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct AnyView: View, PrimitiveView {
    var storage: AnyViewStorageBase

    /// Create an instance that type-erases `view`.
    public init<V>(_ view: V) where V: View {
        if let anyView = view as? AnyView {
            storage = anyView.storage
        } else {
            storage = AnyViewStorage(view: view)
        }
    }

    @_alwaysEmitIntoClient
    public init<V>(erasing view: V) where V : View {
        self.init(view)
    }

    public init?(_fromValue value: Any) {
        struct Visitor: ViewTypeVisitor {
            var value: Any
            var view: AnyView?

            mutating func visit<V: View>(type: V.Type) {
                view = AnyView(value as! V)
            }
        }
        guard let conformace = ViewDescriptor.conformance(of: type(of: value)) else {
            return nil
        }
        var visitor = Visitor(value: value)
        visitor.visit(type: unsafeBitCast(conformace, to: (any View.Type).self))
        self = visitor.view!
    }

    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        makeDynamicView(metadata: (), view: view, inputs: inputs)
    }

    nonisolated public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        makeDynamicViewList(metadata: (), view: view, inputs: inputs)
    }

    package func visitContent<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        storage.visitContent(&visitor)
    }
}

@available(*, unavailable)
extension AnyView: Sendable {}

// MARK: - AnyView: DynamicView

extension AnyView: DynamicView {
    package static var canTransition: Bool { false }

    package func childInfo(metadata: Void) -> (any Any.Type, UniqueID?) {
        (storage.childType, nil)
    }

    package func makeChildView(metadata: (), view: Attribute<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        storage.makeChildView(view: view, inputs: inputs)
    }

    package func makeChildViewList(metadata: (), view: Attribute<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        storage.makeChildViewList(view: view, inputs: inputs)
    }
}

// MARK: - AnyViewStorageBase

@usableFromInline
class AnyViewStorageBase {
    fileprivate var childType: any Any.Type {
        _openSwiftUIBaseClassAbstractMethod()
    }

    fileprivate func makeChildView(view: Attribute<AnyView>, inputs: _ViewInputs) -> _ViewOutputs {
        _openSwiftUIBaseClassAbstractMethod()
    }

    fileprivate func makeChildViewList(view: Attribute<AnyView>, inputs: _ViewListInputs) -> _ViewListOutputs {
        _openSwiftUIBaseClassAbstractMethod()
    }

    fileprivate func visitContent<Visitor>(_ visitor: inout Visitor) where Visitor: ViewVisitor {
        _openSwiftUIBaseClassAbstractMethod()
    }

    fileprivate var content: any View {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@available(*, unavailable)
extension AnyViewStorageBase: Sendable {}

// MARK: - AnyViewStorage

private final class AnyViewStorage<V>: AnyViewStorageBase where V: View {
    let view: V

    init(view: V) {
        self.view = view
        super.init()
    }

    override var childType: Any.Type {
        V.self
    }

    override func makeChildView(view: Attribute<AnyView>, inputs: _ViewInputs) -> _ViewOutputs {
        var inputs = inputs
        inputs.base.pushStableType(V.self)
        let childView = Attribute(AnyViewChild<V>(view: view))
        childView.value = self.view
        return V.makeDebuggableView(view: _GraphValue(childView), inputs: inputs)
    }

    override func makeChildViewList(view: Attribute<AnyView>, inputs: _ViewListInputs) -> _ViewListOutputs {
        var inputs = inputs
        inputs.base.pushStableType(V.self)
        let childView = Attribute(AnyViewChild<V>(view: view))
        childView.value = self.view
        return V.makeDebuggableViewList(view: _GraphValue(childView), inputs: inputs)
    }

    override func visitContent<Visitor>(_ visitor: inout Visitor) where Visitor: ViewVisitor {
        visitor.visit(view)
    }

    override var content: any View {
        view
    }
}

// MARK: - AnyViewChild

fileprivate struct AnyViewChild<V>: StatefulRule, AsyncAttribute, CustomStringConvertible where V: View {
    @Attribute var view: AnyView

    typealias Value = V

    func updateValue() {
        guard let storage = view.storage as? AnyViewStorage<V> else {
            return
        }
        value = storage.view
    }

    var description: String {
        "\(V.self)"
    }
}
