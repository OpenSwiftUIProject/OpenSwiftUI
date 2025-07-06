//
//  PaddingLayout.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A5372118658F90C947BF499CB95E323D (SwiftUICore)

public import Foundation

/// Pads a view by the specified amount or the default amount.
///
/// Child sizing: Stretches to fill minus the given inset.
///
/// Preferred size: Preferred size of child plus inset.
@frozen
public struct _PaddingLayout: UnaryLayout {
    public var edges: Edge.Set

    public var insets: EdgeInsets?

    @inlinable
    public init(edges: Edge.Set = .all, insets: EdgeInsets?) {
        self.edges = edges
        self.insets = insets
    }

    package func placement(of child: LayoutProxy, in context: PlacementContext) -> _Placement {
        let sizeAndSpacingContext = SizeAndSpacingContext(context)
        let effectiveInsets = effectiveInsets(in: sizeAndSpacingContext)
        let newProposal = context.proposedSize.inset(by: effectiveInsets)
        return _Placement(proposedSize: newProposal, at: .init(effectiveInsets.originOffset))
    }

    package func sizeThatFits(in proposedSize: _ProposedSize, context: SizeAndSpacingContext, child: LayoutProxy) -> CGSize {
        let effectiveInsets = effectiveInsets(in: context)
        let newProposal = proposedSize.inset(by: effectiveInsets)
        let size = child.size(in: newProposal)
        return size.outset(by: effectiveInsets)
    }

    package func ignoresAutomaticPadding(child: LayoutProxy) -> Bool {
        true
    }

    package func spacing(in context: SizeAndSpacingContext, child: LayoutProxy) -> Spacing {
        if Semantics.NoSpacingProjectedPadding.isEnabled {
            var spacing = child.layoutComputer.spacing()
            let effectiveInsets = effectiveInsets(in: context)
            var edgeSet = Edge.Set()
            if effectiveInsets.top != 0 {
                edgeSet.insert(.top)
            }
            if effectiveInsets.leading != 0 {
                edgeSet.insert(.leading)
            }
            if effectiveInsets.bottom != 0 {
                edgeSet.insert(.bottom)
            }
            if effectiveInsets.trailing != 0 {
                edgeSet.insert(.trailing)
            }
            if Semantics.StopProjectingAffectedSpacing.isEnabled {
                spacing.reset(.init(edgeSet, layoutDirection: context.layoutDirection))
            } else {
                if !edgeSet.isEmpty {
                    spacing.reset(.init(edgeSet, layoutDirection: context.layoutDirection))
                }
            }
            return spacing
        } else {
            return child.layoutComputer.spacing()
        }
    }

