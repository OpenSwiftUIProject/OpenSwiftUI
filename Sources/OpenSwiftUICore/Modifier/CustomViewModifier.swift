//
//  CustomViewModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: 0EAFD5A78D9C0B607C3C0964CF3A3038 (SwiftUI)
//  ID: 2BA0A33A15B7F322F46AFB9D0D1A262D (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - _ViewModifier_Content

@available(OpenSwiftUI_v1_0, *)
public struct _ViewModifier_Content<Modifier>: PrimitiveView where Modifier: ViewModifier {
    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        providerMakeView(view: view, inputs: inputs)
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        providerMakeViewList(view: view, inputs: inputs)
    }

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        nil
    }

    @available(OpenSwiftUI_v2_0, *)
    @_alwaysEmitIntoClient
    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        _viewListCount(inputs: inputs) { _ in nil }
    }
}

// MARK: - PlaceholderContentView

/// A placeholder used to construct an inline modifier, transition, or other
/// helper type.
///
/// You don't use this type directly. Instead OpenSwiftUI creates this type on
/// your behalf.
@available(OpenSwiftUI_v5_0, *)
public struct PlaceholderContentView<Value>: View {
    package init() {}

    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        providerMakeView(view: view, inputs: inputs)
    }

    nonisolated public static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        providerMakeViewList(view: view, inputs: inputs)
    }

    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        providerViewListCount(inputs: inputs)
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension PlaceholderContentView: Sendable {}

extension _ViewInputs {
    package mutating func pushModifierBody<Token>(_ type: Token.Type, body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs) {
        append(BodyInputElement.view(body), to: BodyInput<Token>.self)
    }
}
extension _ViewListInputs {
    package mutating func pushModifierBody<Token>(_ type: Token.Type, body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) {
        base.append(BodyInputElement.list(body), to: BodyInput<Token>.self)
    }
}

@available(*, unavailable)
extension _ViewModifier_Content: Sendable {}

// MARK: - ViewModifier + Extension

@available(OpenSwiftUI_v1_0, *)
extension ViewModifier {
    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeView(modifier: modifier, inputs: inputs, body: body)
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        makeViewList(modifier: modifier, inputs: inputs, body: body)
    }

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        viewListCount(inputs: inputs, body: body)
    }

    nonisolated package static func makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (view, buffer) = makeBody(modifier: modifier, inputs: &inputs.base, fields: fields)
        inputs.append(.view(body), to: BodyInput<Content>.self)
        let outputs = Body.makeDebuggableView(view: view, inputs: inputs)
        if let buffer {
            buffer.traceMountedProperties(to: modifier, fields: fields)
        }
        return outputs
    }
    
    nonisolated package static func makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (view, buffer) = makeBody(modifier: modifier, inputs: &inputs.base, fields: fields)
        inputs.base.append(.list(body), to: BodyInput<Content>.self)
        let outputs = Body.makeDebuggableViewList(view: view, inputs: inputs)
        if let buffer {
            buffer.traceMountedProperties(to: modifier, fields: fields)
        }
        return outputs
    }
    
    nonisolated package static func viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        withoutActuallyEscaping(body) { escapingBody in
            var inputs = inputs
            inputs.append(escapingBody, to: BodyCountInput<Self>.self)
            return Body._viewListCount(inputs: inputs)
        }
    }
    
    nonisolated private static func makeBody(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        precondition(
            Metadata(Self.self).isValueType,
            "view modifiers must be value types: \(Self.self)"
        )
        let accessor = ModifierBodyAccessor<Self>()
        return accessor.makeBody(container: modifier, inputs: &inputs, fields: fields)
    }
}

// MARK: - ViewModifierContentProvider

private protocol ViewModifierContentProvider: PrimitiveView {}

extension _ViewModifier_Content: ViewModifierContentProvider {}
extension PlaceholderContentView: ViewModifierContentProvider {}

extension ViewModifierContentProvider {
    nonisolated fileprivate static func providerMakeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let graphInputs = inputs.base
        var inputs = inputs
        guard let body = inputs.popLast(BodyInput<Self>.self) else {
            return _ViewOutputs()
        }
        switch body {
        case let .view(makeViewBody):
            return makeViewBody(_Graph(), inputs)
        case let .list(makeViewListBody):
            return .multiView(inputs: inputs) {
                makeViewListBody($0, .init($1.base, options: graphInputs.viewListOptions))
            }
        }
    }

    nonisolated fileprivate static func providerMakeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        guard let body = inputs.base.popLast(BodyInput<Self>.self) else {
            return .emptyViewList(inputs: inputs)
        }
        switch body {
        case let .view(makeViewBody):
            return .unaryViewList(
                viewType: Self.self,
                inputs: inputs
            ) {
                makeViewBody(_Graph(), $0)
            }
        case let .list(makeViewListBody):
            return makeViewListBody(_Graph(), inputs)
        }
    }

    nonisolated fileprivate static func providerViewListCount(
        inputs: _ViewListCountInputs
    ) -> Int? {
        var inputs = inputs
        guard let input = inputs.popLast(BodyCountInput<Self>.self) else {
            return 0
        }
        guard !inputs.customModifierTypes.contains(ObjectIdentifier(Self.self)) else {
            return nil
        }
        inputs.customModifierTypes.append(ObjectIdentifier(Self.self))
        return input(inputs)
    }
}

extension _GraphInputs {
    @inline(__always)
    var containsNonEmptyBodyStack: Bool {
        var set: Set<Metadata> = []
        let descriptor = Metadata(BodyInput<Void>.self).nominalDescriptor
        var isEmptyStack = true
        if let elements = customInputs.elements {
            return elements.forEach(
                filter: .init()
            ) { element, stop in
                let element = element.takeUnretainedValue()
                let type = Metadata(element.keyType)
                guard type.nominalDescriptor == descriptor else {
                    return
                }
                let _ = set.insert(type)
                let value = element.value(as: Stack<BodyInputElement>.self)
                isEmptyStack = value.isEmpty
                guard isEmptyStack else {
                    ReuseTrace.traceReusePreventedFailure(element.keyType)
                    Log.graphReuse("Input \(element.keyType) is preventing reuse")
                    stop = true
                    return
                }
            }
        }
        return !isEmptyStack
    }
}

// MARK: - BodyInput

private struct BodyInput<V>: ViewInput {
    static var defaultValue: Stack<BodyInputElement> { Stack() }
}

// MARK: - BodyInputElement

private enum BodyInputElement: GraphReusable, Equatable {
    typealias MakeViewBody = (_Graph, _ViewInputs) -> _ViewOutputs
    typealias MakeViewListBody = (_Graph, _ViewListInputs) -> _ViewListOutputs

    case view(MakeViewBody)
    case list(MakeViewListBody)

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
                return Self.isTriviallyReusable || compareValues(makeViewBody, otherMakeViewBody)
            case let .list(makeViewListBody):
                guard case let .list(otherMakeViewListBody) = other else {
                    ReuseTrace.traceReuseInternalFailure()
                    return false
                }
                return Self.isTriviallyReusable || compareValues(makeViewListBody, otherMakeViewListBody)
        }
    }

    static func == (lhs: BodyInputElement, rhs: BodyInputElement) -> Bool {
        if case let .view(lhsBody) = lhs, case let .view(rhsBody) = rhs {
            compareValues(lhsBody, rhsBody)
        } else if case let .list(lhsBody) = lhs, case let .list(rhsBody) = rhs{
            compareValues(lhsBody, rhsBody)
        } else {
            false
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
