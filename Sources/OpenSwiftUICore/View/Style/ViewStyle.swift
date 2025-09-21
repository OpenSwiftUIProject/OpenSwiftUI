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

// MARK: - StyleModifier

package protocol StyleModifier: MultiViewModifier, PrimitiveViewModifier {
    associatedtype Style

    associatedtype StyleConfiguration

    associatedtype StyleBody: View

    init(style: Style)

    var style: Style { get set }

    func styleBody(configuration: StyleConfiguration) -> StyleBody
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
