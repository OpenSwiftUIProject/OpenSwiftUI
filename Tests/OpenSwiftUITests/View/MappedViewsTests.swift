//
//  MappedViewsTests.swift
//  OpenSwiftUITests

import Foundation
import OpenAttributeGraphShims
#if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
@_private(sourceFile: "MappedViews.swift")
#endif
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@MainActor
@Suite(.tags(.aigc))
struct MappedViewsTests {
    @Test(arguments: [0, 3, nil] as [Int?])
    func countPreservesContentCountAndRequestsDynamicTraits(_ count: Int?) {
        var inputs = _ViewListCountInputs(_ViewListInputs(.invalid))
        inputs.options.insert(.requiresSections)
        inputs[CountInput.self] = count
        #expect(MappedViews<CountView, EmptyView>._viewListCount(inputs: inputs) == count)
        #expect(!inputs.options.contains(.needsDynamicTraits))
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func mapsEachChildAndPreservesContent() {
        let ids = MutableBox<[ViewList.ID.Canonical]>([])
        let view = MappedViews(content: TupleView((Color.black, Color.white))) { element in
            ids.value.append(element.id.canonicalID)
            return element.content.opacity(element.id.index == 0 ? 0.5 : 1)
        }
        let displayList = DisplayListUtil.renderDisplayList(view)
        #expect(Set(ids.value).count == 2)
        #expect(DisplayListUtil.containsColor("#000000FF", in: displayList))
        #expect(DisplayListUtil.containsColor("#FFFFFFFF", in: displayList))
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func emptyContentDoesNotCallTransform() {
        let view = MappedViews(content: EmptyView()) { _ in
            Issue.record("Empty content must not call the mapping transform")
            return Color.black
        }
        let displayList = DisplayListUtil.renderDisplayList(view)
        #expect(!DisplayListUtil.containsAnyColor(displayList))
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func nestedMappingRestoresEachPlaceholderBody() {
        let inner = MappedViews(content: TupleView((Color.black, Color.white))) { element in
            element.content.padding(1)
        }
        let outer = MappedViews(content: inner) { element in
            element.content.padding(2)
        }
        let displayList = DisplayListUtil.renderDisplayList(outer)
        #expect(DisplayListUtil.containsColor("#000000FF", in: displayList))
        #expect(DisplayListUtil.containsColor("#FFFFFFFF", in: displayList))
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func placeholderWithoutMappingProducesNoContent() {
        let element = MappedViewElement(id: .init(), traits: .init())
        let displayList = DisplayListUtil.renderDisplayList(element.content)
        #expect(!DisplayListUtil.containsAnyColor(displayList))
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func transformTracksTraitChanges() {
        struct Content: View {
            var isWhite: Bool

            var body: some View {
                MappedViews(content: Color.black._trait(WhiteTrait.self, isWhite)) { element in
                    element.traits[WhiteTrait.self] ? Color.white : Color.black
                }
            }
        }

        Update.perform {
            let graph = ViewGraph(rootViewType: Content.self, requestedOutputs: [.layout, .displayList])
            graph.instantiateOutputs()
            graph.setProposedSize(CGSize(width: 20, height: 20))
            for (index, isWhite) in [false, true, false].enumerated() {
                graph.setRootView(Content(isWhite: isWhite))
                graph.updateOutputs(at: Time(seconds: Double(index)))
                let (list, _) = graph.displayList()
                let color = isWhite ? "#FFFFFFFF" : "#000000FF"
                #expect(DisplayListUtil.containsColor(color, in: list.description))
            }
        }
    }

    #if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
    @Test(.disabled(if: attributeGraphVendor == .oag))
    func skippedOutputsStillAdvanceElementIDs() {
        let graph = Graph()
        let subgraph = Subgraph(graph: graph)
        defer { subgraph.invalidate() }
        subgraph.apply {
            let view = Attribute(value: TestMap(content: EmptyView(), transform: ElementProbe.init))
            let cache = MutableBox<[ViewList.ID.Canonical: WeakAttribute<ElementProbe>]>([:])
            let elements = TestMap.MappedElements(
                base: TestElements(count: 3), baseInputs: .invalid, id: .init(implicitID: 42),
                list: WeakAttribute(), view: view, views: cache
            )
            var start = 1
            var calls = 0
            let result = elements.makeElements(from: &start, inputs: .invalidInputs(.invalid), indirectMap: nil) { inputs, makeElement in
                calls += 1
                return calls == 1 ? (nil, true) : (makeElement(inputs), false)
            }
            #expect(start == 0)
            #expect(calls == 2)
            #expect(result.0 != nil)
            #expect(!result.1)
            #expect(cache.value.count == 1)
            guard let mapped = cache.value.values.first?.attribute else {
                Issue.record("The mapped element must remain in the cache")
                return
            }
            #expect(mapped.value.element.id.index == 2)
            #expect(!mapped.value.element.traits[WhiteTrait.self])
        }
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func reuseOnlyReplacesTheRuleAfterSuccessfulValidation() {
        let graph = Graph()
        let subgraph = Subgraph(graph: graph)
        defer { subgraph.invalidate() }
        subgraph.apply {
            let inputs = _GraphInputs(
                time: Attribute(value: Time.zero), phase: Attribute(value: _GraphInputs.Phase(value: 0)),
                environment: Attribute(value: EnvironmentValues()), transaction: Attribute(value: Transaction())
            )
            let view = Attribute(value: TestMap(content: EmptyView(), transform: ElementProbe.init))
            let cache = MutableBox<[ViewList.ID.Canonical: WeakAttribute<ElementProbe>]>([:])
            let elements = TestMap.MappedElements(
                base: TestElements(count: 1), baseInputs: inputs, id: .init(implicitID: 42),
                list: WeakAttribute(), view: view, views: cache
            )
            let map = IndirectAttributeMap(subgraph: subgraph)
            var start = 0
            _ = elements.makeElements(from: &start, inputs: .invalidInputs(inputs), indirectMap: map) { inputs, makeElement in
                (makeElement(inputs), true)
            }
            guard let mapped = cache.value.values.first?.attribute else {
                Issue.record("The mapped element must remain in the cache")
                return
            }
            let other = TestMap.MappedElements(
                base: TestElements(count: 1), baseInputs: inputs, id: .init(implicitID: 99),
                list: WeakAttribute(), view: view, views: MutableBox([:])
            )
            #expect(!elements.tryToReuseElement(at: 0, by: TestElements(count: 1), at: 0, indirectMap: map, testOnly: false))
            #expect(!elements.tryToReuseElement(at: 1, by: other, at: 0, indirectMap: map, testOnly: false))
            #expect(!elements.tryToReuseElement(at: 0, by: other, at: 1, indirectMap: map, testOnly: false))
            #expect(!elements.tryToReuseElement(at: 0, by: other, at: 0, indirectMap: IndirectAttributeMap(subgraph: subgraph), testOnly: false))
            #expect(elements.tryToReuseElement(at: 0, by: other, at: 0, indirectMap: map, testOnly: true))
            #expect(mapped.value.element.id == ViewList.ID(implicitID: 42))
            #expect(elements.tryToReuseElement(at: 0, by: other, at: 0, indirectMap: map, testOnly: false))
            #expect(mapped.value.element.id == ViewList.ID(implicitID: 99))
        }
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func reuseRemovesExpiredCacheEntries() {
        let graph = Graph()
        let subgraph = Subgraph(graph: graph)
        defer { subgraph.invalidate() }
        subgraph.apply {
            let view = Attribute(value: TestMap(content: EmptyView(), transform: ElementProbe.init))
            let id = ViewList.ID(implicitID: 42)
            let cache = MutableBox<[ViewList.ID.Canonical: WeakAttribute<ElementProbe>]>([:])
            let child = Subgraph(graph: graph)
            child.apply {
                cache.value[id.canonicalID] = WeakAttribute(Attribute(value: ElementProbe(element: .init(id: id, traits: .init()))))
            }
            child.invalidate()
            let elements = TestMap.MappedElements(
                base: TestElements(count: 1), baseInputs: .invalid, id: id,
                list: WeakAttribute(), view: view, views: cache
            )
            let map = IndirectAttributeMap(subgraph: subgraph)
            #expect(!elements.tryToReuseElement(at: 0, by: elements, at: 0, indirectMap: map, testOnly: true))
            #expect(cache.value.isEmpty)
        }
    }

    private typealias TestMap = MappedViews<EmptyView, ElementProbe>

    private struct ElementProbe: UnaryView, PrimitiveView {
        var element: MappedViewElement

        nonisolated static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
            _ = view.value.value
            return _ViewOutputs()
        }
    }

    private struct TestElements: ViewList.Elements {
        var count: Int

        func makeElements(
            from start: inout Int,
            inputs: _ViewInputs,
            indirectMap: IndirectAttributeMap?,
            body: Body
        ) -> (_ViewOutputs?, Bool) {
            let remaining = max(count - start, 0)
            start = max(start - count, 0)
            for _ in 0..<remaining {
                let result = body(inputs) { _ in _ViewOutputs() }
                if !result.1 {
                    return result
                }
            }
            return (nil, true)
        }

        func tryToReuseElement(
            at index: Int,
            by other: any ViewList.Elements,
            at otherIndex: Int,
            indirectMap: IndirectAttributeMap,
            testOnly: Bool
        ) -> Bool {
            other is TestElements && index < count && otherIndex < other.count
        }

        func retain() -> Release? { nil }
    }
    #endif

    private struct CountInput: GraphInput {
        static var defaultValue: Int? { nil }
    }

    private struct CountView: PrimitiveView, MultiView {
        nonisolated static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
            .emptyViewList(inputs: inputs)
        }

        nonisolated static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
            #expect(inputs.options.contains(.needsDynamicTraits))
            #expect(inputs.options.contains(.requiresSections))
            return inputs[CountInput.self]
        }
    }

    private struct WhiteTrait: _ViewTraitKey {
        static var defaultValue: Bool { false }
    }
}
