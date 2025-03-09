//
//  CustomView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 9F92ACD17B554E8AB7D29ABB1E796415 (SwiftUI)
//  ID: CE1D93D8ECBBEB5FE2E32E69A123E7CB (SwiftUICore)

import OpenGraphShims

extension View {
    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        makeView(view: view, inputs: inputs)
    }
    
    nonisolated public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        makeViewList(view: view, inputs: inputs)
    }
    
    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        Body._viewListCount(inputs: inputs)
    }
    
    nonisolated package static func makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (body, buffer) = makeBody(view: view, inputs: &inputs.base, fields: fields)
        if let buffer {
            buffer.traceMountedProperties(to: body, fields: fields)
        }
        return Body.makeDebuggableView(view: body, inputs: inputs)
    }
    
    nonisolated package static func makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (body, buffer) = makeBody(view: view, inputs: &inputs.base, fields: fields)
        let outputs = Body.makeDebuggableViewList(view: body, inputs: inputs)
        if let buffer {
            buffer.traceMountedProperties(to: body, fields: fields)
        }
        return outputs
    }
    
    nonisolated private static func makeBody(
        view: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        let kind = Metadata(Self.self).kind
        switch kind {
        case .struct, .enum, .optional, .tuple:
            let accessor = ViewBodyAccessor<Self>()
            return accessor.makeBody(container: view, inputs: &inputs, fields: fields)
        default:
            preconditionFailure("views must be value types (either a struct or an enum); \(Self.self) is a class.")
        }
    }
}
