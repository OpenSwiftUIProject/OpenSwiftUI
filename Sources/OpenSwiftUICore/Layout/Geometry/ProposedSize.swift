//
//  ProposedSize.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

package import Foundation

/// A size proposal that can have specified or unspecified dimensions.
///
/// A proposed size is used in the layout system to communicate size constraints
/// to views and layout containers. Either dimension can be specified with a concrete
/// value or left unspecified (nil), allowing the receiver to choose its own size
/// for that dimension.
public struct _ProposedSize {
    /// The proposed width, or `nil` if unspecified.
    package var width: CGFloat?

    /// The proposed height, or `nil` if unspecified.
    package var height: CGFloat?
    
    /// Creates a proposed size with optional width and height values.
    ///
    /// - Parameters:
    ///   - width: The proposed width, or `nil` if unspecified.
    ///   - height: The proposed height, or `nil` if unspecified.
    package init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
    }
    
    /// Creates a proposed size with both dimensions unspecified.
    package init() {
        self.width = nil
        self.height = nil
    }
    
    /// Converts to a concrete `CGSize` by replacing unspecified dimensions with the provided defaults.
    ///
    /// - Parameter defaults: The default size to use for unspecified dimensions.
    /// - Returns: A `CGSize` with concrete values for both dimensions.
    package func fixingUnspecifiedDimensions(at defaults: CGSize) -> CGSize {
        CGSize(width: width ?? defaults.width, height: height ?? defaults.height)
    }
    
    /// Converts to a concrete `CGSize` by replacing unspecified dimensions with a default value of 10.0.
    ///
    /// - Returns: A `CGSize` with concrete values for both dimensions.
    package func fixingUnspecifiedDimensions() -> CGSize {
        CGSize(width: width ?? 10.0, height: height ?? 10.0)
    }
    
    /// Creates a new proposed size by scaling both dimensions by the given factor.
    ///
    /// - Parameter s: The scale factor to apply.
    /// - Returns: A new proposed size with scaled dimensions.
    package func scaled(by s: CGFloat) -> _ProposedSize {
        _ProposedSize(width: width.map { $0 * s }, height: height.map { $0 * s })
    }
    
    /// A proposed size with both dimensions set to zero.
    package static let zero = _ProposedSize(width: 0, height: 0)

    /// A proposed size with both dimensions set to infinity.
    package static let infinity = _ProposedSize(width: .infinity, height: .infinity)

    /// A proposed size with both dimensions unspecified.
    package static let unspecified = _ProposedSize(width: nil, height: nil)
}

@available(*, unavailable)
extension _ProposedSize: Sendable {}

extension _ProposedSize: Hashable {}

extension _ProposedSize {
    /// Creates a proposed size from a concrete `CGSize`.
    ///
    /// - Parameter s: The concrete size to convert.
    package init(_ s: CGSize) {
        width = s.width
        height = s.height
    }
}

extension CGSize {
    /// Creates a `CGSize` from a proposed size if both dimensions are specified.
    ///
    /// - Parameter p: The proposed size to convert.
    /// - Returns: A `CGSize` if both dimensions are specified, or `nil` otherwise.
    package init?(_ p: _ProposedSize) {
        guard let width = p.width, let height = p.height else { return nil }
        self.init(width: width, height: height)
    }
}

extension _ProposedSize {
    /// Creates a new proposed size by reducing both dimensions by the specified edge insets.
    ///
    /// - Parameter insets: The edge insets to apply.
    /// - Returns: A new proposed size with insets applied.
    package func inset(by insets: EdgeInsets) -> _ProposedSize {
        _ProposedSize(
            width: width.map { max(0, $0 - insets.horizontal) },
            height: height.map { max(0, $0 - insets.vertical) }
        )
    }
    
    /// Accesses the dimension specified by the given axis.
    ///
    /// - Parameter axis: The axis to access (.horizontal for width, .vertical for height).
    /// - Returns: The dimension for the specified axis.
    package subscript(axis: Axis) -> CGFloat? {
        get { axis == .horizontal ? width : height }
        set { if axis == .horizontal { width = newValue } else { height = newValue } }
    }
    
    /// Creates a proposed size by assigning dimensions based on the specified axis.
    ///
    /// - Parameters:
    ///   - l1: The dimension for the first axis.
    ///   - first: The first axis (.horizontal or .vertical).
    ///   - l2: The dimension for the second axis.
    /// - Returns: A new proposed size with dimensions assigned according to the axes.
    package init(_ l1: CGFloat?, in first: Axis, by l2: CGFloat?) {
        self = first == .horizontal ? _ProposedSize(width: l1, height: l2) : _ProposedSize(width: l2, height: l1)
    }
}
