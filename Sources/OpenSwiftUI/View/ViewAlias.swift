//
//  ViewAlias.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: D9F7AF928092578A4B8FA861B49E2161 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

// MARK: - ViewAlias

/// A protocol for creating view aliases that can be used to reference source views indirectly.
///
/// ViewAlias allows the creation of placeholder views that will be replaced with actual
/// source views at render time. This enables more flexible view composition patterns
/// and reuse of view hierarchies across different parts of an application.
///
/// Conforming types must provide an empty initializer and will inherit the view
/// implementation from the source view when rendered.
protocol ViewAlias: PrimitiveView {
    init()
}

// MARK: - View + ViewAlias Extension

extension View {
    /// Defines a view alias that will be replaced with the provided source view.
    ///
    /// Use this method to associate a view alias with a source view. When the
    /// alias is used elsewhere in the view hierarchy, it will be replaced with
    /// the source view provided here.
    ///
    /// - Parameters:
    ///   - alias: The view alias type to associate with the source view.
    ///   - source: A closure that returns the source view to be used when rendering the alias.
    /// - Returns: A view that establishes the connection between the alias and source view.
    func viewAlias<Alias, Source>(
        _ alias: Alias.Type,
        _ source: () -> Source
    ) -> some View where Alias: ViewAlias, Source: View {
        modifier(StaticSourceWriter<Alias, Source>(source: source()))
    }

    /// Conditionally defines a view alias based on a predicate.
    ///
    /// Use this method to associate a view alias with a source view only when
    /// a specific condition is met based on the ViewInputPredicate.
    ///
    /// - Parameters:
    ///   - predicate: The predicate type used to determine if the alias should be applied.
    ///   - alias: The view alias type to associate with the source view.
    ///   - source: A closure that returns the source view to be used when rendering the alias.
    /// - Returns: A view that conditionally establishes the connection between the alias and source view.
    func viewAlias<Predicate, Alias, Source>(
        if predicate: Predicate.Type,
        _ alias: Alias.Type,
        _ source: () -> Source
    ) -> some View where Predicate: ViewInputPredicate, Alias: ViewAlias, Source: View {
        modifier(StaticSourceWriter<Alias, Source>(source: source()).requiring(predicate))
    }

    /// Defines an optional view alias that will be replaced with the provided source view when it exists.
    ///
    /// Use this method to associate a view alias with an optional source view. When the
    /// alias is used elsewhere in the view hierarchy, it will be replaced with the source
    /// view if it's non-nil, or not rendered if the source is nil.
    ///
    /// - Parameters:
    ///   - alias: The view alias type to associate with the optional source view.
    ///   - source: A closure that returns the optional source view to be used when rendering the alias.
    /// - Returns: A view that establishes the conditional connection between the alias and source view.
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

/// A property wrapper that provides conditional access to a view alias based on source availability.
///
/// `OptionalViewAlias` checks whether a source view has been defined for the specified
/// view alias type. If a source exists, the `wrappedValue` provides an instance of the
/// alias; otherwise, it returns `nil`.
///
/// This is useful for conditionally including views in a hierarchy when their source views
/// may or may not be defined.
@propertyWrapper
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

    /// Indicates whether a source view has been defined for this alias.
    var sourceExists: Bool = false

    /// Returns an instance of the alias if a source view exists, otherwise `nil`.
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
