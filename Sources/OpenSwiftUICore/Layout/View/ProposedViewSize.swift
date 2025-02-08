//
//  ProposedViewSize.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public import Foundation
#if canImport(Darwin)
public import CoreGraphics
#endif

/// A proposal for the size of a view.
///
/// During layout in OpenSwiftUI, views choose their own size, but they do that
/// in response to a size proposal from their parent view. When you create
/// a custom layout using the ``Layout`` protocol, your layout container
/// participates in this process using `ProposedViewSize` instances.
/// The layout protocol's methods take a proposed size input that you
/// can take into account when arranging views and calculating the size of
/// the composite container. Similarly, your layout proposes a size to each
/// of its own subviews when it measures and places them.
///
/// Layout containers typically measure their subviews by proposing several
/// sizes and looking at the responses. The container can use this information
/// to decide how to allocate space among its subviews. A
/// layout might try the following special proposals:
///
/// * The ``zero`` proposal; the view responds with its minimum size.
/// * The ``infinity`` proposal; the view responds with its maximum size.
/// * The ``unspecified`` proposal; the view responds with its ideal size.
///
/// A layout might also try special cases for one dimension at a time. For
/// example, an ``HStack`` might measure the flexibility of its subviews'
/// widths, while using a fixed value for the height.
@frozen
public struct ProposedViewSize: Equatable {
    /// The proposed horizontal size measured in points.
    ///
    /// A value of `nil` represents an unspecified width proposal, which a view
    /// interprets to mean that it should use its ideal width.
    public var width: CGFloat?
    
    /// The proposed vertical size measured in points.
    ///
    /// A value of `nil` represents an unspecified height proposal, which a view
    /// interprets to mean that it should use its ideal height.
    public var height: CGFloat?
    
    /// A size proposal that contains zero in both dimensions.
    ///
    /// Subviews of a custom layout return their minimum size when you propose
    /// this value using the ``LayoutSubview/dimensions(in:)`` method.
    /// A custom layout should also return its minimum size from the
    /// ``Layout/sizeThatFits(proposal:subviews:cache:)`` method for this
    /// value.
    public static let zero: ProposedViewSize = .init(width: .zero, height: .zero)
    
    /// The proposed size with both dimensions left unspecified.
    ///
    /// Both dimensions contain `nil` in this size proposal.
    /// Subviews of a custom layout return their ideal size when you propose
    /// this value using the ``LayoutSubview/dimensions(in:)`` method.
    /// A custom layout should also return its ideal size from the
    /// ``Layout/sizeThatFits(proposal:subviews:cache:)`` method for this
    /// value.
    public static let unspecified: ProposedViewSize = .init(width: nil, height: nil)
    
    /// A size proposal that contains infinity in both dimensions.
    ///
    /// Both dimensions contain
    /// [infinity](https://developer.apple.com/documentation/CoreFoundation/CGFloat/1454161-infinity)
    /// in this size proposal.
    /// Subviews of a custom layout return their maximum size when you propose
    /// this value using the ``LayoutSubview/dimensions(in:)`` method.
    /// A custom layout should also return its maximum size from the
    /// ``Layout/sizeThatFits(proposal:subviews:cache:)`` method for this
    /// value.
    public static let infinity: ProposedViewSize = .init(width: .infinity, height: .infinity)
    
    /// Creates a new proposed size using the specified width and height.
    ///
    /// - Parameters:
    ///   - width: A proposed width in points. Use a value of `nil` to indicate
    ///     that the width is unspecified for this proposal.
    ///   - height: A proposed height in points. Use a value of `nil` to
    ///     indicate that the height is unspecified for this proposal.
    @inlinable
    public init(width: CGFloat?, height: CGFloat?) {
        (self.width, self.height) = (width, height)
    }
    
    package init(_ proposal: _ProposedSize) {
        width = proposal.width
        height = proposal.height
    }
    
    /// Creates a new proposed size from a specified size.
    ///
    /// - Parameter size: A proposed size with dimensions measured in points.
    @inlinable
    public init(_ size: CGSize) {
        self.init(width: size.width, height: size.height)
    }
    
    /// Creates a new proposal that replaces unspecified dimensions in this
    /// proposal with the corresponding dimension of the specified size.
    ///
    /// Use the default value to prevent a flexible view from disappearing
    /// into a zero-sized frame, and ensure the unspecified value remains
    /// visible during debugging.
    ///
    /// - Parameter size: A set of concrete values to use for the size proposal
    ///   in place of any unspecified dimensions. The default value is `10`
    ///   for both dimensions.
    ///
    /// - Returns: A new, fully specified size proposal.
    @inlinable
    public func replacingUnspecifiedDimensions(by size: CGSize = CGSize(width: 10, height: 10)) -> CGSize {
        CGSize(width: width ?? size.width, height: height ?? size.height)
    }
    
    package init(_ major: CGFloat?, in axis: Axis, by minor: CGFloat?) {
        self = axis == .horizontal ? ProposedViewSize(width: major, height: minor) : ProposedViewSize(width: minor, height: major)
    }
    
    package subscript(axis: Axis) -> CGFloat? {
        get { axis == .horizontal ? width : height }
        set { if axis == .horizontal { width = newValue } else { height = newValue } }
    }
}

extension _ProposedSize {
    package init(_ p: ProposedViewSize) {
        self.init(width: p.width, height: p.height)
    }
}
