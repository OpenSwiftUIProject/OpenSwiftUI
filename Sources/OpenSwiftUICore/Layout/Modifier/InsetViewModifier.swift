//
//  InsetViewModifier.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 9508EA06E054356A38E761213D9FFC07 (SwiftUICore)

public import Foundation
import OpenAttributeGraphShims

// MARK: - View + _InsetViewModifier

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Shows the specified content above or below the modified view.
    ///
    /// The `content` view is anchored to the specified
    /// vertical edge in the parent view, aligning its horizontal axis
    /// to the specified alignment guide. The modified view is inset by
    /// the height of `content`, from `edge`, with its safe area
    /// increased by the same amount.
    ///
    ///     struct ScrollableViewWithBottomBar: View {
    ///         var body: some View {
    ///             ScrollView {
    ///                 ScrolledContent()
    ///             }
    ///             .safeAreaInset(edge: .bottom, spacing: 0) {
    ///                 BottomBarContent()
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - edge: The vertical edge of the view to inset by the height of
    ///    `content`, to make space for `content`.
    ///   - spacing: Extra distance placed between the two views, or
    ///     nil to use the default amount of spacing.
    ///   - alignment: The alignment guide used to position `content`
    ///     horizontally.
    ///   - content: A view builder function providing the view to
    ///     display in the inset space of the modified view.
    ///
    /// - Returns: A new view that displays both `content` above or below the
    ///   modified view,
    ///   making space for the `content` view by vertically insetting
    ///   the modified view, adjusting the safe area of the result to match.
    @inlinable
    nonisolated public func safeAreaInset<V>(
        edge: VerticalEdge,
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> V
    ) -> some View where V: View {
        modifier(_InsetViewModifier(
            content: content(),
            edge: Edge(vertical: edge),
            regions: .container,
            spacing: spacing,
            alignmentKey: alignment.key))
    }

    /// Shows the specified content beside the modified view.
    ///
    /// The `content` view is anchored to the specified
    /// horizontal edge in the parent view, aligning its vertical axis
    /// to the specified alignment guide. The modified view is inset by
    /// the width of `content`, from `edge`, with its safe area
    /// increased by the same amount.
    ///
    ///     struct ScrollableViewWithSideBar: View {
    ///         var body: some View {
    ///             ScrollView {
    ///                 ScrolledContent()
    ///             }
    ///             .safeAreaInset(edge: .leading, spacing: 0) {
    ///                 SideBarContent()
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - edge: The horizontal edge of the view to inset by the width of
    ///    `content`, to make space for `content`.
    ///   - spacing: Extra distance placed between the two views, or
    ///     nil to use the default amount of spacing.
    ///   - alignment: The alignment guide used to position `content`
    ///     vertically.
    ///   - content: A view builder function providing the view to
    ///     display in the inset space of the modified view.
    ///
    /// - Returns: A new view that displays `content` beside the modified view,
    ///   making space for the `content` view by horizontally insetting
    ///   the modified view.
    @inlinable
    nonisolated public func safeAreaInset<V>(
        edge: HorizontalEdge,
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> V
    ) -> some View where V: View {
        modifier(_InsetViewModifier(
            content: content(),
            edge: Edge(horizontal: edge),
            regions: .container,
            spacing: spacing,
            alignmentKey: alignment.key))
    }
}

