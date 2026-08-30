//
//  ViewThatFits.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: F613AABF2A2A0496B46514894D5116C3 (SwiftUI)

@_spi(ForOpenSwiftUIOnly) public import OpenSwiftUICore
import OpenAttributeGraphShims
import OpenCoreGraphicsShims

// MARK: - ViewThatFits

/// A view that adapts to the available space by providing the first
/// child view that fits.
///
/// `ViewThatFits` evaluates its child views in the order you provide them
/// to the initializer. It selects the first child whose ideal size on the
/// constrained axes fits within the proposed size. This means that you
/// provide views in order of preference. Usually this order is largest to
/// smallest, but since a view might fit along one constrained axis but not the
/// other, this isn't always the case. By default, `ViewThatFits` constrains
/// in both the horizontal and vertical axes.
///
/// The following example shows an `UploadProgressView` that uses `ViewThatFits`
/// to display the upload progress in one of three ways. In order, it attempts
/// to display:
///
/// * An ``HStack`` that contains a ``Text`` view and a ``ProgressView``.
/// * Only the `ProgressView`.
/// * Only the `Text` view.
///
/// The progress views are fixed to a 100-point width.
///
///     struct UploadProgressView: View {
///         var uploadProgress: Double
///
///         var body: some View {
///             ViewThatFits(in: .horizontal) {
///                 HStack {
///                     Text("\(uploadProgress.formatted(.percent))")
///                     ProgressView(value: uploadProgress)
///                         .frame(width: 100)
///                 }
///                 ProgressView(value: uploadProgress)
///                     .frame(width: 100)
///                 Text("\(uploadProgress.formatted(.percent))")
///             }
///         }
///     }
///
/// This use of `ViewThatFits` evaluates sizes only on the horizontal axis. The
/// following code fits the `UploadProgressView` to several fixed widths:
///
///     VStack {
///         UploadProgressView(uploadProgress: 0.75)
///             .frame(maxWidth: 200)
///         UploadProgressView(uploadProgress: 0.75)
///             .frame(maxWidth: 100)
///         UploadProgressView(uploadProgress: 0.75)
///             .frame(maxWidth: 50)
///     }
///
/// ![A vertical stack showing three expressions of progress, constrained by
/// the available horizontal space. The first line shows the text, 75%, and a
/// three-quarters-full progress bar. The second line shows only the progress
/// view. The third line shows only the text.](ViewThatFits-1)
@available(OpenSwiftUI_v4_0, *)
@frozen
public struct ViewThatFits<Content>: View, UnaryView, PrimitiveView where Content: View {
    @usableFromInline
    var _tree: _VariadicView.Tree<_SizeFittingRoot, Content>

    /// Produces a view constrained in the given axes from one of several
    /// alternatives provided by a view builder.
    ///
    /// - Parameters:
    ///     - axes: A set of axes to constrain children to. The set may
    ///       contain ``Axis/horizontal``, ``Axis/vertical``, or both of these.
    ///       `ViewThatFits` chooses the first child whose size fits within the
    ///       proposed size on these axes. If `axes` is an empty set,
    ///       `ViewThatFits` uses the first child view. By default,
    ///       `ViewThatFits` uses both axes.
    ///     - content: A view builder that provides the child views for this
    ///       container, in order of preference. The builder chooses the first
    ///       child view that fits within the proposed width, height, or both,
    ///       as defined by `axes`.
    @inlinable
    public init(in axes: Axis.Set = [.horizontal, .vertical], @ViewBuilder content: () -> Content) {
        _tree = .init(_SizeFittingRoot(axes: axes)) { content() }
    }

    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        _VariadicView.Tree<_SizeFittingRoot, Content>.makeDebuggableView(
            view: view[offset: { .of(&$0._tree) }],
            inputs: inputs
        )
    }
}
@available(*, unavailable)
extension ViewThatFits: Sendable {}

// MARK: - _SizeFittingRoot

@frozen
public struct _SizeFittingRoot: _VariadicView.UnaryViewRoot {
    @usableFromInline
    var axes: Axis.Set

    @inlinable
    init(axes: Axis.Set) { self.axes = axes }

