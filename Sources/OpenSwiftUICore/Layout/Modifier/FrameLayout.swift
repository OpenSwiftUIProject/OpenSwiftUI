//
//  FrameLayout.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: 73C64038119BBD0A6D8557B14379A404 (SwiftUICore)

public import Foundation

// MARK: - FrameLayoutCommon [6.4.41] [WIP]

private protocol FrameLayoutCommon {
    func commonPlacement(of child: LayoutProxy, in context: PlacementContext, childProposal: _ProposedSize) -> _Placement
}

extension FrameLayoutCommon {
    func commonPlacement(of child: LayoutProxy, in context: PlacementContext, childProposal: _ProposedSize) -> _Placement {
        preconditionFailure("TODO")
    }
}

// MARK: - FrameLayout [6.4.41]

/// A modifier that centers its child in an invisible frame with one or two
/// fixed dimensions.
@frozen
public struct _FrameLayout: UnaryLayout, FrameLayoutCommon {
    let width: CGFloat?

    let height: CGFloat?

    let alignment: Alignment

    @usableFromInline
    package init(width: CGFloat?, height: CGFloat?, alignment: Alignment) {
        if isLinkedOnOrAfter(.v2) {
            let isWidthInvalid: Bool = if let width, width < 0 || !width.isFinite { true } else { false }
            let isHeightInvalid: Bool = if let width, width < 0 || !width.isFinite { true } else { false }
            if isWidthInvalid || isHeightInvalid {
                Log.runtimeIssues("Invalid frame dimension (negative or non-finite).")
            }
            self.width = isWidthInvalid ? nil : width
            self.height = isHeightInvalid ? nil : height
            self.alignment = alignment
        } else {
            self.width = width
            self.height = height
            self.alignment = alignment
        }
    }

    package func sizeThatFits(in proposedSize: _ProposedSize, context: SizeAndSpacingContext, child: LayoutProxy) -> CGSize {
        if let width, let height {
            return CGSize(width: width, height: height)
        }
        let size = child.size(in: _ProposedSize(width: width ?? proposedSize.width, height: height ?? proposedSize.height))
        return CGSize(width: width ?? size.width, height: height ?? size.height)
    }

    package func placement(of child: LayoutProxy, in context: PlacementContext) -> _Placement {
        var proposal = context.proposedSize
        if let width {
            proposal.width = width
        }
        if let height {
            proposal.height = height
        }
        return commonPlacement(of: child, in: context, childProposal: proposal)
    }

    package func spacing(in context: SizeAndSpacingContext, child: LayoutProxy) -> Spacing {
        if _SemanticFeature_v3.isEnabled, !child.requiresSpacingProjection {
            var spacing = child.layoutComputer.spacing()
            var edges: Edge.Set = []
            if height != nil {
                edges.formUnion(.vertical)
            }
            if width != nil {
                edges.formUnion(.horizontal)
            }
            spacing.reset(.init(edges, layoutDirection: context.layoutDirection))
            return spacing
        } else {
            return child.layoutComputer.spacing()
        }
    }
}

extension View {
    /// Positions this view within an invisible frame with the specified size.
    ///
    /// Use this method to specify a fixed size for a view's width, height, or
    /// both. If you only specify one of the dimensions, the resulting view
    /// assumes this view's sizing behavior in the other dimension.
    ///
    /// For example, the following code lays out an ellipse in a fixed 200 by
    /// 100 frame. Because a shape always occupies the space offered to it by
    /// the layout system, the first ellipse is 200x100 points. The second
    /// ellipse is laid out in a frame with only a fixed height, so it occupies
    /// that height, and whatever width the layout system offers to its parent.
    ///
    ///     VStack {
    ///         Ellipse()
    ///             .fill(Color.purple)
    ///             .frame(width: 200, height: 100)
    ///         Ellipse()
    ///             .fill(Color.blue)
    ///             .frame(height: 100)
    ///     }
    ///
    /// ![A screenshot showing the effect of frame size options: a purple
    /// ellipse shows the effect of a fixed frame size, while a blue ellipse
    /// shows the effect of constraining a view in one
    /// dimension.](OpenSwiftUI-View-frame-1.png)
    ///
    /// `The alignment` parameter specifies this view's alignment within the
    /// frame.
    ///
    ///     Text("Hello world!")
    ///         .frame(width: 200, height: 30, alignment: .topLeading)
    ///         .border(Color.gray)
    ///
    /// In the example above, the text is positioned at the top, leading corner
    /// of the frame. If the text is taller than the frame, its bounds may
    /// extend beyond the bottom of the frame's bounds.
    ///
    /// ![A screenshot showing the effect of frame size options on a text view
    /// showing a fixed frame size with a specified
    /// alignment.](OpenSwiftUI-View-frame-2.png)
    ///
    /// - Parameters:
    ///   - width: A fixed width for the resulting view. If `width` is `nil`,
    ///     the resulting view assumes this view's sizing behavior.
    ///   - height: A fixed height for the resulting view. If `height` is `nil`,
    ///     the resulting view assumes this view's sizing behavior.
    ///   - alignment: The alignment of this view inside the resulting frame.
    ///     Note that most alignment values have no apparent effect when the
    ///     size of the frame happens to match that of this view.
    ///
    /// - Returns: A view with fixed dimensions of `width` and `height`, for the
    ///   parameters that are non-`nil`.
    @inlinable
    nonisolated
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        return modifier(
            _FrameLayout(width: width, height: height, alignment: alignment)
        )
    }


    /// Positions this view within an invisible frame.
    ///
    /// Use ``View/frame(width:height:alignment:)`` or
    /// ``View/frame(minWidth:idealWidth:maxWidth:minHeight:idealHeight:maxHeight:alignment:)``
    /// instead.
    @available(*, deprecated, message: "Please pass one or more parameters.")
    @inlinable
    nonisolated public func frame() -> some View {
        return frame(width: nil, height: nil, alignment: .center)
    }
}

// MARK: - FlexFrameLayout [6.4.41] [WIP]