// MARK: - _InsetViewModifier

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _InsetViewModifier<Content>: ViewModifier where Content: View {
    @usableFromInline
    var content: Content

    @usableFromInline
    var properties: (regions: SafeAreaRegions, spacing: CGFloat?, edge: Edge, alignmentKey: AlignmentKey)

    @inlinable
    package init(
        content: Content,
        edge: Edge,
        regions: SafeAreaRegions,
        spacing: CGFloat?,
        alignmentKey: AlignmentKey
    ) {
        self.content = content
        self.properties = (regions, spacing, edge, alignmentKey)
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var primaryInputs = inputs
        var secondaryInputs = inputs
        secondaryInputs.base.pushStableIndex(0)
        secondaryInputs.implicitRootType = _ZStackLayout.self
        secondaryInputs.base.pushStableIndex(1)

        let requestsLayoutComputer = inputs.requestsLayoutComputer
        let needsGeometry = inputs.needsGeometry

        var childGeometry: Attribute<(ViewGeometry, ViewGeometry)>!
        var safeAreaInsets: Attribute<SafeAreaInsets>!
        var layoutComputer: Attribute<LayoutComputer>!
        if requestsLayoutComputer || needsGeometry {
            let layout = InsetViewLayout(
                parentPosition: inputs.position,
                parentSize: inputs.size,
                props: modifier.value[offset: { .of(&$0.properties) }],
                layoutDirection: inputs.layoutDirection
            )
            if needsGeometry {
                let uniqueID = CoordinateSpace.ID()
                let geometry = Attribute(InsetChildGeometry(layout: layout))
                childGeometry = geometry

                primaryInputs.position = geometry.0.origin()
                primaryInputs.size = geometry.0.size()

                let primarySafeAreas = Attribute(
                    InsetPrimarySafeAreas(
                        layout: layout,
                        safeAreaInsets: inputs.safeAreaInsets,
                        uniqueID: uniqueID
                    )
                )
                primaryInputs.safeAreaInsets = OptionalAttribute(primarySafeAreas)
                safeAreaInsets = primarySafeAreas

                let transform = Attribute(
                    InsetPrimaryTransform(
                        position: inputs.position,
                        size: inputs.size,
                        transform: inputs.transform,
                        uniqueID: uniqueID
                    )
                )
                primaryInputs.transform = transform

                secondaryInputs.position = geometry.1.origin()
                secondaryInputs.size = geometry.1.size()
            }
            if requestsLayoutComputer {
                let computer = Attribute(InsetLayoutComputer(layout: layout))
                layoutComputer = computer
            }
        }
        let primaryOutputs = body(_Graph(), primaryInputs)
        let secondaryOuputs = Content.makeDebuggableView(
            view: modifier[offset: { .of(&$0.content) }],
            inputs: secondaryInputs
        )
        if needsGeometry {
            childGeometry.mutateBody(
                as: InsetChildGeometry.self,
                invalidating: true
            ) { computer in
                computer.layout.$primaryLayoutComputer = primaryOutputs.layoutComputer
                computer.layout.$secondaryLayoutComputer = secondaryOuputs.layoutComputer
            }
            safeAreaInsets.mutateBody(
                as: InsetPrimarySafeAreas.self,
                invalidating: true
            ) { computer in
                computer.layout.$primaryLayoutComputer = primaryOutputs.layoutComputer
                computer.layout.$secondaryLayoutComputer = secondaryOuputs.layoutComputer
            }
        }
        if requestsLayoutComputer {
            layoutComputer.mutateBody(
                as: InsetLayoutComputer.self,
                invalidating: true
            ) { computer in
                computer.layout.$primaryLayoutComputer = primaryOutputs.layoutComputer
                computer.layout.$secondaryLayoutComputer = secondaryOuputs.layoutComputer
            }
        }
        var visitor = PairwisePreferenceCombinerVisitor(outputs: (primaryOutputs, secondaryOuputs))
        for key in inputs.preferences.keys {
            key.visitKey(&visitor)
        }
        return visitor.result
    }
}

@available(*, unavailable)
extension _InsetViewModifier: Sendable {}

// MARK: - SafeAreaPaddingModifier

@available(OpenSwiftUI_v5_0, *)
@usableFromInline
struct SafeAreaPaddingModifier: ViewModifier {
    var edges: Edge.Set

    var insets: EdgeInsets?

    @Environment(\.defaultPadding)
    private var defaultPadding: EdgeInsets

    @usableFromInline
    init(edges: Edge.Set, insets: EdgeInsets?) {
        self.edges = edges
        self.insets = insets
    }

    @usableFromInline
    func body(content: SafeAreaPaddingModifier.Content) -> some View {
        content.safeAreaInset(edge: .top) {
            insetView(edge: .top)
        }.safeAreaInset(edge: .bottom) {
            insetView(edge: .bottom)
        }.safeAreaInset(edge: .leading) {
            insetView(edge: .leading)
        }.safeAreaInset(edge: .trailing) {
            insetView(edge: .trailing)
        }
    }

