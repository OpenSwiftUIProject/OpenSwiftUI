//
//  ViewListView.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 52A2FFECFBCF37BFFEED558E33EBD1E3 (SwiftUI?)
//  ID: 9B09D1820E97ECBB666F7560EA2A2D2C (SwiftUICore?)

package import OpenAttributeGraphShims

// MARK: - ViewListVisitor

package protocol ViewListVisitor {
    mutating func visit(view: ViewList.View, traits: ViewTraitCollection) -> Bool
}

// MARK: - ViewList.Backing

extension ViewList {
    package typealias Backing = _ViewList_Backing
}

package struct _ViewList_Backing {
    package var children: _VariadicView.Children

    package var viewCount: Int {
        children.list.count
    }

    package init(_ children: _VariadicView.Children)  {
        self.children = children
    }

    package func visitViews<V>(applying v: inout V, from start: inout Int) -> Bool where V: ViewListVisitor {
        Update.ensure {
            children.list.applySublists(from: &start, list: nil) { sublist in
                var index = sublist.start
                let count = sublist.count
                if index < count {
                    repeat {
                        let view = ViewList.View(
                            elements: sublist.elements,
                            id: sublist.id,
                            index: index,
                            count: count,
                            contentSubgraph: children.contentSubgraph
                        )
                        guard v.visit(view: view, traits: sublist.traits) else {
                            return false
                        }
                        index &+= 1
                    } while count != index
                }
                return true
            }
        }
    }
}

extension ViewList.Backing {
    package func visitAll<V>(
        applying v: inout V
    ) where V: ViewListVisitor {
        var start = 0
        _ = visitViews(applying: &v, from: &start)
    }

    package func visitViews<V>(
        applying v: inout V,
        from start: Int
    ) where V: ViewListVisitor {
        var start = start
        _ = visitViews(applying: &v, from: &start)
    }
}

extension ViewList.Backing {
    package var ids: [AnyHashable] {
        Update.ensure {
            var start = 0
            var ids: [AnyHashable] = []
            children.list.applySublists(from: &start, list: nil) { sublist in
                var index = sublist.start
                let count = sublist.count
                if index < count {
                    repeat {
                        Swift.assert(index < count)
                        let view = ViewList.View(
                            elements: sublist.elements,
                            id: sublist.id,
                            index: index,
                            count: count,
                            contentSubgraph: children.contentSubgraph
                        )
                        let canonicalID = view.id.canonicalID
                        let id: AnyHashable
                        if let explicitID = canonicalID.explicitID {
                            id = AnyHashable(explicitID.anyValue)
                        } else {
                            id = AnyHashable(canonicalID)
                        }
                        ids.append(id)
                        index &+= 1
                    } while count != index
                }
                return true
            }
            return ids
        }
    }
}

// MARK: - ViewList.View

extension ViewList {
    package typealias View = _ViewList_View
}

package struct _ViewList_View: PrimitiveView, View, UnaryView {
    var elements: any ViewList.Elements
    var releaseElements: ViewList.Elements.Release?
    package var id: ViewList.ID
    var index: Int
    var count: Int
    var contentSubgraph: Subgraph?

    @inline(__always)
    init(emptyViewID implicitID: Int) {
        self.elements = EmptyViewListElements()
        self.releaseElements = nil
        self.id = .init(implicitID: implicitID)
        self.index = .zero
        self.count = .zero
        self.contentSubgraph = nil
    }

    package init(
        elements: any ViewList.Elements,
        id: ViewList.ID,
        index: Int,
        count: Int,
        contentSubgraph: Subgraph
    ) {
        self.elements = elements
        releaseElements = elements.retain()
        self.id = id
        self.index = index
        self.count = count
        self.contentSubgraph = contentSubgraph
    }

    package var elementID: ViewList.ID {
        id.elementID(at: index)
    }

    package var reuseIdentifier: Int {
        elementID.reuseIdentifier
    }

    package var viewID: AnyHashable {
        let canonicalID = elementID.canonicalID
        if count == 1, !canonicalID.requiresImplicitID {
            return canonicalID.explicitID!.anyHashable
        } else {
            return AnyHashable(canonicalID)
        }
    }

    package var subviewID: ViewList.ID {
        id.elementID(at: index)
    }

    nonisolated package static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let outputs = inputs.makeIndirectOutputs()
        let placeholderInfo = Attribute(
            PlaceholderInfo(
                placeholder: view.value,
                inputs: inputs,
                outputs: outputs
            )
        )
        outputs.setIndirectDependency(placeholderInfo.identifier)
        return outputs
    }
}

// MARK: - ViewListShouldParentToPlaceholderSubgraph

package struct ViewListShouldParentToPlaceholderSubgraph: GraphInput {
    package static let defaultValue: Bool = true
}

// MARK: - PlaceholderInfo

private struct PlaceholderInfo: StatefulRule, ObservedAttribute, AsyncAttribute {
    @Attribute var placeholder: ViewList.View
    let inputs: _ViewInputs
    let outputs: _ViewOutputs
    let parentSubgraph: Subgraph
    var lastSubgraph: Subgraph?
    var lastRelease: ViewList.Elements.Release?
    var secondaryRelease: ViewList.Elements.Release?
    var lastElements: (any ViewList.Elements)?
    var lastMap: IndirectAttributeMap?
    var contentObserver: (Subgraph, Int)?
    var lastPhase: Attribute<_GraphInputs.Phase>?

