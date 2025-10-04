//
//  PositionLayout.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID:  (SwiftUI)

public import Foundation

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - PositionLayout

@frozen
public struct _PositionLayout: UnaryLayout {
    public var position: CGPoint
    
    @inlinable
    public init(position: CGPoint) {
        self.position = position
    }

    package func sizeThatFits(
        in proposal: _ProposedSize,
        context: SizeAndSpacingContext,
        child: LayoutProxy
    ) -> CGSize {
        CGSize(proposal) ?? proposal.fixingUnspecifiedDimensions(at: child.size(in: proposal))
    }
    
    package func spacing(in: SizeAndSpacingContext, child: LayoutProxy) -> Spacing {
        if Semantics.StopProjectingAffectedSpacing.isEnabled {
            return Spacing()
        }
        return child.spacing()
    }

    package func placement(of: LayoutProxy, in context: PlacementContext) -> _Placement {
        _Placement(proposedSize: context.size, anchoring: .center, at: position)
    }
}

extension View {
    /// Positions the center of this view at the specified point in its parent's
    /// coordinate space.
    ///
    /// Use the `position(_:)` modifier to place the center of a view at a
    /// specific coordinate in the parent view using a
    /// <doc://com.apple.documentation/documentation/CoreFoundation/CGPoint> to specify the `x`
    /// and `y` offset.
    ///
    ///     Text("Position by passing a CGPoint()")
    ///         .position(CGPoint(x: 175, y: 100))
    ///         .border(Color.gray)
    ///
    /// - Parameter position: The point at which to place the center of this
    ///   view.
    ///
    /// - Returns: A view that fixes the center of this view at `position`.

    @inlinable
    nonisolated public func position(_ position: CGPoint) -> some View {
        modifier(_PositionLayout(position: position))
    }

    /// Positions the center of this view at the specified coordinates in its
    /// parent's coordinate space.
    ///
    /// Use the `position(x:y:)` modifier to place the center of a view at a
    /// specific coordinate in the parent view using an `x` and `y` offset.
    ///
    ///     Text("Position by passing the x and y coordinates")
    ///         .position(x: 175, y: 100)
    ///         .border(Color.gray)
    ///
    /// - Parameters:
    ///   - x: The x-coordinate at which to place the center of this view.
    ///   - y: The y-coordinate at which to place the center of this view.
    ///
    /// - Returns: A view that fixes the center of this view at `x` and `y`.

    @inlinable
    nonisolated public func position(x: CGFloat = 0, y: CGFloat = 0) -> some View {
        position(.init(x: x, y: y))
    }
}
