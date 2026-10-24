//
//  MappedViews.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: FB223812A59250D03E6B10B06AEB9F73 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

// MARK: - MappedViewElement

struct MappedViewElement {
    var id: ViewList.ID
    var traits: ViewTraitCollection

    var content: some View {
        Placeholder()
    }

    private struct Placeholder: UnaryView, PrimitiveView {
        nonisolated static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
            var inputs = inputs
            guard let body = inputs.popLast(BodyInput.self) else {
                return _ViewOutputs()
            }
            return body(inputs)
        }
    }

    fileprivate struct BodyInput: ViewInput {
        static let defaultValue: Stack<(_ViewInputs) -> _ViewOutputs> = .init()
    }
}

// MARK: - MappedViews

struct MappedViews<Content, MappedContent>: MultiView, PrimitiveView where Content: View, MappedContent: View {
    var content: Content
    var transform: (MappedViewElement) -> MappedContent

    nonisolated static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        var contentInputs = inputs
        contentInputs.options.insert(.needsDynamicTraits)
        let content = view[offset: { .of(&$0.content) }]
        var outputs = Content.makeDebuggableViewList(view: content, inputs: contentInputs)
        let list = outputs.makeAttribute(inputs: contentInputs)
        let mappedList = Attribute(MappedList.Init(list: list, view: view.value, baseInputs: inputs.base))
        outputs.views = .dynamicList(mappedList, nil)
        return outputs
    }

    nonisolated static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        var inputs = inputs
        inputs.options.insert(.needsDynamicTraits)
        return Content._viewListCount(inputs: inputs)
    }
}

// MARK: - MappedViews.MappedList

extension MappedViews {
    private struct MappedList: ViewList {
        var base: any ViewList
        var baseInputs: _GraphInputs
        @Attribute var view: MappedViews
        var views: MutableBox<[ViewList.ID.Canonical: WeakAttribute<MappedContent>]>

        init(
            base: any ViewList,
            baseInputs: _GraphInputs,
            view: Attribute<MappedViews>,
            views: MutableBox<[ViewList.ID.Canonical: WeakAttribute<MappedContent>]>
        ) {
            self.base = base
            self.baseInputs = baseInputs
            self._view = view
            self.views = views
        }

        struct Init: Rule, AsyncAttribute {
            @Attribute var list: any ViewList
            @Attribute var view: MappedViews
            var baseInputs: _GraphInputs
            var views: MutableBox<[ViewList.ID.Canonical: WeakAttribute<MappedContent>]>

            init(
                list: Attribute<any ViewList>,
                view: Attribute<MappedViews>,
                baseInputs: _GraphInputs,
                views: MutableBox<[ViewList.ID.Canonical: WeakAttribute<MappedContent>]> = MutableBox([:])
            ) {
                self._list = list
                self._view = view
                self.baseInputs = baseInputs
                self.views = views
            }

            var value: any ViewList {
                MappedList(base: list, baseInputs: baseInputs, view: $view, views: views)
            }
        }

        func count(style: IteratorStyle) -> Int {
            base.count(style: style)
        }

        func estimatedCount(style: IteratorStyle) -> Int {
            base.estimatedCount(style: style)
        }

        var traitKeys: ViewTraitKeys? { base.traitKeys }

        var viewIDs: ID.Views? { base.viewIDs }

        var traits: ViewTraitCollection { base.traits }

        func applyNodes(
            from start: inout Int,
            style: IteratorStyle,
            list: Attribute<any ViewList>?,
            transform: inout SublistTransform,
            to body: ApplyBody
        ) -> Bool {
            transform.push(Transform(view: $view, baseInputs: baseInputs, views: views))
            defer { transform.pop() }
            return base.applyNodes(from: &start, style: style, list: list, transform: &transform, to: body)
        }

        func edit(forID id: ID, since transaction: TransactionID) -> Edit? {
            base.edit(forID: id, since: transaction)
        }

        func firstOffset<OtherID>(forID id: OtherID, style: IteratorStyle) -> Int? where OtherID: Hashable {
            base.firstOffset(forID: id, style: style)
        }
    }
}

// MARK: - MappedViews.Transform

extension MappedViews {
    private struct Transform: ViewList.SublistTransform.Item {
        @Attribute var view: MappedViews
        var baseInputs: _GraphInputs
        var views: MutableBox<[ViewList.ID.Canonical: WeakAttribute<MappedContent>]>

