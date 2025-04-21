//
//  ViewAlias.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: D9F7AF928092578A4B8FA861B49E2161 (SwiftUI)

import OpenGraphShims
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

// MARK: - ViewAlias

protocol ViewAlias: PrimitiveView {
    init()
}

// MARK: - View + ViewAlias Extension

extension View {
    func viewAlias<Alias, Source>(
        _ alias: Alias.Type,
        _ source: () -> Source
    ) -> some View where Alias: ViewAlias, Source: View {
        modifier(StaticSourceWriter<Alias, Source>(source: source()))
    }

    func viewAlias<Predicate, Alias, Source>(
        if predicate: Predicate.Type,
        _ alias: Alias.Type,
        _ source: () -> Source
    ) -> some View where Predicate: ViewInputPredicate, Alias: ViewAlias, Source: View {
        modifier(StaticSourceWriter<Alias, Source>(source: source()).requiring(predicate))
    }

    func optionalViewAlias<Alias, Source>(
        _ alias: Alias.Type,
        _ source: () -> Source?
    ) -> some View where Alias: ViewAlias, Source: View {
        modifier(OptionalSourceWriter<Alias, Source>(source: source()))
    }
}

// MARK: - AnySourceFormula

private protocol AnySourceFormula {
    static func makeView<Alias>(
        view: _GraphValue<Alias>,
        source: AnySource,
        inputs: _ViewInputs
    ) -> _ViewOutputs where Alias: ViewAlias

    static func makeViewList<Alias>(
        view: _GraphValue<Alias>,
        source: AnySource,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs where Alias: ViewAlias

    static func viewListCount(
        source: AnySource,
        inputs: _ViewListCountInputs
    ) -> Int?
}

// MARK: - OptionalViewAlias

struct OptionalViewAlias<Alias>: DynamicProperty where Alias: ViewAlias {
    static func _makeProperty<Value>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<Value>, fieldOffset: Int, inputs: inout _GraphInputs) {
        if let source = inputs[SourceInput<Alias>.self].top {
            if let valueIsNil = source.valueIsNil {
                let box = OptionalSourceBox(sourceIsNil: valueIsNil)
                buffer.append(box, fieldOffset: fieldOffset)
            } else {
                let box = StaticSourceBox(sourceExists: true)
                buffer.append(box, fieldOffset: fieldOffset)
            }
        } else {
            let box = StaticSourceBox(sourceExists: false)
            buffer.append(box, fieldOffset: fieldOffset)
        }
    }

    var sourceExists: Bool

    var wrappedValue: Alias? {
        sourceExists ? Alias() : nil
    }

    private struct OptionalSourceBox: DynamicPropertyBox {
        @Attribute var sourceIsNil: Bool

        func update(property: inout OptionalViewAlias, phase: ViewPhase) -> Bool {
            let (sourceIsNil, changed) = $sourceIsNil.changedValue()
            property.sourceExists = !sourceIsNil
            return changed
        }
    }

    private struct StaticSourceBox: DynamicPropertyBox {
        var sourceExists: Bool

        func update(property: inout OptionalViewAlias, phase: ViewPhase) -> Bool {
            property.sourceExists = sourceExists
            return false
        }
    }
}

// MARK: - OptionalSourceWriter

private struct OptionalSourceWriter<Alias, Source>: PrimitiveViewModifier, _GraphInputsModifier where Alias: ViewAlias, Source: View {
    var source: Source?

    static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        inputs.append(
            AnySource(modifier.value[offset: { .of(&$0.source) }]),
            to: SourceInput<Alias>.self
        )
    }
}

// MARK: - StaticSourceWriter

private struct StaticSourceWriter<Alias, Source>: PrimitiveViewModifier, _GraphInputsModifier where Alias: ViewAlias, Source: View {
    var source: Source

    static func _makeInputs(modifier: _GraphValue<Self>, inputs: inout _GraphInputs) {
        inputs.append(
            AnySource(modifier.value[offset: { .of(&$0.source) }]),
            to: SourceInput<Alias>.self
        )
    }
}

// MARK: - SourceFormula

private struct SourceFormula<Source>: AnySourceFormula where Source: View {
    static func makeView<Alias>(
        view: _GraphValue<Alias>,
        source: AnySource,
        inputs: _ViewInputs
    ) -> _ViewOutputs where Alias: ViewAlias {
        guard let attribute = source.value.attribute else {
            return .init()
        }
        return if source.valueIsNil == nil {
            Optional<Source>.makeDebuggableView(
                view: _GraphValue(Attribute(identifier: attribute)),
                inputs: inputs
            )
        } else {
            Source.makeDebuggableView(
                view: _GraphValue(Attribute(identifier: attribute)),
                inputs: inputs
            )
        }
    }

    static func makeViewList<Alias>(
        view: _GraphValue<Alias>,
        source: AnySource,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs where Alias: ViewAlias {
        guard let attribute = source.value.attribute else {
            return .emptyViewList(inputs: inputs)
        }
        return if source.valueIsNil == nil {
            Optional<Source>.makeDebuggableViewList(
                view: _GraphValue(Attribute(identifier: attribute)),
                inputs: inputs
            )
        } else {
            Source.makeDebuggableViewList(
                view: _GraphValue(Attribute(identifier: attribute)),
                inputs: inputs
            )
        }
    }

    static func viewListCount(
        source: AnySource,
        inputs: _ViewListCountInputs
    ) -> Int? {
        if source.valueIsNil == nil {
            Optional<Source>._viewListCount(inputs: inputs)
        } else {
            Source._viewListCount(inputs: inputs)
        }
    }
}

// MARK: - AnySource

private struct AnySource: GraphReusable {
    let formula: AnySourceFormula.Type
    var value: AnyWeakAttribute
    let valueIsNil: Attribute<Bool>?

    init<V>(_ view: Attribute<V>) where V: View {
        formula = SourceFormula<V>.self
        value = AnyWeakAttribute(view.identifier)
        valueIsNil = nil
    }

    init<V>(_ view: Attribute<V?>) where V: View {
        formula = SourceFormula<V?>.self
        value = AnyWeakAttribute(view.identifier)
        valueIsNil = Attribute(isNil(input: view))
    }

    struct isNil<Input>: Rule, AsyncAttribute {
        @Attribute
        var input: Input?

        var value: Bool { input == nil }
    }

    mutating func makeReusable(indirectMap: IndirectAttributeMap) {
        guard let attribute = value.attribute else {
            return
        }
        if let result = indirectMap.map[attribute] {
            value = AnyWeakAttribute(result)
        } else {
            let indirect = indirectMap.subgraph.apply {
                attribute.createIndirect()
            }
            indirectMap.map[attribute] = indirect
            value = AnyWeakAttribute(indirect)
        }
    }

    func tryToReuse(by other: AnySource, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool {
        guard formula == other.formula,
              let attribute = value.attribute,
              let result = indirectMap.map[attribute],
              let otherAttribute = other.value.attribute
        else {
            ReuseTrace.traceNeverMadeReusableFailure(AnySource.self)
            return false
        }
        if !testOnly {
            result.source = otherAttribute
        }
        return true
    }
}

// MARK: - SourceInput

private struct SourceInput<Alias>: ViewInput where Alias: ViewAlias {
    static var defaultValue: Stack<AnySource> { Stack() }
}
