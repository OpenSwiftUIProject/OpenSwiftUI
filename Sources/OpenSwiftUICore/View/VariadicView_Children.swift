//
//  VariadicView_Children.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 52A2FFECFBCF37BFFEED558E33EBD1E3 (?)
//  ID: 9B09D1820E97ECBB666F7560EA2A2D2C (?)

package import OpenAttributeGraphShims

// MARK: - _VariadicView.Children + View [WIP]

@available(OpenSwiftUI_v1_0, *)
extension _VariadicView.Children: View, MultiView, PrimitiveView {
    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        let child = _GraphValue(Child(children: view.value))
        return ForEach._makeViewList(view: child, inputs: inputs)
    }

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs
    ) -> Int? {
        nil
    }

    private struct Child: Rule, AsyncAttribute {
        typealias Value = ForEach<_VariadicView.Children, AnyHashable, _VariadicView.Children.Element>

        @Attribute var children: _VariadicView.Children

        var value: Value {
            _openSwiftUIUnimplementedFailure()
        }
    }
}

// MARK: - _VariadicView.Children + RandomAccessCollection [WIP]

@available(OpenSwiftUI_v1_0, *)
extension _VariadicView.Children: RandomAccessCollection {
    public struct Element: PrimitiveView, UnaryView, Identifiable {
        var view: ViewList.View
        var traits: ViewTraitCollection
        
        public var id: AnyHashable {
            _openSwiftUIUnimplementedFailure()

        }
        public func id<ID>(as _: ID.Type = ID.self) -> ID? where ID : Hashable {
            _openSwiftUIUnimplementedFailure()
        }

        /// The value of each trait associated with the view. Changing
        /// the traits will not affect the view in any way.
        public subscript<Trait: _ViewTraitKey>(key: Trait.Type) -> Trait.Value {
            get { traits[key] }
            set { traits[key] = newValue }
        }

        public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
            _openSwiftUIUnimplementedFailure()
        }
    }
    
    public var startIndex: Int {
        _openSwiftUIUnimplementedFailure()
    }

    public var endIndex: Int {
        _openSwiftUIUnimplementedFailure()
    }

    public subscript(index: Int) -> Element {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - ViewListVisitor

package protocol ViewListVisitor {
    mutating func visit(view: ViewList.View, traits: ViewTraitCollection) -> Bool
}

// MARK: - ViewList.Backing [WIP]

extension ViewList {
    package typealias Backing = _ViewList_Backing
}

package struct _ViewList_Backing {
    package var children: _VariadicView.Children

    package var viewCount: Swift.Int {
        children.list.count
    }

    package init(_ children: _VariadicView.Children)  {
        self.children = children
    }

    package func visitViews<V>(applying v: inout V, from start: inout Int) -> Bool where V: ViewListVisitor {
        Update.ensure {
            children.list.applySublists(from: &start, list: nil) { sublist in
                _openSwiftUIUnimplementedFailure()
            }
        }
    }
}

extension ViewList.Backing {
    package func visitAll<V>(applying v: inout V) where V: ViewListVisitor {
        _openSwiftUIUnimplementedFailure()
    }

    package func visitViews<V>(applying v: inout V, from start: Int) where V: ViewListVisitor {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ViewList.Backing {
    package var ids: [AnyHashable] {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - _ViewList.View

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

    package init(
        elements: any ViewList.Elements,
        id: ViewList.ID,
        index: Int,
        count: Int,
        contentSubgraph: Subgraph
    ) {
        self.elements = elements
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

    nonisolated package static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let outputs = inputs.makeIndirectOutputs()
        let placeholderInfo = PlaceholderInfo(
            placeholder: view.value,
            inputs: inputs,
            outputs: outputs
        )
        let attribute = Attribute(placeholderInfo)
        outputs.setIndirectDependency(attribute.identifier)
        return outputs
    }
}

// MARK: - PlaceholderInfo [WIP]

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
        // FIXME: The Subgraph.current call on the init default value or the call site will trigger a compiler crash (SIL -> IR) on Release build
        // We workaround it by setting it to .current here
        self.parentSubgraph = .current!
    }

    struct Value {
        var id: ViewList.ID
        var seed: UInt32
        var index: Int
    }

    func makeItem(placeholder: ViewList.View, seed: UInt32) -> Value {
        _openSwiftUIUnimplementedFailure()
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
            // TODO: OSubgraphRemoveObserver
            // contentObserver.0.removeObserver(contentObserver.1)
            self.contentObserver = nil
        }
        lastRelease = nil
        secondaryRelease = nil
        lastElements = nil
        lastMap = nil
        lastPhase = nil
    }

    mutating func updateValue() {
        _openSwiftUIUnimplementedFailure()
    }

    func destroy() {
        if let contentObserver {
            // TODO: OSubgraphRemoveObserver
            // contentObserver.0.removeObserver(contentObserver.1)
        }
    }
}

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
