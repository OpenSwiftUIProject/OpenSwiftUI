//
//  CustomViewModifier.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 0EAFD5A78D9C0B607C3C0964CF3A3038

internal import OpenGraphShims

extension ViewModifier {
    static func makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (body, buffer) = inputs.withMutateGraphInputs { inputs in
            makeBody(modifier: modifier, inputs: &inputs, fields: fields)
        }
        // inputs.append(<#T##value: Value##Value#>, to: <#T##ViewInput.Type#>)
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
    
    static func makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        fatalError("TODO")
    }
    
    static func viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        fatalError("TODO")
    }
    
    private static func makeBody(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        let kind = OGTypeID(Self.self).kind
        switch kind {
        case .struct, .enum, .optional, .tuple:
            let accessor = ModifierBodyAccessor<Self>()
            return accessor.makeBody(container: modifier, inputs: &inputs, fields: fields)
        default:
            fatalError("view modifiers must be value types:  \(Self.self)")
        }
    }
}

private struct ModifierBodyAccessor<Container: ViewModifier>: BodyAccessor {
    typealias Body = Container.Body
    
    func updateBody(of container: Container, changed: Bool) {
        guard changed else {
            return
        }
        setBody {
            container.body(content: _ViewModifier_Content())
        }
    }
}