    private func insetView(edge: Edge) -> some View {
        let axis = Axis(edge: edge)
        let inset = (insets ?? defaultPadding)[edge]
        return axis == .horizontal
            ? Color.clear.frame(width: inset)
            : Color.clear.frame(height: inset)
    }
}

@available(*, unavailable)
extension SafeAreaPaddingModifier: Sendable {}

// MARK: - View + SafeAreaPaddingModifier

@available(OpenSwiftUI_v5_0, *)
extension View {
    /// Adds the provided insets into the safe area of this view.
    ///
    /// Use this modifier when you would like to add a fixed amount
    /// of space to the safe area a view sees.
    ///
    ///     ScrollView(.horizontal) {
    ///         HStack(spacing: 10.0) {
    ///             ForEach(items) { item in
    ///                 ItemView(item)
    ///             }
    ///         }
    ///     }
    ///     .safeAreaPadding(.horizontal, 20.0)
    ///
    /// See the ``View/safeAreaInset(edge:alignment:spacing:content)``
    /// modifier for adding to the safe area based on the size of a
    /// view.
    @_alwaysEmitIntoClient
    nonisolated public func safeAreaPadding(_ insets: EdgeInsets) -> some View {
        modifier(SafeAreaPaddingModifier(edges: .all, insets: insets))
    }

    /// Adds the provided insets into the safe area of this view.
    ///
    /// Use this modifier when you would like to add a fixed amount
    /// of space to the safe area a view sees.
    ///
    ///     ScrollView(.horizontal) {
    ///         HStack(spacing: 10.0) {
    ///             ForEach(items) { item in
    ///                 ItemView(item)
    ///             }
    ///         }
    ///     }
    ///     .safeAreaPadding(.horizontal, 20.0)
    ///
    /// See the ``View/safeAreaInset(edge:alignment:spacing:content)``
    /// modifier for adding to the safe area based on the size of a
    /// view.
    @_alwaysEmitIntoClient
    nonisolated public func safeAreaPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        modifier(SafeAreaPaddingModifier(
            edges: edges,
            insets: length.map { EdgeInsets(_all: $0) }
        ))
    }

    /// Adds the provided insets into the safe area of this view.
    ///
    /// Use this modifier when you would like to add a fixed amount
    /// of space to the safe area a view sees.
    ///
    ///     ScrollView(.horizontal) {
    ///         HStack(spacing: 10.0) {
    ///             ForEach(items) { item in
    ///                 ItemView(item)
    ///             }
    ///         }
    ///     }
    ///     .safeAreaPadding(.horizontal, 20.0)
    ///
    /// See the ``View/safeAreaInset(edge:alignment:spacing:content)``
    /// modifier for adding to the safe area based on the size of a
    /// view.
    @_alwaysEmitIntoClient
    nonisolated public func safeAreaPadding(_ length: CGFloat) -> some View {
        safeAreaPadding(.all, length)
    }
}

// MARK: - InsetPrimaryTransform

private struct InsetPrimaryTransform: Rule, AsyncAttribute {
    @Attribute var position: ViewOrigin
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform
    let uniqueID: CoordinateSpace.ID

    var value: ViewTransform {
        var transform = transform.withPosition(position)
        transform.appendSizedSpace(id: uniqueID, size: size.value)
        return transform
    }
}

// MARK: - InsetLayoutComputer

private struct InsetLayoutComputer: StatefulRule, AsyncAttribute {
    var layout: InsetViewLayout

    typealias Value = LayoutComputer

    mutating func updateValue() {
        update(to: Engine(
            layout: layout,
            context: .init(context),
            dimensionsCache: .init()
        ))
    }

    struct Engine: LayoutEngine {
        var layout: InsetViewLayout
        var context: AnyRuleContext
        var dimensionsCache: ViewSizeCache

