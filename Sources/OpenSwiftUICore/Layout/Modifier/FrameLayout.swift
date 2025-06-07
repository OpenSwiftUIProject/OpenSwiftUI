//
//  FrameLayout.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: 73C64038119BBD0A6D8557B14379A404 (SwiftUICore)

public import Foundation

// MARK: - FrameLayoutCommon [6.4.41]

private protocol FrameLayoutCommon {
    var alignment: Alignment { get }
}

extension FrameLayoutCommon {
    func commonPlacement(of child: LayoutProxy, in context: PlacementContext, childProposal: _ProposedSize) -> _Placement {
        let defaultDimensions = ViewDimensions(guideComputer: LayoutComputer.defaultValue, size: .fixed(context.size))
        let dimensions = child.dimensions(in: childProposal)

        let horizontalKey = alignment.horizontal.key
        let horizontalID = horizontalKey.id

        let verticalKey = alignment.vertical.key
        let verticalID = verticalKey.id

        let horizontalDefaultValue = horizontalID.defaultValue(in: defaultDimensions)
        let verticalDefaultValue = verticalID.defaultValue(in: defaultDimensions)

        let horizontalAlignmentValue = dimensions[horizontalKey]
        let verticalAlignmentValue = dimensions[verticalKey]

        let x = horizontalDefaultValue - horizontalAlignmentValue
        let y = verticalDefaultValue - verticalAlignmentValue

        return _Placement(
            proposedSize: childProposal,
            anchoring: .topLeading,
            at: CGPoint(x: x, y: y)
        )
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
    nonisolated public func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> some View {
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

// MARK: - FlexFrameLayout [6.4.41]

/// A modifier that aligns its child in an invisible, flexible frame with size
/// limits and ideal size properties.
@frozen
public struct _FlexFrameLayout: UnaryLayout, FrameLayoutCommon {
    let minWidth: CGFloat?
    let idealWidth: CGFloat?
    let maxWidth: CGFloat?
    let minHeight: CGFloat?
    let idealHeight: CGFloat?
    let maxHeight: CGFloat?
    let alignment: Alignment

    /// Creates an instance with the given properties.
    @usableFromInline
    package init(
        minWidth: CGFloat? = nil,
        idealWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        idealHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil,
        alignment: Alignment
    ) {
        let minW: CGFloat? = if let minWidth {
            max(minWidth, .zero)
        } else {
            nil
        }
        let ideaW: CGFloat? = if let idealWidth {
            max(minW ?? .zero, idealWidth)
        } else {
            nil
        }
        let maxW: CGFloat? = if let maxWidth {
            max(ideaW ?? .zero, maxWidth)
        } else {
            nil
        }
        let minH: CGFloat? = if let minHeight {
            max(minHeight, .zero)
        } else {
            nil
        }
        let ideaH: CGFloat? = if let idealHeight {
            max(minH ?? .zero, idealHeight)
        } else {
            nil
        }
        let maxH: CGFloat? = if let maxHeight {
            max(ideaH ?? .zero, maxHeight)
        } else {
            nil
        }
        let hasInvalidWidth = (minWidth ?? .zero) > (idealWidth ?? maxWidth ?? .infinity) ||
            (idealWidth ?? .zero) > (maxWidth ?? .infinity) ||
            (minWidth ?? .zero).isInfinite || (minWidth ?? .zero).isNaN

        let hasInvalidHeight = (minHeight ?? .zero) > (idealHeight ?? maxHeight ?? .infinity) ||
            (idealHeight ?? 0.0) > (maxHeight ?? .infinity) ||
            (minHeight ?? .zero).isInfinite || (minHeight ?? .zero).isNaN

        if (hasInvalidWidth || hasInvalidHeight) && isLinkedOnOrAfter(.v2) {
            Log.runtimeIssues("Invalid frame dimension (negative or non-finite).")
        }

        self.minWidth = minW
        self.idealWidth = ideaW
        self.maxWidth = maxW
        self.minHeight = minH
        self.idealHeight = ideaH
        self.maxHeight = maxH
        self.alignment = alignment
    }

    private func childProposal(myProposal: _ProposedSize) -> _ProposedSize {
        let width: CGFloat? = if let idealWidth {
            min(max(myProposal.width ?? idealWidth, minWidth ?? -.infinity), maxWidth ?? .infinity)
        } else {
            nil
        }
        let height: CGFloat? = if let idealHeight {
            min(max(myProposal.height ?? idealHeight, minHeight ?? -.infinity), maxHeight ?? .infinity)
        } else {
            nil
        }
        return _ProposedSize(width: width, height: height)
    }

    package func sizeThatFits(
        in proposedSize: _ProposedSize,
        context: SizeAndSpacingContext,
        child: LayoutProxy
    ) -> CGSize {
        let width: CGFloat? = if let width = proposedSize.width {
            if let minWidth, let maxWidth, minWidth <= maxWidth {
                min(max(width, minWidth), maxWidth)
            } else {
                nil
            }
        } else {
            idealWidth
        }
        let height: CGFloat? = if let height = proposedSize.height {
            if let minHeight, let maxHeight, minHeight <= maxHeight {
                min(max(height, minHeight), maxHeight)
            } else {
                nil
            }
        } else {
            idealHeight
        }
        guard let width, let height else {
            let childProposal = childProposal(myProposal: proposedSize)
            let size = child.size(in: childProposal)

            let finalWidth = if let width {
                width
            } else {
                switch (minWidth, maxWidth) {
                case let (minW?, maxW?) where minW <= maxW:
                    min(max(minW, size.width), maxW)
                case let (minW?, nil):
                    max(min(childProposal.width ?? .infinity, size.width), minW)
                case let (nil, maxW?):
                    min(max(childProposal.width ?? -.infinity, size.width), maxW)
                default:
                    size.width
                }
            }
            let finalHeight = if let height {
                height
            } else {
                switch (minHeight, maxHeight) {
                case let (minH?, maxH?) where minH <= maxH:
                    min(max(minH, size.height), maxH)
                case let (minH?, nil):
                    max(min(childProposal.height ?? .infinity, size.height), minH)
                case let (nil, maxH?):
                    min(max(childProposal.height ?? -.infinity, size.height), maxH)
                default:
                    size.height
                }
            }
            return CGSize(width: finalWidth, height: finalHeight)
        }
        return CGSize(width: width, height: height)
    }

    private func childPlacementProposal(of child: LayoutProxy, context: PlacementContext) -> _ProposedSize {
        func proposedDimension(
            _ axis: Axis,
            min: CGFloat? = nil,
            ideal: CGFloat? = nil,
            max: CGFloat? = nil
        ) -> CGFloat? {
            let value = context.size[axis]
            guard ideal == nil,
                  context.proposedSize[axis] == nil,
                  (min ?? -.infinity) < value, value < (max ?? .infinity)
            else {
                return value
            }
            return nil
        }
        return _ProposedSize(
            width: proposedDimension(.horizontal, min: minWidth, ideal: idealWidth, max: maxWidth),
            height: proposedDimension(.vertical, min: minHeight, ideal: idealHeight, max: maxHeight)
        )
    }

    package func placement(of child: LayoutProxy, in context: PlacementContext) -> _Placement {
        let childProposal = if Semantics.FlexFrameIdealSizing.isEnabled {
            childPlacementProposal(of: child, context: context)
        } else {
            _ProposedSize(context.size)
        }
        return commonPlacement(of: child, in: context, childProposal: childProposal)
    }

    package func spacing(in context: SizeAndSpacingContext, child: LayoutProxy) -> Spacing {
        if _SemanticFeature_v3.isEnabled, !child.requiresSpacingProjection {
            var spacing = child.layoutComputer.spacing()
            var edges: Edge.Set = []
            if minHeight != nil || idealHeight != nil || maxHeight != nil {
                edges.formUnion(.vertical)
            }
            if minWidth != nil || idealWidth != nil || maxWidth != nil {
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
    /// Positions this view within an invisible frame having the specified size
    /// constraints.
    ///
    /// Always specify at least one size characteristic when calling this
    /// method. Pass `nil` or leave out a characteristic to indicate that the
    /// frame should adopt this view's sizing behavior, constrained by the other
    /// non-`nil` arguments.
    ///
    /// The size proposed to this view is the size proposed to the frame,
    /// limited by any constraints specified, and with any ideal dimensions
    /// specified replacing any corresponding unspecified dimensions in the
    /// proposal.
    ///
    /// If no minimum or maximum constraint is specified in a given dimension,
    /// the frame adopts the sizing behavior of its child in that dimension. If
    /// both constraints are specified in a dimension, the frame unconditionally
    /// adopts the size proposed for it, clamped to the constraints. Otherwise,
    /// the size of the frame in either dimension is:
    ///
    /// - If a minimum constraint is specified and the size proposed for the
    ///   frame by the parent is less than the size of this view, the proposed
    ///   size, clamped to that minimum.
    /// - If a maximum constraint is specified and the size proposed for the
    ///   frame by the parent is greater than the size of this view, the
    ///   proposed size, clamped to that maximum.
    /// - Otherwise, the size of this view.
    ///
    /// - Parameters:
    ///   - minWidth: The minimum width of the resulting frame.
    ///   - idealWidth: The ideal width of the resulting frame.
    ///   - maxWidth: The maximum width of the resulting frame.
    ///   - minHeight: The minimum height of the resulting frame.
    ///   - idealHeight: The ideal height of the resulting frame.
    ///   - maxHeight: The maximum height of the resulting frame.
    ///   - alignment: The alignment of this view inside the resulting frame.
    ///     Note that most alignment values have no apparent effect when the
    ///     size of the frame happens to match that of this view.
    ///
    /// - Returns: A view with flexible dimensions given by the call's non-`nil`
    ///   parameters.
    @inlinable
    nonisolated public func frame(
        minWidth: CGFloat? = nil,
        idealWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        idealHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil,
        alignment: Alignment = .center
    ) -> some View {
        func areInNondecreasingOrder(
            _ min: CGFloat?, _ ideal: CGFloat?, _ max: CGFloat?
        ) -> Bool {
            let min = min ?? -.infinity
            let ideal = ideal ?? min
            let max = max ?? ideal
            return min <= ideal && ideal <= max
        }

        if !areInNondecreasingOrder(minWidth, idealWidth, maxWidth)
            || !areInNondecreasingOrder(minHeight, idealHeight, maxHeight)
        {
            Log.runtimeIssues("Contradictory frame constraints specified.")
        }

        return modifier(
            _FlexFrameLayout(
                minWidth: minWidth,
                idealWidth: idealWidth, maxWidth: maxWidth,
                minHeight: minHeight,
                idealHeight: idealHeight, maxHeight: maxHeight,
                alignment: alignment
            )
        )
    }
}