    nonisolated public static func _makeView(root: _GraphValue<Self>, inputs: _ViewInputs, body: (_Graph, _ViewInputs) -> _ViewListOutputs) -> _ViewOutputs {
        let list = body(_Graph(), inputs)
            .makeAttribute(inputs: _ViewListInputs(inputs.base))
        var childInputs = inputs
        childInputs.requestsLayoutComputer = false
        childInputs.preferences.remove(WidgetAuxiliaryViewMetadata.Key.self)
        var outputs = childInputs.makeIndirectOutputs()
        let state = SizeFittingState(
            root: root.value,
            list: list,
            inputs: childInputs,
            outputs: outputs
        )
        let mux = Attribute(SizeFittingMux(state: state))
        outputs.setIndirectDependency(mux.identifier)
        if inputs.requestsLayoutComputer {
            outputs.layoutComputer = Attribute(SizeFittingLayoutComputer(state: state))
        }
        if let representation = inputs.requestedViewThatFitsRepresentation,
           representation.shouldMakeRepresentation(inputs: inputs) {
            representation.makeRepresentation(inputs: inputs, state: state, outputs: &outputs)
        }
        return outputs
    }

    fileprivate func size(_ size: CGSize, fits proposal: _ProposedSize) -> Bool {
        (!axes.contains(.horizontal) || size.width <= (proposal.width ?? .infinity)) &&
            (!axes.contains(.vertical) || size.height <= (proposal.height ?? .infinity))
    }
}

// MARK: - SizeFittingState

final package class SizeFittingState {
    @Attribute var root: _SizeFittingRoot
    @Attribute var list: any ViewList
    let inputs: _ViewInputs
    let outputs: _ViewOutputs
    let parentSubgraph: Subgraph
    var children: [ViewList.ID.Canonical: Child]
    var seed: UInt32

    init(
        root: Attribute<_SizeFittingRoot>,
        list: Attribute<any ViewList>,
        inputs: _ViewInputs,
        outputs: _ViewOutputs
    ) {
        _root = root
        _list = list
        self.inputs = inputs
        self.outputs = outputs
        parentSubgraph = Subgraph.current!
        children = [:]
        seed = 0
    }

    package func applyChildren(
        selectLast: Bool,
        to body: (_ViewOutputs, Bool) -> Bool
    ) {
        seed.unsafeIncrement()
        let list = list
        let count = list.count
        var start = 0
        var order = 0
        var selectedOrder: Int?

        list.applySublists(from: &start, list: $list) { sublist in
            let lastOrder = count &- 1
            for index in 0 ..< sublist.count {
                let id = sublist.id.elementID(at: index).canonicalID
                if let child = children[id] {
                    if child.isInserted || selectedOrder == nil {
                        precondition(child.seed != seed, "child view IDs must be unique: \(id)")
                        var newChild = child
                        newChild.seed = seed
                        newChild.order = UInt32(truncatingIfNeeded: order)
                        children[id] = newChild
                        if selectedOrder == nil,
                           body(newChild.outputs, order == lastOrder) {
                            selectedOrder = order
                        }
                    }
                } else if selectedOrder == nil {
                    let subgraph = Subgraph(graph: parentSubgraph.graph)
                    let child = subgraph.apply {
                        var inputs = inputs
                        inputs.copyCaches()
                        let outputs = sublist.elements.makeOneElement(at: index, inputs: inputs) { inputs, makeElement in
                            makeElement(inputs)
                        } ?? _ViewOutputs()
                        return Child(
                            subgraph: subgraph,
                            release: sublist.elements.retain(),
                            outputs: outputs,
                            seed: seed,
                            order: order
                        )
                    }
                    children[id] = child
                    if selectedOrder == nil,
                       body(child.outputs, order == lastOrder) {
                        selectedOrder = order
                    }
                }
                if order == lastOrder {
                    return false
                }
                order &+= 1
            }
            return true
        }

        children = children.filter { _, child in
            guard child.seed != seed else {
                return true
            }
            child.subgraph.willInvalidate(isInserted: child.isInserted)
            child.subgraph.invalidate()
            return false
        }

        guard let selectedOrder, selectLast else {
            return
        }
        children.forEach { id, value in
            var child = value
            let shouldInsert = Int(child.order) == selectedOrder
            if shouldInsert != child.isInserted {
                child.isInserted = shouldInsert
                if shouldInsert {
                    parentSubgraph.addChild(child.subgraph)
                    child.subgraph.didReinsert()
                    outputs.attachIndirectOutputs(to: child.outputs)
                } else {
                    child.subgraph.willRemove()
                    parentSubgraph.removeChild(child.subgraph)
                }
            }
            children[id] = child
        }
    }

    package func invalidate() {
        for child in children.values {
            child.subgraph.willInvalidate(isInserted: child.isInserted)
            child.subgraph.invalidate()
        }
    }

    struct Child {
        var subgraph: Subgraph
        var release: ViewList.Elements.Release?
        var outputs: _ViewOutputs
        var seed: UInt32
        var order: UInt32
        var isInserted: Bool

        @inline(__always)
        init(
            subgraph: Subgraph,
            release: ViewList.Elements.Release?,
            outputs: _ViewOutputs,
            seed: UInt32,
            order: Int
        ) {
            self.subgraph = subgraph
            self.release = release
            self.outputs = outputs
            self.seed = seed
            self.order = UInt32(truncatingIfNeeded: order)
            isInserted = false
        }
    }
}