        mutating func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
            dimensionsCache.get(proposedSize) {
                var size: CGSize!
                context.update {
                    size = layout.sizeThatFits(proposedSize)
                }
                return size
            }
        }
    }
}

// MARK: - InsetPrimarySafeAreas

private struct InsetPrimarySafeAreas: Rule, AsyncAttribute {
    var layout: InsetViewLayout
    @OptionalAttribute var safeAreaInsets: SafeAreaInsets?
    let uniqueID: CoordinateSpace.ID

    var value: SafeAreaInsets {
        let elements = [layout.primarySafeAreaInsets()]
        let next: SafeAreaInsets.OptionalValue
        if let safeAreaInsets {
            next = .insets(safeAreaInsets)
        } else {
            next = .empty
        }
        return SafeAreaInsets(
            space: uniqueID,
            elements: elements,
            next: next
        )
    }
}

// MARK: - InsetChildGeometry

private struct InsetChildGeometry: Rule, AsyncAttribute {
    var layout: InsetViewLayout

    var value: (ViewGeometry, ViewGeometry) {
        layout.childGeometry()
    }
}

// MARK: - InsetViewLayout

private struct InsetViewLayout {
    @Attribute var parentPosition: ViewOrigin
    @Attribute var parentSize: ViewSize
    @Attribute var props: (regions: SafeAreaRegions, spacing: CGFloat?, edge: Edge, alignmentKey: AlignmentKey)
    @Attribute var layoutDirection: LayoutDirection
    @OptionalAttribute var primaryLayoutComputer: LayoutComputer?
    @OptionalAttribute var secondaryLayoutComputer: LayoutComputer?

    func spacing() -> CGFloat {
        guard let spacing = props.spacing else {
            let primaryComputer = primaryLayoutComputer ?? .defaultValue
            let secondaryComputer = secondaryLayoutComputer ?? .defaultValue
            let axis = Axis(edge: props.edge)
            return primaryComputer.spacing().distanceToSuccessorView(
                along: axis,
                layoutDirection: layoutDirection,
                preferring: secondaryComputer.spacing()
            ) ?? defaultSpacingValue[axis]
        }
        return spacing
    }

    func primaryMinimum(
        parentProposalWithoutSpacing proposal: _ProposedSize
    ) -> CGFloat {
        var proposal = proposal
        let axis = Axis(edge: props.edge)
        proposal[axis] = .zero
        let computer = primaryLayoutComputer ?? .defaultValue
        return computer.sizeThatFits(proposal)[axis]
    }

    func secondaryProposal(
        parentProposal: _ProposedSize,
        spacing: CGFloat
    ) -> _ProposedSize {
        var proposal = parentProposal
        let axis = Axis(edge: props.edge)
        guard let value = parentProposal[axis] else {
            return parentProposal
        }
        let valueWithoutSpacing = max(value - spacing, .zero)
        proposal[axis] = valueWithoutSpacing
        let minimum = primaryMinimum(parentProposalWithoutSpacing: proposal)
        let result = max(valueWithoutSpacing - minimum, .zero)
        proposal[axis] = result
        return proposal
    }

    func primaryProposal(
        parentProposal: _ProposedSize,
        secondarySize: CGSize,
        spacing: CGFloat
    ) -> _ProposedSize {
        var proposal = parentProposal
        let axis = Axis(edge: props.edge)
        guard let value = parentProposal[axis] else {
            return parentProposal
        }
        proposal[axis] = max(value - (secondarySize[axis] + spacing), .zero)
        return proposal
    }

