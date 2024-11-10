//
//  CustomView.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: 9F92ACD17B554E8AB7D29ABB1E796415

import OpenGraphShims

extension View {
    static func makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (body, buffer) = inputs.withMutateGraphInputs { inputs in
            makeBody(view: view, inputs: &inputs, fields: fields)
        }
        // FIXME
        let outputs = _ViewDebug.makeView(
            view: body,
            inputs: inputs
        ) { view, inputs in
            Body._makeView(view: body, inputs: inputs)
        }
        if let buffer {
            buffer.traceMountedProperties(to: body, fields: fields)
        }
        return outputs
    }
    
    static func makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (body, buffer) = inputs.withMutateGraphInputs { inputs in
            makeBody(view: view, inputs: &inputs, fields: fields)
        }
        let outputs = Body.makeDebuggableViewList(view: body, inputs: inputs)
        if let buffer {
            buffer.traceMountedProperties(to: body, fields: fields)
        }
        return outputs
    }
    
    private static func makeBody(
        view: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        let kind = OGTypeID(Self.self).kind
        switch kind {
        case .struct, .enum, .optional, .tuple:
            let accessor = ViewBodyAccessor<Self>()
            return accessor.makeBody(container: view, inputs: &inputs, fields: fields)
        default:
            fatalError("views must be value types (either a struct or an enum); \(Self.self) is a class.")
        }
    }
}
