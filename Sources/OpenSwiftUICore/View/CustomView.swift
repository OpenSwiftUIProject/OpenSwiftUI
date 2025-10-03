//
//  CustomView.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: 9F92ACD17B554E8AB7D29ABB1E796415 (SwiftUI)
//  ID: CE1D93D8ECBBEB5FE2E32E69A123E7CB (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - View default implmementation [6.0.87]

@available(OpenSwiftUI_v1_0, *)
extension View {
    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        makeView(view: view, inputs: inputs)
    }
    
    nonisolated public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        makeViewList(view: view, inputs: inputs)
    }
    
    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        Body._viewListCount(inputs: inputs)
    }
    
    nonisolated package static func makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (body, buffer) = makeBody(view: view, inputs: &inputs.base, fields: fields)
        if let buffer {
            buffer.traceMountedProperties(to: view, fields: fields)
        }
        let outputs = Body.makeDebuggableView(view: body, inputs: inputs)
        return outputs
    }
    
    nonisolated package static func makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (body, buffer) = makeBody(view: view, inputs: &inputs.base, fields: fields)
        let outputs = Body.makeDebuggableViewList(view: body, inputs: inputs)
        if let buffer {
            buffer.traceMountedProperties(to: view, fields: fields)
        }
        return outputs
    }
    
    nonisolated private static func makeBody(
        view: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        guard Metadata(Self.self).isValueType else {
            preconditionFailure("views must be value types (either a struct or an enum); \(Self.self) is a class.")
        }
        let accessor = ViewBodyAccessor<Self>()
        return accessor.makeBody(container: view, inputs: &inputs, fields: fields)
    }
}

// MARK: - ViewBodyAccessor [6.0.87]

package struct ViewBodyAccessor<V>: BodyAccessor where V: View {
    package init() {}

    package func updateBody(of container: Container, changed: Bool) {
        guard changed else {
            return
        }
        setBody {
            container.body
        }
    }

    package typealias Body = V.Body

    package typealias Container = V
}

// MARK: - ViewBodyAccessor [6.4.41]

package struct ViewValuePredicate<V> where V: View {
    package var view: V?

    package init(view: V?) {
        self.view = view
    }

    package mutating func apply(to ident: AnyAttribute) -> Bool {
        if let rule = ident._bodyType as? BodyAccessorRule.Type {
            view = rule.value(as: V.self, attribute: ident)
        }
        return view != nil
    }
}

// MARK: - ViewBodyAccessor [6.4.41]

package struct ViewStatePredicate<V, S> where V: View {
    package var state: Binding<S>?

    package init() {}

    package mutating func apply(to ident: AnyAttribute) -> Bool {
        if let rule = ident._bodyType as? BodyAccessorRule.Type,
           let buffer = rule.buffer(as: V.self, attribute: ident) {
            state = buffer.getState(type: S.self)
        }
        return state != nil
    }
}
