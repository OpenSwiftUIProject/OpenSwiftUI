//
//  ViewStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: AC03956538119E2820390436C305EBF1 (SwiftUI)
//  ID: AC59074524C298808AAD87A4737AEFFC (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - StyleableView

package protocol StyleableView: View where Configuration == DefaultStyleModifier.StyleConfiguration {
    associatedtype Configuration

    associatedtype DefaultStyleModifier: StyleModifier

    var configuration: Configuration { get }

    static var defaultStyleModifier: DefaultStyleModifier { get }
}

extension StyleableView {
    package var body: some View { self }

    nonisolated package static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var inputs = inputs
        guard inputs.base.isCurrentStyleableView(Self.self) else {
            inputs.base.setCurrentStyleableView(Self.self)
            return Body._makeView(
                view: _GraphValue(MakeResolvedRepresentation(view: view.value)),
                inputs: inputs
            )
        }
        guard let modifier = inputs.base.popLast(StyleInput<Configuration>.self) else {
            return MakeDefaultRepresentation<Self>.Value.makeDebuggableView(
                view: _GraphValue(MakeDefaultRepresentation(view: view.value)),
                inputs: inputs
            )
        }
        return (modifier._type as! AnyStyleModifierType.Type).makeView(
            view: view,
            modifier: modifier,
            inputs: inputs
        )
    }
    
    nonisolated package static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        guard inputs.base.isCurrentStyleableView(Self.self) else {
            inputs.base.setCurrentStyleableView(Self.self)
            return Body._makeViewList(
                view: _GraphValue(MakeResolvedRepresentation(view: view.value)),
                inputs: inputs
            )
        }
        guard let modifier = inputs.base.popLast(StyleInput<Configuration>.self) else {
            return MakeDefaultRepresentation<Self>.Value.makeDebuggableViewList(
                view: _GraphValue(MakeDefaultRepresentation(view: view.value)),
                inputs: inputs
            )
        }
        return (modifier._type as! AnyStyleModifierType.Type).makeViewList(
            view: view,
            modifier: modifier,
            inputs: inputs
        )
    }
    
    nonisolated package static func _viewListCount(
        inputs: _ViewListCountInputs
    ) -> Int? {
        var inputs = inputs
        guard inputs.isCurrentStyleableView(Self.self) else {
            inputs.setCurrentStyleableView(Self.self)
            return Body._viewListCount(inputs: inputs)
        }
        guard let modifier = inputs.popLast(StyleInput<Configuration>.self) else {
            return MakeDefaultRepresentation<Self>.Value._viewListCount(inputs: inputs)
        }
        return (modifier._type as! AnyStyleModifierType.Type).viewListCount(inputs: inputs)
    }
}

// MARK: - StyleModifier

package protocol StyleModifier: MultiViewModifier, PrimitiveViewModifier {
    associatedtype Style

    associatedtype StyleConfiguration

    associatedtype StyleBody: View

    init(style: Style)

    var style: Style { get set }

    func styleBody(configuration: StyleConfiguration) -> StyleBody
}

extension StyleModifier {
    nonisolated package static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        let override = inputs[StyleOverrideInput<Style>.self]
        inputs.append(
            override ?? AnyStyleModifier(
                value: modifier.value.identifier,
                _type: StyleModifierType<Self>.self
            ),
            to: StyleInput<StyleConfiguration>.self
        )
        return body(_Graph(), inputs)
    }
    
    nonisolated package static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        let override = inputs[StyleOverrideInput<Style>.self]
        inputs.base.append(
            override ?? AnyStyleModifier(
                value: modifier.value.identifier,
                _type: StyleModifierType<Self>.self
            ),
            to: StyleInput<StyleConfiguration>.self
        )
        return body(_Graph(), inputs)
    }
    
    nonisolated package static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        var inputs = inputs
        inputs.append(
            AnyStyleModifier(
                value: .nil,
                _type: StyleModifierType<Self>.self
            ),
            to: StyleInput<StyleConfiguration>.self
        )
        return body(inputs)
    }
}

// MARK: - AnyStyleModifierType

private protocol AnyStyleModifierType {
    static func makeView<V>(
        view: _GraphValue<V>,
        modifier: AnyStyleModifier,
        inputs: _ViewInputs
    ) -> _ViewOutputs where V: StyleableView

    static func makeViewList<V>(
        view: _GraphValue<V>,
        modifier: AnyStyleModifier,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs where V: StyleableView

    static func viewListCount(inputs: _ViewListCountInputs) -> Int?
}

// MARK: - AutomaticStyleOverrideModifier

struct AutomaticStyleOverrideModifier<I, M>: PrimitiveViewModifier, _GraphInputsModifier where M: StyleModifier {
    var styleModifier: M

    init(_: I.Type, modifier: M) {
        self.styleModifier = modifier
    }

    static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        inputs[StyleOverrideInput<I>.self] = AnyStyleModifier(
            value: modifier[offset: { .of(&$0.styleModifier) }].value.identifier,
            _type: StyleModifierType<M>.self
        )
    }
}

