//
//  FixedSizeLayout.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import Foundation

// MARK: - FixedSizeLayout [6.4.41]

/// A layout that offers its child the child's ideal width and/or height.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _FixedSizeLayout {
    /// Creates an instance that fixes size at its ideal in the specified axes.
    @inlinable
    public init(horizontal: Bool = true, vertical: Bool = true) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    @usableFromInline
    var horizontal: Bool

    @usableFromInline
    var vertical: Bool
}

extension _FixedSizeLayout: UnaryLayout {
    package func placement(
        of child: LayoutProxy,
        in context: PlacementContext
    ) -> _Placement {
        let proposedSize = context.proposedSize
        return _Placement(
            proposedSize: _ProposedSize(
                width: horizontal ? nil : proposedSize.width,
                height: vertical ? nil : proposedSize.height
            ),
            aligning: .center,
            in: context.size
        )
    }

    package func sizeThatFits(
        in proposedSize: _ProposedSize,
        context: SizeAndSpacingContext,
        child: LayoutProxy
    ) -> CGSize {
        child.size(in: _ProposedSize(
            width: horizontal ? nil : proposedSize.width,
            height: vertical ? nil : proposedSize.height)
        )
    }
}

// MARK: - View + fixedSize [6.4.41]

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Fixes this view at its ideal size in the specified dimensions.
    ///
    /// This function behaves like ``View/fixedSize()``, except with
    /// `fixedSize(horizontal:vertical:)` the fixing of the axes can be
    /// optionally specified in one or both dimensions. For example, if you
    /// horizontally fix a text view before wrapping it in the frame view,
    /// you're telling the text view to maintain its ideal _width_. The view
    /// calculates this to be the space needed to represent the entire string.
    ///
    ///     Text("A single line of text, too long to fit in a box.")
    ///         .fixedSize(horizontal: true, vertical: false)
    ///         .frame(width: 200, height: 200)
    ///         .border(Color.gray)
    ///
    /// This can result in the view exceeding the parent's bounds, which may or
    /// may not be the effect you want.
    ///
    /// ![A screenshot showing a text view exceeding the bounds of its
    /// parent.](OpenSwiftUI-View-fixedSize-3.png)
    ///
    /// - Parameters:
    ///   - horizontal: A Boolean value that indicates whether to fix the width
    ///     of the view.
    ///   - vertical: A Boolean value that indicates whether to fix the height
    ///     of the view.
    ///
    /// - Returns: A view that fixes this view at its ideal size in the
    ///   dimensions specified by `horizontal` and `vertical`.
    @inlinable
    nonisolated public func fixedSize(
        horizontal: Bool,
        vertical: Bool
    ) -> some View {
        modifier(_FixedSizeLayout(
            horizontal: horizontal,
            vertical: vertical)
        )
    }

    /// Fixes this view at its ideal size.
    ///
    /// During the layout of the view hierarchy, each view proposes a size to
    /// each child view it contains. If the child view doesn't need a fixed size
    /// it can accept and conform to the size offered by the parent.
    ///
    /// For example, a ``Text`` view placed in an explicitly sized frame wraps
    /// and truncates its string to remain within its parent's bounds:
    ///
    ///     Text("A single line of text, too long to fit in a box.")
    ///         .frame(width: 200, height: 200)
    ///         .border(Color.gray)
    ///
    /// ![A screenshot showing the text in a text view contained within its
    /// parent.](OpenSwiftUI-View-fixedSize-1.png)
    ///
    /// The `fixedSize()` modifier can be used to create a view that maintains
    /// the *ideal size* of its children both dimensions:
    ///
    ///     Text("A single line of text, too long to fit in a box.")
    ///         .fixedSize()
    ///         .frame(width: 200, height: 200)
    ///         .border(Color.gray)
    ///
    /// This can result in the view exceeding the parent's bounds, which may or
    /// may not be the effect you want.
    ///
    /// ![A screenshot showing a text view exceeding the bounds of its
    /// parent.](SwiftUI-View-fixedSize-2.png)
    ///
    /// You can think of `fixedSize()` as the creation of a *counter proposal*
    /// to the view size proposed to a view by its parent. The ideal size of a
    /// view, and the specific effects of `fixedSize()` depends on the
    /// particular view and how you have configured it.
    ///
    /// To create a view that fixes the view's size in either the horizontal or
    /// vertical dimensions, see ``View/fixedSize(horizontal:vertical:)``.
    ///
    /// - Returns: A view that fixes this view at its ideal size.
    @inlinable
    nonisolated public func fixedSize() -> some View {
        fixedSize(horizontal: true, vertical: true)
    }
}
