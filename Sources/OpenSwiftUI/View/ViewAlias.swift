//
//  ViewAlias.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: TODO
//  ID: D9F7AF928092578A4B8FA861B49E2161 (SwiftUI)

import OpenGraphShims
import OpenSwiftUICore

protocol ViewAlias: PrimitiveView {
    init()
}

extension View {
    func viewAlias<Alias: ViewAlias, Source: View>(
        _ alias: Alias.Type,
        _ source: () -> Source
    ) -> some View {
        modifier(StaticSourceWriter<Alias, Source>(source: source()))
    }

    func viewAlias<Alias: ViewAlias, Source: View>(
        _ alias: Alias.Type,
        _ source: () -> Source?
    ) -> some View {
        preconditionFailure("TODO")
//        modifier(OptionalSourceWriter<Alias, Source>(source: source()))
    }
}


//struct OptionalViewAlias<A> {
//    var sourceExists: Bool
//}
//
//private struct OptionalSourceWriter<Alias: ViewAlias, Source: View>: PrimitiveViewModifier, _GraphInputsModifier {
//    var source: Source?
//
//    static func _makeInputs(modifier: _GraphValue<OptionalSourceWriter<Alias, Source>>, inputs: inout _GraphInputs) {
//        preconditionFailure("TODO")
//    }
//}


private struct StaticSourceWriter<Alias: ViewAlias, Source: View>: PrimitiveViewModifier, _GraphInputsModifier {
    var source: Source

    static func _makeInputs(modifier: _GraphValue<StaticSourceWriter<Alias, Source>>, inputs: inout _GraphInputs) {
        preconditionFailure("TODO")
    }
}

//
//; struct SwiftUI.OptionalViewAlias.OptionalSourceBox<A> {
//                            ;     var _sourceIsNil: AttributeGraph.Attribute<Swift.Bool>
//                            ; }
//
//; struct SwiftUI.OptionalViewAlias..StaticSourceBox<A> {
//                             ;     var sourceExists: Swift.Bool
//                             ; }




private protocol AnySourceFormula {
    // 3 requirements
}

private struct SourceFormula<A>: AnySourceFormula {

}

// MARK: - AnySource [WIP]

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
//        // x0, x6 is what?
//        guard true,
//
//
//        if let result = indirectMap.map[identifier] {
//            if testOnly {
//                return true
//            } else {
//                result.source = other.identifier
//                return true
//            }
//        } else {
//            ReuseTrace.traceNeverMadeReusableFailure(<#T##valueType: (any Any.Type)?##(any Any.Type)?#>)
//            return false
//        }
        false
    }
}

// MARK: - SourceInput

private struct SourceInput<V>: ViewInput where V: ViewAlias {
    static var defaultValue: Stack<AnySource> { Stack() }
}
