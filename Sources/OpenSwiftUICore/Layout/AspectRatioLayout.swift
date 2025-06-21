//
//  AspectRatioLayout.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: 16C39F04401F65ECECDD878223AA3E56

public import Foundation

// MARK: - ContentMode [6.4.41]

/// Constants that define how a view's content fills the available space.
@available(OpenSwiftUI_v1_0, *)
@frozen
public enum ContentMode: Hashable, CaseIterable {
    /// An option that resizes the content so it's all within the available space,
    /// both vertically and horizontally.
    ///
    /// This mode preserves the content's aspect ratio.
    /// If the content doesn't have the same aspect ratio as the available
    /// space, the content becomes the same size as the available space on
    /// one axis and leaves empty space on the other.
    case fit

    /// An option that resizes the content so it occupies all available space,
    /// both vertically and horizontally.
    ///
    /// This mode preserves the content's aspect ratio.
    /// If the content doesn't have the same aspect ratio as the available
    /// space, the content becomes the same size as the available space on
    /// one axis, and larger on the other axis.
    case fill
}

// MARK: - AspectRatioLayout [6.4.41]

/// A layout that tries to situate its child so the child either fits or fills
/// the layout's frame, is centered, and maintains a given aspect ratio.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _AspectRatioLayout: UnaryLayout {
    /// The aspect ratio offered to the child, or `nil` to preserve the ratio
    /// of dimensions in `content`'s ideal size.
    public var aspectRatio: CGFloat?

    public var contentMode: ContentMode

    @inlinable
    public init(
        aspectRatio: CGFloat? = nil,
        contentMode: ContentMode
    ) {
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
    }

    package func placement(of child: LayoutProxy, in context: PlacementContext) -> _Placement {
        _Placement(
            proposedSize: spaceOffered(to: child, in: context.proposedSize),
            aligning: .center,
            in: context.size
        )
    }

    package func sizeThatFits(in proposedSize: _ProposedSize, context: SizeAndSpacingContext, child: LayoutProxy) -> CGSize {
        child.size(in: spaceOffered(to: child, in: proposedSize))
    }

    private func spaceOffered(to child: LayoutProxy, in proposedSize: _ProposedSize) -> _ProposedSize {
        guard proposedSize != .unspecified else {
            return proposedSize
        }
        let size: CGSize = if let aspectRatio {
            CGSize(width: aspectRatio, height: 1.0)
        } else {
            child.size(in: .unspecified)
        }
        let ratioSize = if size.width == size.height {
            CGSize(width: 1.0, height: 1.0)
        } else {
            size
        }
        let scaledSize = switch contentMode {
        case .fit: ratioSize.scaledToFit(proposedSize)
        case .fill: ratioSize.scaledToFill(proposedSize)
        }
        return _ProposedSize(scaledSize)
    }
}

