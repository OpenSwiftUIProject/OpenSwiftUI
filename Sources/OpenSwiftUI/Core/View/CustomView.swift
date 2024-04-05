//
//  CustomView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 9F92ACD17B554E8AB7D29ABB1E796415

internal import OpenGraphShims

extension View {
    static func makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        var inputs = inputs
        inputs.base.changedDebugProperties = []
        let fields = DynamicPropertyCache.fields(of: Self.self)
        let (body, buffer) = makeBody(view: view, inputs: &inputs.base, fields: fields)
        OGSubgraph.beginTreeElement(value: body.value, flags: 0)
        var outputs = Body._makeView(view: body, inputs: inputs)
        if OGSubgraph.shouldRecordTree {
            _ViewDebug.reallyWrap(&outputs, value: body, inputs: &inputs) // FIXME
            OGSubgraph.endTreeElement(value: body.value)
        }
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