        init(
            view: Attribute<MappedViews>,
            baseInputs: _GraphInputs,
            views: MutableBox<[ViewList.ID.Canonical: WeakAttribute<MappedContent>]>
        ) {
            self._view = view
            self.baseInputs = baseInputs
            self.views = views
        }

        func apply(sublist: inout ViewList.Sublist) {
            sublist.elements = MappedElements(
                base: sublist.elements,
                baseInputs: baseInputs,
                id: sublist.id,
                list: WeakAttribute(sublist.list),
                view: $view,
                views: views
            )
        }

        func bindID(_ id: inout ViewList.ID) {
            _openSwiftUIEmptyStub()
        }
    }
}

// MARK: - MappedViews.MappedElements

extension MappedViews {
    private struct MappedElements: ViewList.Elements {
        var base: any ViewList.Elements
        var baseInputs: _GraphInputs
        var id: ViewList.ID
        @WeakAttribute var list: (any ViewList)?
        @Attribute var view: MappedViews
        var views: MutableBox<[ViewList.ID.Canonical: WeakAttribute<MappedContent>]>

        init(
            base: any ViewList.Elements,
            baseInputs: _GraphInputs,
            id: ViewList.ID,
            list: WeakAttribute<any ViewList>,
            view: Attribute<MappedViews>,
            views: MutableBox<[ViewList.ID.Canonical: WeakAttribute<MappedContent>]>
        ) {
            self.base = base
            self.baseInputs = baseInputs
            self.id = id
            self._list = list
            self._view = view
            self.views = views
        }

        var count: Int { base.count }

        func makeElements(
            from start: inout Int,
            inputs: _ViewInputs,
            indirectMap: IndirectAttributeMap?,
            body: ViewList.Elements.Body
        ) -> (_ViewOutputs?, Bool) {
            let list = $list
            let view = $view
            var id = id.elementID(at: start)
            return withoutActuallyEscaping(body) { escapingBody in
                base.makeElements(from: &start, inputs: inputs, indirectMap: indirectMap) { inputs, makeElement in
                    let result = escapingBody(inputs) { bodyInputs in
                        let element = Attribute(ElementView(id: id, view: view, list: WeakAttribute(list)))
                        views.value[id.canonicalID] = WeakAttribute(element)
                        var base = baseInputs
                        if let indirectMap {
                            base.makeReusable(indirectMap: indirectMap)
                        }
                        var inputs = bodyInputs
                        inputs.base.merge(base)
                        inputs.append(makeElement, to: MappedViewElement.BodyInput.self)
                        return MappedContent._makeView(view: _GraphValue(element), inputs: inputs)
                    }
                    id.index += 1
                    return result
                }
            }
        }

        func tryToReuseElement(
            at index: Int,
            by other: any ViewList.Elements,
            at otherIndex: Int,
            indirectMap: IndirectAttributeMap,
            testOnly: Bool
        ) -> Bool {
            var id = id.canonicalID
            id.index = index
            guard let other = other as? MappedElements,
                  let cachedView = views.value[id] else {
                return false
            }
            guard let view = cachedView.attribute else {
                views.value.removeValue(forKey: id)
                return false
            }
            guard base.tryToReuseElement(at: index, by: other.base, at: otherIndex, indirectMap: indirectMap, testOnly: testOnly),
                  baseInputs.tryToReuse(by: other.baseInputs, indirectMap: indirectMap, testOnly: testOnly) else {
                ReuseTrace.traceReuseViewInputsDifferentFailure()
                return false
            }
            if !testOnly {
                view.mutateBody(as: ElementView.self, invalidating: true) {
                    $0 = ElementView(id: other.id, view: other.$view, list: WeakAttribute(other.$list))
                }
            }
            return true
        }

        func retain() -> Release? {
            base.retain()
        }
    }
}

// MARK: - MappedViews.ElementView

extension MappedViews {
    private struct ElementView: Rule, AsyncAttribute {
        var id: ViewList.ID
        @Attribute var view: MappedViews
        @WeakAttribute var list: (any ViewList)?

        init(id: ViewList.ID, view: Attribute<MappedViews>, list: WeakAttribute<any ViewList>) {
            self.id = id
            self._view = view
            self._list = list
        }

        var value: MappedContent {
            withObservation {
                $view.syncMainIfReferences { view in
                    view.transform(MappedViewElement(id: id, traits: list?.traits ?? ViewTraitCollection()))
                }
            }
        }
    }
}
