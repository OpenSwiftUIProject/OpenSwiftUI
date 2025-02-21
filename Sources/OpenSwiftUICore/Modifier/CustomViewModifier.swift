//
//  CustomViewModifier.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: 0EAFD5A78D9C0B607C3C0964CF3A3038 (SwiftUI)
//  ID: 2BA0A33A15B7F322F46AFB9D0D1A262D (SwiftUICore)

import OpenGraphShims

// MARK: - ViewModifier + Extension

extension ViewModifier {
    public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeView(modifier: modifier, inputs: inputs, body: body)
    }

    public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        makeViewList(modifier: modifier, inputs: inputs, body: body)
    }

    public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        viewListCount(inputs: inputs, body: body)
    }
}

extension ViewModifier {
    static func makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (view, buffer) = makeBody(modifier: modifier, inputs: &inputs.base, fields: fields)
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
        preconditionFailure("TODO")
    }
    
    static func viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        preconditionFailure("TODO")
    }
    
    private static func makeBody(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        let kind = Metadata(Self.self).kind
        switch kind {
        case .struct, .enum, .optional, .tuple:
            let accessor = ModifierBodyAccessor<Self>()
            return accessor.makeBody(container: modifier, inputs: &inputs, fields: fields)
        default:
            preconditionFailure("view modifiers must be value types:  \(Self.self)")
        }
    }
}

// MARK: - BodyInput [WIP]

// FIXME
private struct BodyInput<Input> {}

private enum BodyInputElement: GraphReusable, Equatable {
    typealias MakeViewBody = (_Graph, _ViewInputs) -> _ViewOutputs
    typealias MakeViewListBody = (_Graph, _ViewListInputs) -> _ViewListOutputs

    case view(MakeViewBody)
    case list(MakeViewListBody)

    static func == (lhs: BodyInputElement, rhs: BodyInputElement) -> Bool {
        if case let .view(lhsBody) = lhs, case let .view(rhsBody) = rhs {
            compareValues(lhsBody, rhsBody, options: .init(rawValue: 0x103))
        } else if case let .list(lhsBody) = lhs, case let .list(rhsBody) = rhs{
            compareValues(lhsBody, rhsBody, options: .init(rawValue: 0x103))
        } else {
            false
        }
    }

    static var isTriviallyReusable: Bool {
        _SemanticFeature_v5.isEnabled
    }

    func makeReusable(indirectMap: IndirectAttributeMap) {
        return
    }

    func tryToReuse(by other: BodyInputElement, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool {
        switch self {
            case let .view(makeViewBody):
                guard case let .view(otherMakeViewBody) = other else {
                    ReuseTrace.traceReuseInternalFailure()
                    return false
                }
                return Self.isTriviallyReusable || compareValues(makeViewBody, otherMakeViewBody, options: .init(rawValue: 0x103))
            case let .list(makeViewListBody):
                guard case let .list(otherMakeViewListBody) = other else {
                    ReuseTrace.traceReuseInternalFailure()
                    return false
                }
                return Self.isTriviallyReusable || compareValues(makeViewListBody, otherMakeViewListBody, options: .init(rawValue: 0x103))
        }
    }
}

// MARK: - BodyCountInput

private struct BodyCountInput<V>: ViewInput {
    static var defaultValue: Stack<(_ViewListCountInputs) -> Int?> { .init() }
}

// MARK: - ModifierBodyAccessor

private struct ModifierBodyAccessor<Container>: BodyAccessor where Container: ViewModifier {
    typealias Body = Container.Body

    func updateBody(of container: Container, changed: Bool) {
        guard changed else {
            return
        }
        setBody {
            container.body(content: Container.Content())
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
            preconditionFailure("TODO: \(String(describing: makeViewListBody))")
        }
    }

    public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        preconditionFailure("TODO")
    }

    public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        preconditionFailure("TODO")
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