    init(placeholder: Attribute<ViewList.View>, inputs: _ViewInputs, outputs: _ViewOutputs) {
        self._placeholder = placeholder
        self.inputs = inputs
        self.outputs = outputs
        self.parentSubgraph = .current!
    }

    struct Value {
        var id: ViewList.ID
        var seed: UInt32
        var index: Int
    }

    mutating func makeItem(placeholder: ViewList.View, seed: UInt32) -> Value {
        guard let contentSubgraph = placeholder.contentSubgraph,
              contentSubgraph.isValid else {
            return .init(id: .init(), seed: seed, index: .min)
        }
        let child = Subgraph(graph: parentSubgraph.graph)
        parentSubgraph.addChild(child)
        let shouldParentToPlaceholder = inputs.base[ViewListShouldParentToPlaceholderSubgraph.self]
        if parentSubgraph !== contentSubgraph, shouldParentToPlaceholder {
            contentSubgraph.addChild(child, tag: 1)
        }
        child.apply {
            // TODO: GraphReuseOptions on v7
            let indirectMap = IndirectAttributeMap(subgraph: child)
            let elementOutputs = placeholder.elements.makeOneElement(
                at: placeholder.index,
                inputs: inputs,
                indirectMap: indirectMap
            ) { elementInputs, makeElement in
                lastPhase = Attribute(PlaceholderViewPhase(
                    phase1: elementInputs.viewPhase,
                    phase2: inputs.viewPhase,
                    resetDelta: .zero
                ))
                var newInputs = elementInputs
                newInputs.base[ViewListShouldParentToPlaceholderSubgraph.self] = true
                newInputs.copyCaches()
                newInputs.base.changedDebugProperties.formUnion([.transform, .position, .size])
                newInputs.base.merge(inputs.base, ignoringPhase: true)
                newInputs.base.mergedInputs.insert(lastPhase!.identifier)
                return makeElement(newInputs)
            }
            elementOutputs.map {
                outputs.attachIndirectOutputs(to: $0)
            }
            lastMap = indirectMap
        }
        lastSubgraph = child
        lastRelease = placeholder.elements.retain()
        lastElements = placeholder.elements
        if contentSubgraph.graph !== child.graph {
            let token = contentSubgraph.addObserver { [parentSubgraph, attribute] in
                guard parentSubgraph.isValid else { return }
                let infoPointer = UnsafeMutableRawPointer(mutating: attribute.identifier._bodyPointer)
                    .assumingMemoryBound(to: Self.self)
                infoPointer.pointee.contentObserver = nil
                infoPointer.pointee.eraseItem()
            }
            contentObserver = (contentSubgraph, token)
        }
        return Value(id: placeholder.id, seed: seed, index: placeholder.index)
    }

    mutating func reuseItem(info: inout Value, placeholder: ViewList.View) -> Bool {
        guard let lastElements,
              lastElements.tryToReuseElement(
                  at: info.index,
                  by: placeholder.elements,
                  at: placeholder.index,
                  indirectMap: lastMap!,
                  testOnly: false
              )
        else {
            ReuseTrace.traceReuseInvalidSubgraphFailure(ViewList.View.self)
            return false
        }
        lastPhase!.mutateBody(
            as: PlaceholderViewPhase.self,
            invalidating: true
        ) { phase in
            phase.resetDelta &+= 1
        }
        secondaryRelease = placeholder.elements.retain()
        info.id = placeholder.id
        info.index = placeholder.index
        return true
    }

    mutating func eraseItem() {
        outputs.detachIndirectOutputs()
        if let lastSubgraph {
            lastSubgraph.willInvalidate(isInserted: true)
            lastSubgraph.invalidate()
            self.lastSubgraph = nil
        }
        if let contentObserver {
            contentObserver.0.removeObserver(contentObserver.1)
            self.contentObserver = nil
        }
        lastRelease = nil
        secondaryRelease = nil
        lastElements = nil
        lastMap = nil
        lastPhase = nil
    }

    mutating func updateValue() {
        guard hasValue else {
            if lastSubgraph != nil {
                eraseItem()
            }
            value = makeItem(placeholder: placeholder, seed: 0)
            return
        }
        if value.index != placeholder.index || value.id == placeholder.id {
            let newValue: Value
            if reuseItem(info: &value, placeholder: placeholder) {
                newValue = value
            } else {
                let seed = value.seed &+ 1
                if lastSubgraph != nil {
                    eraseItem()
                }
                newValue = makeItem(placeholder: placeholder, seed: seed)
            }
            value = newValue
        }
    }

    mutating func destroy() {
        if let contentObserver {
            contentObserver.0.removeObserver(contentObserver.1)
            self.contentObserver = nil
        }
        lastRelease = nil
        secondaryRelease = nil
    }
}

// MARK: - PlaceholderViewPhase

private struct PlaceholderViewPhase: Rule, AsyncAttribute {
    @Attribute var phase1: _GraphInputs.Phase
    @Attribute var phase2: _GraphInputs.Phase
    var resetDelta: UInt32

    var value: _GraphInputs.Phase {
        var result = phase1
        result.merge(phase2)
        result.resetSeed &+= resetDelta
        return result
    }
}
