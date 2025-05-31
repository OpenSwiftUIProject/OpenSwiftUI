//
//  AlignmentLayout.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import Foundation

// MARK: - VAlignment [6.4.41]

/// An alignment in the vertical axis.
@frozen
public enum _VAlignment {
    case top
    case center
    case bottom

    package var value: CGFloat {
        switch self {
            case .top: 0.0
            case .center: 0.5
            case .bottom: 1.0
        }
    }
}

// MARK: - AlignmentLayout [6.4.41]

@frozen
public struct _AlignmentLayout: UnaryLayout {
    public var horizontal: TextAlignment?

    public var vertical: _VAlignment?

    @inlinable
    public init(
        horizontal: TextAlignment? = nil,
        vertical: _VAlignment? = nil
    ) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    package func placement(
        of child: LayoutProxy,
        in context: PlacementContext
    ) -> _Placement {
        _Placement(
            proposedSize: context.proposedSize,
            aligning: UnitPoint(x: (horizontal ?? .center).value, y: (vertical ?? .center).value),
            in: context.size
        )
    }

    package func sizeThatFits(
        in proposedSize: _ProposedSize,
        context: SizeAndSpacingContext,
        child: LayoutProxy
    ) -> CGSize {
        guard horizontal != nil,
              vertical != nil,
              let width = proposedSize.width,
              let height = proposedSize.height else {
            let childSize = child.size(in: proposedSize)
            let width = if horizontal != nil, let width = proposedSize.width {
                width
            } else {
                childSize.width
            }
            let height = if vertical != nil, let height = proposedSize.height {
                height
            } else {
                childSize.height
            }
            return CGSize(width: width, height: height)
        }
        return CGSize(width: width, height: height)
    }

    package func spacing(
        in context: SizeAndSpacingContext,
        child: LayoutProxy
    ) -> Spacing {
        if _SemanticFeature_v3.isEnabled {
            var spacing = child.layoutComputer.spacing()
            spacing.reset(
                AbsoluteEdge.Set(
                    [horizontal == nil ? [] : .horizontal, vertical == nil ? [] : .vertical],
                    layoutDirection: context.layoutDirection
                )
            )
            return spacing
        } else {
            return child.layoutComputer.spacing()
        }
    }

    public typealias AnimatableData = EmptyAnimatableData

    public typealias Body = Never

    package typealias PlacementContextType = PlacementContext
}