    private func effectiveInsets(in context: SizeAndSpacingContext) -> EdgeInsets {
        (insets ?? context.defaultPadding).in(edges)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Adds a different padding amount to each edge of this view.
    ///
    /// Use this modifier to add a different amount of padding on each edge
    /// of a view:
    ///
    ///     VStack {
    ///         Text("Text padded by different amounts on each edge.")
    ///             .padding(EdgeInsets(top: 10, leading: 20, bottom: 40, trailing: 0))
    ///             .border(.gray)
    ///         Text("Unpadded text for comparison.")
    ///             .border(.yellow)
    ///     }
    ///
    /// The order in which you apply modifiers matters. The example above
    /// applies the padding before applying the border to ensure that the
    /// border encompasses the padded region:
    ///
    /// ![A screenshot of two text strings arranged vertically, each surrounded
    /// by a border, with a small space between the two borders.
    /// The first string says Text padded by different amounts on each edge.
    /// Its border is gray, and there are different amounts of space between
    /// the string and its border on each edge: 40 points on the bottom, 10
    /// points on the top, 20 points on the leading edge, and no space on
    /// the trailing edge.
    /// The second string says Unpadded text for comparison.
    /// Its border is yellow, and there's no space between the string
    /// and its border.](View-padding-3-iOS)
    ///
    /// To pad a view on specific edges with equal padding for all padded
    /// edges, use ``View/padding(_:_:)``. To pad all edges of a view
    /// equally, use ``View/padding(_:)``.
    ///
    /// - Parameter insets: An ``EdgeInsets`` instance that contains
    ///   padding amounts for each edge.
    ///
    /// - Returns: A view that's padded by different amounts on each edge.
    @inlinable
    nonisolated public func padding(_ insets: EdgeInsets) -> some View {
        modifier(_PaddingLayout(insets: insets))
    }

    /// Adds an equal padding amount to specific edges of this view.
    ///
    /// Use this modifier to add a specified amount of padding to one or more
    /// edges of the view. Indicate the edges to pad by naming either a single
    /// value from ``Edge/Set``, or by specifying an
    /// [OptionSet](https://developer.apple.com/documentation/Swift/OptionSet)
    /// that contains edge values:
    ///
    ///     VStack {
    ///         Text("Text padded by 20 points on the bottom and trailing edges.")
    ///             .padding([.bottom, .trailing], 20)
    ///             .border(.gray)
    ///         Text("Unpadded text for comparison.")
    ///             .border(.yellow)
    ///     }
    ///
    /// The order in which you apply modifiers matters. The example above
    /// applies the padding before applying the border to ensure that the
    /// border encompasses the padded region:
    ///
    /// ![A screenshot of two text strings arranged vertically, each surrounded
    /// by a border, with a small space between the two borders.
    /// The first string says Text padded by 20 points
    /// on the bottom and trailing edges.
    /// Its border is gray, and there are 20 points of space between the bottom
    /// and trailing edges of the string and its border.
    /// There's no space between the string and the border on the other edges.
    /// The second string says Unpadded text for comparison.
    /// Its border is yellow, and there's no space between the string
    /// and its border.](View-padding-2-iOS)
    ///
    /// You can omit either or both of the parameters. If you omit the `length`,
    /// OpenSwiftUI uses a default amount of padding. If you
    /// omit the `edges`, OpenSwiftUI applies the padding to all edges. Omit both
    /// to add a default padding all the way around a view. OpenSwiftUI chooses a
    /// default amount of padding that's appropriate for the platform and
    /// the presentation context.
    ///
    ///     VStack {
    ///         Text("Text with default padding.")
    ///             .padding()
    ///             .border(.gray)
    ///         Text("Unpadded text for comparison.")
    ///             .border(.yellow)
    ///     }
    ///
    /// The example above looks like this in iOS under typical conditions:
    ///
    /// ![A screenshot of two text strings arranged vertically, each surrounded
    /// by a border, with a small space between the two borders.
    /// The first string says Text with default padding.
    /// Its border is gray, and there is padding on all sides
    /// between the border and the string it encloses in an amount that's
    /// similar to the height of the text.
    /// The second string says Unpadded text for comparison.
    /// Its border is yellow, and there's no space between the string
    /// and its border.](View-padding-2a-iOS)
    ///
    /// To control the amount of padding independently for each edge, use
    /// ``View/padding(_:)-6pgqq``. To pad all outside edges of a view by a
    /// specified amount, use ``View/padding(_:)-68shk``.
    ///
    /// - Parameters:
    ///   - edges: The set of edges to pad for this view. The default
    ///     is ``Edge/Set/all``.
    ///   - length: An amount, given in points, to pad this view on the
    ///     specified edges. If you set the value to `nil`, OpenSwiftUI uses
    ///     a platform-specific default amount. The default value of this
    ///     parameter is `nil`.
    ///
    /// - Returns: A view that's padded by the specified amount on the
    ///   specified edges.
    @inlinable
    nonisolated public func padding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        let insets = length.map { EdgeInsets(_all: $0) }
        return modifier(_PaddingLayout(edges: edges, insets: insets))
    }

    /// Adds a specific padding amount to each edge of this view.
    ///
    /// Use this modifier to add padding all the way around a view.
    ///
    ///     VStack {
    ///         Text("Text padded by 10 points on each edge.")
    ///             .padding(10)
    ///             .border(.gray)
    ///         Text("Unpadded text for comparison.")
    ///             .border(.yellow)
    ///     }
    ///
    /// The order in which you apply modifiers matters. The example above
    /// applies the padding before applying the border to ensure that the
    /// border encompasses the padded region:
    ///
    /// ![A screenshot of two text strings arranged vertically, each surrounded
    /// by a border, with a small space between the two borders.
    /// The first string says Text padded by 10 points on each edge.
    /// Its border is gray, and there are 10 points of space on all sides
    /// between the string and its border.
    /// The second string says Unpadded text for comparison.
    /// Its border is yellow, and there's no space between the string
    /// and its border.](View-padding-1-iOS)
    ///
    /// To independently control the amount of padding for each edge, use
    /// ``View/padding(_:)-6pgqq``. To pad a select set of edges by the
    /// same amount, use ``View/padding(_:_:)``.
    ///
    /// - Parameter length: The amount, given in points, to pad this view on all
    ///   edges.
    ///
    /// - Returns: A view that's padded by the amount you specify.
    @inlinable
    nonisolated public func padding(_ length: CGFloat) -> some View {
        padding(.all, length)
    }

    /// Pads this view along all edges by an amount that is tighter than the
    /// usual default value.
    @available(OpenSwiftUI_v2_0, *)
    public func _tightPadding() -> some View {
        padding(8.0)
    }
}