    func childGeometry() -> (ViewGeometry, ViewGeometry) {
        let spacing = spacing()
        let primaryAxis = Axis(edge: props.edge)
        let secondaryAxis = primaryAxis.otherAxis
        var proposal = parentSize.proposal
        let secondaryValue = proposal[secondaryAxis] ?? parentSize[secondaryAxis]
        proposal[secondaryAxis] = secondaryValue
        let secondaryProposal = secondaryProposal(
            parentProposal: proposal,
            spacing: spacing
        )
        let secondaryComputer = secondaryLayoutComputer ?? .defaultValue
        let secondarySize = secondaryComputer.sizeThatFits(secondaryProposal)
        let primaryProposal = primaryProposal(
            parentProposal: proposal,
            secondarySize: secondarySize,
            spacing: spacing
        )
        let primaryComputer = primaryLayoutComputer ?? .defaultValue
        let primarySize = primaryComputer.sizeThatFits(primaryProposal)

        let primaryAnchor = UnitPoint(edge: props.edge.opposite)
        let primaryPlacement = _Placement(
            proposedSize: primaryProposal,
            aligning: primaryAnchor,
            in: parentSize.value
        )
        let alignmentKeyID = props.alignmentKey.id
        let primaryDimensions = ViewDimensions(
            guideComputer: primaryComputer,
            size: primarySize,
            proposal: primaryProposal
        )
        let primaryAlignmentValue = primaryDimensions[.init(
            id: alignmentKeyID,
            axis: secondaryAxis
        )]
        let secondaryDimensions = ViewDimensions(
            guideComputer: secondaryComputer,
            size: secondarySize,
            proposal: secondaryProposal
        )
        let secondaryAlignmentValue = secondaryDimensions[.init(
            id: alignmentKeyID,
            axis: secondaryAxis)
        ]
        var primaryGeometry = ViewGeometry(
            placement: primaryPlacement,
            dimensions: primaryDimensions
        )

        let position = (primaryGeometry.origin[secondaryAxis] + primaryAlignmentValue) - (secondaryAlignmentValue + .zero)
        
        let secondaryAnchor = UnitPoint(edge: props.edge)
        let secondaryPlacement = _Placement(
            proposedSize: secondaryProposal,
            aligning: secondaryAnchor,
            in: parentSize.value
        )
        var secondaryGeometry = ViewGeometry(
            placement: secondaryPlacement,
            dimensions: secondaryDimensions
        )
        secondaryGeometry.origin[secondaryAxis] = position

        primaryGeometry.finalizeLayoutDirection(
            layoutDirection,
            parentSize: parentSize.value
        )
        secondaryGeometry.finalizeLayoutDirection(
            layoutDirection,
            parentSize: parentSize.value
        )

        primaryGeometry.origin += CGSize(parentPosition)
        secondaryGeometry.origin += CGSize(parentPosition)

        return (primaryGeometry, secondaryGeometry)
    }

    func sizeThatFits(_ proposal: _ProposedSize) -> CGSize {
        let spacing = spacing()

        let secondaryProposal = secondaryProposal(
            parentProposal: proposal,
            spacing: spacing
        )
        let secondaryComputer = secondaryLayoutComputer ?? .defaultValue
        let secondarySize = secondaryComputer.sizeThatFits(secondaryProposal)

        let primaryProposal = primaryProposal(
            parentProposal: proposal,
            secondarySize: secondarySize,
            spacing: spacing
        )
        let primaryComputer = primaryLayoutComputer ?? .defaultValue
        let primarySize = primaryComputer.sizeThatFits(primaryProposal)

        switch Axis(edge: props.edge) {
        case .horizontal:
            return CGSize(
                width: secondarySize.width + spacing + primarySize.width,
                height: max(secondarySize.height, primarySize.height)
            )
        case .vertical:
            return CGSize(
                width: max(secondarySize.width, primarySize.width),
                height: secondarySize.height + spacing + primarySize.height
            )
        }
    }

    func primarySafeAreaInsets() -> SafeAreaInsets.Element {
        let spacing = spacing()

        let secondaryProposal = secondaryProposal(
            parentProposal: .init(parentSize.value),
            spacing: spacing
        )
        let secondaryComputer = secondaryLayoutComputer ?? .defaultValue
        let secondarySize = secondaryComputer.sizeThatFits(secondaryProposal)

        let axis = Axis(edge: props.edge)
        let length = spacing + secondarySize[axis]
        let edgeSet = Edge.Set(props.edge)

        var insets = EdgeInsets(length, edges: edgeSet)
        insets.xFlipIfRightToLeft { layoutDirection }
        return SafeAreaInsets.Element(
            regions: props.regions,
            insets: insets
        )
    }
}