// MARK: - View + aspectRatio [6.4.41]

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Constrains this view's dimensions to the specified aspect ratio.
    ///
    /// Use `aspectRatio(_:contentMode:)` to constrain a view's dimensions to an
    /// aspect ratio specified by a
    /// [CGFloat](https://developer.apple.com/documentation/CoreFoundation/CGFloat)
    /// using the specified content mode.
    ///
    /// If this view is resizable, the resulting view will have `aspectRatio` as
    /// its aspect ratio. In this example, the purple ellipse has a 3:4
    /// width-to-height ratio, and scales to fit its frame:
    ///
    ///     Ellipse()
    ///         .fill(Color.purple)
    ///         .aspectRatio(0.75, contentMode: .fit)
    ///         .frame(width: 200, height: 200)
    ///         .border(Color(white: 0.75))
    ///
    /// ![A view showing a purple ellipse that has a 3:4 width-to-height ratio,
    /// and scales to fit its frame.](OpenSwiftUI-View-aspectRatio-cgfloat.png)
    ///
    /// - Parameters:
    ///   - aspectRatio: The ratio of width to height to use for the resulting
    ///     view. Use `nil` to maintain the current aspect ratio in the
    ///     resulting view.
    ///   - contentMode: A flag that indicates whether this view fits or fills
    ///     the parent context.
    ///
    /// - Returns: A view that constrains this view's dimensions to the aspect
    ///   ratio of the given size using `contentMode` as its scaling algorithm.
    @inlinable
    nonisolated public func aspectRatio(
        _ aspectRatio: CGFloat? = nil,
        contentMode: ContentMode
    ) -> some View {
        modifier(_AspectRatioLayout(
            aspectRatio: aspectRatio,
            contentMode: contentMode
        ))
    }

    /// Constrains this view's dimensions to the aspect ratio of the given size.
    ///
    /// Use `aspectRatio(_:contentMode:)` to constrain a view's dimensions to
    /// an aspect ratio specified by a
    /// [CGSize](https://developer.apple.com/documentation/CoreFoundation/CGSize)
    ///
    /// If this view is resizable, the resulting view uses `aspectRatio` as its
    /// own aspect ratio. In this example, the purple ellipse has a 3:4
    /// width-to-height ratio, and scales to fill its frame:
    ///
    ///     Ellipse()
    ///         .fill(Color.purple)
    ///         .aspectRatio(CGSize(width: 3, height: 4), contentMode: .fill)
    ///         .frame(width: 200, height: 200)
    ///         .border(Color(white: 0.75))
    ///
    /// ![A view showing a purple ellipse that has a 3:4 width-to-height ratio,
    /// and scales to fill its frame.](OpenSwiftUI-View-aspectRatio.png)
    ///
    /// - Parameters:
    ///   - aspectRatio: A size that specifies the ratio of width to height to
    ///     use for the resulting view.
    ///   - contentMode: A flag indicating whether this view should fit or fill
    ///     the parent context.
    ///
    /// - Returns: A view that constrains this view's dimensions to
    ///   `aspectRatio`, using `contentMode` as its scaling algorithm.
    @inlinable
    nonisolated public func aspectRatio(
        _ aspectRatio: CGSize,
        contentMode: ContentMode
    ) -> some View {
        self.aspectRatio(
            aspectRatio.width / aspectRatio.height,
            contentMode: contentMode
        )
    }

    /// Scales this view to fit its parent.
    ///
    /// Use `scaledToFit()` to scale this view to fit its parent, while
    /// maintaining the view's aspect ratio as the view scales.
    ///
    ///     Circle()
    ///         .fill(Color.pink)
    ///         .scaledToFit()
    ///         .frame(width: 300, height: 150)
    ///         .border(Color(white: 0.75))
    ///
    /// ![A screenshot of pink circle scaled to fit its
    /// frame.](OpenSwiftUI-View-scaledToFit-1.png)
    ///
    /// This method is equivalent to calling
    /// ``View/aspectRatio(_:contentMode:)`` with a `nil` aspectRatio and
    /// a content mode of ``ContentMode/fit``.
    ///
    /// - Returns: A view that scales this view to fit its parent, maintaining
    ///   this view's aspect ratio.
    @inlinable
    nonisolated public func scaledToFit() -> some View {
        aspectRatio(contentMode: .fit)
    }

    /// Scales this view to fill its parent.
    ///
    /// Use `scaledToFill()` to scale this view to fill its parent, while
    /// maintaining the view's aspect ratio as the view scales:
    ///
    ///     Circle()
    ///         .fill(Color.pink)
    ///         .scaledToFill()
    ///         .frame(width: 300, height: 150)
    ///         .border(Color(white: 0.75))
    ///
    /// ![A screenshot of pink circle scaled to fill its
    /// frame.](OpenSwiftUI-View-scaledToFill-1.png)
    ///
    /// This method is equivalent to calling
    /// ``View/aspectRatio(_:contentMode:)`` with a `nil` aspectRatio and
    /// a content mode of ``ContentMode/fill``.
    ///
    /// - Returns: A view that scales this view to fill its parent, maintaining
    ///   this view's aspect ratio.
    @inlinable
    nonisolated public func scaledToFill() -> some View {
        aspectRatio(contentMode: .fill)
    }
}

// MARK: - CGSize + ContentMode [6.4.41]

extension CGSize {
    package func scaleThatFits(_ target: _ProposedSize) -> CGFloat {
        let scaleX = if let targetWidth = target.width, (width != 0 || targetWidth != 0) {
            targetWidth / width
        } else {
            CGFloat.infinity
        }
        let scaleY = if let targetHeight = target.height, (height != 0 || targetHeight != 0) {
            targetHeight / height
        } else {
            CGFloat.infinity
        }
        return min(scaleX, scaleY)
    }

    package func scaleThatFills(_ target: _ProposedSize) -> CGFloat {
        let scaleX = if let targetWidth = target.width, (width != 0 || targetWidth != 0) {
            targetWidth / width
        } else {
            CGFloat.infinity
        }
        let scaleY = if let targetHeight = target.height, (height != 0 || targetHeight != 0) {
            targetHeight / height
        } else {
            CGFloat.infinity
        }
        return max(scaleX, scaleY)
    }

    package func scaledToFit(_ target: _ProposedSize) -> CGSize {
        self * scaleThatFits(target)
    }

    package func scaledToFill(_ target: _ProposedSize) -> CGSize {
       self * scaleThatFills(target)
    }

    package func centeredIn(_ size: CGSize) -> CGRect {
        centeredIn(CGRect(origin: .zero, size: size))
    }

    package func centeredIn(_ rect: CGRect) -> CGRect {
        CGRect(
            origin: (rect.size - self) / 2 + rect.origin,
            size: self
        )
    }
}
