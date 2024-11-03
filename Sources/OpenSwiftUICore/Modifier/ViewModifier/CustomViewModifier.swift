//
//  CustomViewModifier.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 0EAFD5A78D9C0B607C3C0964CF3A3038

import OpenGraphShims

// MARK: - ViewModifier + Extension

extension ViewModifier {
    static func makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (view, buffer) = inputs.withMutateGraphInputs { inputs in
            makeBody(modifier: modifier, inputs: &inputs, fields: fields)
        }
        inputs.append(.view(body), to: _ViewModifier_Content<Self>.BodyInput.self)
        let outputs = _ViewDebug.makeView(
            view: view,
            inputs: inputs
        ) { view, inputs in
            Body._makeView(view: view, inputs: inputs)
        }
        if let buffer {
            buffer.traceMountedProperties(to: view, fields: fields)
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

// MARK: - ModifierBodyAccessor

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

// MARK: - _ViewModifier_Content

public struct _ViewModifier_Content<Modifier: ViewModifier>: PrimitiveView {
    public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var inputs = inputs
        guard let body = inputs.popLast(BodyInput.self) else {
            return _ViewOutputs()
        }
        switch body {
        case let .view(makeViewBody):
            return makeViewBody(_Graph(), inputs)
        case let .list(makeViewListBody):
            fatalError("TODO: \(String(describing: makeViewListBody))")
        }
    }
    
    public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        fatalError("TODO")
    }
    
    public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        fatalError("TODO")
    }
}

extension _ViewModifier_Content {
    fileprivate struct BodyInput: ViewInput {
        static var defaultValue: [Body] {
            []
        }
        
        typealias MakeViewBody = (_Graph, _ViewInputs) -> _ViewOutputs
        typealias MakeViewListBody = (_Graph, _ViewListInputs) -> _ViewListOutputs
        
        enum Body: Equatable {
            case view(MakeViewBody)
            case list(MakeViewListBody)
            
            static func == (lhs: _ViewModifier_Content<Modifier>.BodyInput.Body, rhs: _ViewModifier_Content<Modifier>.BodyInput.Body) -> Bool {
                if case let .view(lhsBody) = lhs, case let .view(rhsBody) = rhs {
                    compareValues(lhsBody, rhsBody)
                } else if case let .list(lhsBody) = lhs, case let .list(rhsBody) = rhs{
                    compareValues(lhsBody, rhsBody)
                } else {
                    false
                }
            }
        }
    }
}