// MARK: - SizeFittingMux

private struct SizeFittingMux: StatefulRule, ObservedAttribute, AsyncAttribute {
    let state: SizeFittingState

    typealias Value = Void

    mutating func updateValue() {
        let proposal = state.inputs.size.value.proposal
        state.applyChildren(selectLast: true) { outputs, isLast in
            let computer = outputs.layoutComputer?.value ?? .defaultValue
            let axes = state.root.axes
            var fittingProposal = proposal
            if axes.contains(.horizontal) {
                fittingProposal.width = nil
            }
            if axes.contains(.vertical) {
                fittingProposal.height = nil
            }
            let size = computer.sizeThatFits(fittingProposal)
            return isLast || state.root.size(size, fits: proposal)
        }
    }

    mutating func destroy() {
        state.invalidate()
    }
}

// MARK: - SizeFittingLayoutComputer

private struct SizeFittingLayoutComputer: StatefulRule, AsyncAttribute {
    let state: SizeFittingState

    typealias Value = LayoutComputer

    mutating func updateValue() {
        update(to: Engine(root: state.root, ctx: context, state: state))
    }

    private struct Engine: LayoutEngine {
        var root: _SizeFittingRoot
        let ctx: RuleContext<LayoutComputer>
        let state: SizeFittingState
        var sizeCache: ViewSizeCache = .init()

        mutating func spacing() -> Spacing {
            var result = Spacing.zero
            ctx.update {
                state.applyChildren(selectLast: false) { outputs, _ in
                    let computer = outputs.layoutComputer?.value ?? .defaultValue
                    result = computer.spacing()
                    return true
                }
            }
            return result
        }

        mutating func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
            let root = root
            let ctx = ctx
            let state = state
            return sizeCache.get(proposedSize) {
                var result = CGSize.zero
                ctx.update {
                    state.applyChildren(selectLast: false) { outputs, _ in
                        let computer = outputs.layoutComputer?.value ?? .defaultValue
                        var fittingProposal = proposedSize
                        if root.axes.contains(.horizontal) {
                            fittingProposal.width = nil
                        }
                        if root.axes.contains(.vertical) {
                            fittingProposal.height = nil
                        }
                        let fittingSize = computer.sizeThatFits(fittingProposal)
                        result = computer.sizeThatFits(proposedSize)
                        return root.size(fittingSize, fits: proposedSize)
                    }
                }
                return result
            }
        }

        mutating func explicitAlignment(_ key: AlignmentKey, at viewSize: ViewSize) -> CGFloat? {
            var result: CGFloat?
            ctx.update {
                state.applyChildren(selectLast: false) { outputs, isLast in
                    let computer = outputs.layoutComputer?.value ?? .defaultValue
                    var fittingProposal = viewSize.proposal
                    if root.axes.contains(.horizontal) {
                        fittingProposal.width = nil
                    }
                    if root.axes.contains(.vertical) {
                        fittingProposal.height = nil
                    }
                    let fittingSize = computer.sizeThatFits(fittingProposal)
                    guard isLast || root.size(fittingSize, fits: viewSize.proposal) else {
                        return false
                    }
                    result = computer.explicitAlignment(key, at: viewSize)
                    return true
                }
            }
            return result
        }
    }
}

// MARK: - PlatformViewThatFitsRepresentable

package protocol PlatformViewThatFitsRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool

    static func makeRepresentation(inputs: _ViewInputs, state: SizeFittingState, outputs: inout _ViewOutputs)
}

extension _ViewInputs {
    package var requestedViewThatFitsRepresentation: (any PlatformViewThatFitsRepresentable.Type)? {
        get { base.requestedViewThatFitsRepresentation }
        set { base.requestedViewThatFitsRepresentation = newValue }
    }
}

extension _GraphInputs {
    private struct ViewThatFitsRepresentationKey: GraphInput {
        static var defaultValue: (any PlatformViewThatFitsRepresentable.Type)? { nil }
    }

    package var requestedViewThatFitsRepresentation: (any PlatformViewThatFitsRepresentable.Type)? {
        get { self[ViewThatFitsRepresentationKey.self] }
        set { self[ViewThatFitsRepresentationKey.self] = newValue }
    }
}