// MARK: - StyleOverrideInput

private struct StyleOverrideInput<I>: ViewInput {
    static var defaultValue: AnyStyleModifier? {
        nil
    }
}

// MARK: - MakeDefaultRepresentation

private struct MakeDefaultRepresentation<V>: Rule where V: StyleableView {
    @Attribute var view: V

    typealias Value = ModifiedContent<V, V.DefaultStyleModifier>

    var value: Value {
        view.modifier(V.defaultStyleModifier)
    }
}

// MARK: - AnyStyleModifier

struct AnyStyleModifier {
    var value: AnyAttribute
    let _type: Any.Type


}

// MARK: - StyleInput

private struct StyleInput<I>: ViewInput {
    static var defaultValue: Stack<AnyStyleModifier> {
        .init()
    }
}

// MARK: - MakeResolvedRepresentation

private struct MakeResolvedRepresentation<V>: Rule where V: StyleableView {
    @Attribute var view: V

    var value: V.Body {
        view.body
    }
}

// MARK: - StyleModifierType

private struct StyleModifierType<M>: AnyStyleModifierType where M: StyleModifier {
    static func makeView<V>(
        view: _GraphValue<V>,
        modifier: AnyStyleModifier,
        inputs: _ViewInputs
    ) -> _ViewOutputs where V: StyleableView {
        var inputs = inputs
        let fields = DynamicPropertyCache.fields(of: M.Style.self)
        let (styleBody, buffer) = makeStyleBody(
            view: view,
            modifier: modifier,
            inputs: &inputs.base,
            fields: fields
        )
        let outputs = M.StyleBody.makeDebuggableView(
            view: styleBody,
            inputs: inputs
        )
        if let buffer {
            buffer.traceMountedProperties(
                to: view,
                fields: fields
            )
        }
        return outputs
    }

    static func makeStyleBody<V>(
        view: _GraphValue<V>,
        modifier: AnyStyleModifier,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<M.StyleBody>, _DynamicPropertyBuffer?) where V: StyleableView {
        if Semantics.ViewStylesMustBeValueTypes.isEnabled {
            guard Metadata(M.Style.self).isValueType else {
                preconditionFailure("styles must be value types (either a struct or an enum); \(M.Style.self) is a class.")
            }
        }
        let styleModifier = modifier.value.unsafeCast(to: M.self)
        let accessor = StyleBodyAccessor<V, M>(
            view: view.value,
            styleModifier: styleModifier
        )
        return accessor
            .makeBody(
                container: .init(styleModifier[offset: { .of(&$0.style) }]),
                inputs: &inputs,
                fields: fields
            )
    }

    static func makeViewList<V>(
        view: _GraphValue<V>,
        modifier: AnyStyleModifier,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs where V: StyleableView {
        var inputs = inputs
        let fields = DynamicPropertyCache.fields(of: M.Style.self)
        let (styleBody, buffer) = makeStyleBody(
            view: view,
            modifier: modifier,
            inputs: &inputs.base,
            fields: fields
        )
        let outputs = M.StyleBody.makeDebuggableViewList(
            view: styleBody,
            inputs: inputs
        )
        if let buffer {
            buffer.traceMountedProperties(
                to: view,
                fields: fields
            )
        }
        return outputs
    }

    static func viewListCount(inputs: _ViewListCountInputs) -> Int? {
        M.StyleBody._viewListCount(inputs: inputs)
    }
}

// MARK: - StyleableViewContextInput

private struct StyleableViewContextInput: ViewInput {
    static var defaultValue: Any.Type? { nil }
}

extension _GraphInputs {
    fileprivate func isCurrentStyleableView<V>(_: V.Type) -> Bool where V: StyleableView {
        self[StyleableViewContextInput.self] == V.self
    }

    fileprivate mutating func setCurrentStyleableView<V>(_: V.Type) where V: StyleableView {
        self[StyleableViewContextInput.self] = V.self
    }

    package mutating func resetCurrentStyleableView() {
        self[StyleableViewContextInput.self] = nil
    }
}

extension _ViewListCountInputs {
    fileprivate func isCurrentStyleableView<V>(_: V.Type) -> Bool where V: StyleableView {
        self[StyleableViewContextInput.self] == V.self
    }

    fileprivate mutating func setCurrentStyleableView<V>(_: V.Type) where V: StyleableView {
        self[StyleableViewContextInput.self] = V.self
    }

    package mutating func resetCurrentStyleableView() {
        self[StyleableViewContextInput.self] = nil
    }
}

// MARK: - StyleBodyAccessor

private struct StyleBodyAccessor<V, M>: BodyAccessor where V: StyleableView, M: StyleModifier {
    @Attribute var view: V
    @Attribute var styleModifier: M

    typealias Container = M.Style

    typealias Body = M.StyleBody

    func updateBody(of container: Container, changed: Bool) {
        let (view, viewChanged) = $view.changedValue()
        guard changed || viewChanged else {
            return
        }
        setBody {
            styleModifier.styleBody(configuration: view.configuration as! M.StyleConfiguration)
        }
    }
}
