//
//  UnitPoint.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public import Foundation
#if canImport(Darwin)
import CoreGraphics
#endif

/// A normalized 2D point in a view's coordinate space.
///
/// Use a unit point to represent a location in a view without having to know
/// the view's rendered size. The point stores a value in each dimension that
/// indicates the fraction of the view's size in that dimension --- measured
/// from the view's origin --- where the point appears. For example, you can
/// create a unit point that represents the center of any view by using the
/// value `0.5` for each dimension:
///
///     let unitPoint = UnitPoint(x: 0.5, y: 0.5)
///
/// To project the unit point into the rendered view's coordinate space,
/// multiply each component of the unit point with the corresponding
/// component of the view's size:
///
///     let projectedPoint = CGPoint(
///         x: unitPoint.x * size.width,
///         y: unitPoint.y * size.height
///     )
///
/// You can perform this calculation yourself if you happen to know a view's
/// size, or if you want to use the unit point for some custom purpose, but
/// OpenSwiftUI typically does this for you to carry out operations that
/// you request, like when you:
///
/// * Transform a shape using a shape modifier. For example, to rotate a
///   shape with ``Shape/rotation(_:anchor:)``, you indicate an anchor point
///   that you want to rotate the shape around.
/// * Override the alignment of the view in a ``Grid`` cell using the
///   ``View/gridCellAnchor(_:)`` view modifier. The grid aligns the projection
///   of a unit point onto the view with the projection of the same unit point
///   onto the cell.
/// * Create a gradient that has a center, or start and stop points, relative
///   to the shape that you are styling. See the gradient methods in
///   ``ShapeStyle``.
///
/// You can create custom unit points with explicit values, like the example
/// above, or you can use one of the built-in unit points that OpenSwiftUI provides,
/// like ``zero``, ``center``, or ``topTrailing``. The built-in values
/// correspond to the alignment positions of the similarly named, built-in
/// ``Alignment`` types.
///
/// > Note: A unit point with one or more components outside the range `[0, 1]`
/// projects to a point outside of the view.
///
/// ### Layout direction
///
/// When a person configures their device to use a left-to-right language like
/// English, the system places the view's origin in its top-left corner,
/// with positive x toward the right and positive y toward the bottom of the
/// view. In a right-to-left environment, the origin moves to the upper-right
/// corner, and the positive x direction changes to be toward the left. You
/// don't typically need to do anything to handle this change, because OpenSwiftUI
/// applies the change to all aspects of the system. For example, see the
/// discussion about layout direction in ``HorizontalAlignment``.
///
/// It’s important to test your app for the different locales that you
/// distribute your app in. For more information about the localization process,
/// see [Localization](https://developer.apple.com/documentation/xcode/localization)
@frozen
public struct UnitPoint: Hashable {
    /// The normalized distance from the origin to the point in the horizontal
    /// direction.
    public var x: CGFloat
    
    /// The normalized distance from the origin to the point in the vertical
    /// dimension.
    public var y: CGFloat
    
    /// Creates a unit point at the origin.
    ///
    /// A view's origin appears in the top-left corner in a left-to-right
    /// language environment, with positive x toward the right. It appears in
    /// the top-right corner in a right-to-left language, with positive x toward
    /// the left. Positive y is always toward the bottom of the view.
    @inlinable
    public init() {
        self.init(x: 0, y: 0)
    }
    
    /// Creates a unit point with the specified horizontal and vertical offsets.
    ///
    /// Values outside the range `[0, 1]` project to points outside of a view.
    ///
    /// - Parameters:
    ///   - x: The normalized distance from the origin to the point in the
    ///     horizontal direction.
    ///   - y: The normalized distance from the origin to the point in the
    ///     vertical direction.
    @inlinable
    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    package init(_ point: CGPoint, in rect: CGRect) {
        self.init(x: (point.x - rect.x) / rect.width, y: (point.y - rect.y) / rect.height)
    }
    
    package init(edge: Edge) {
        switch edge {
            case .top: self.init(x: 0.5, y: 0.0)
            case .leading: self.init(x: 0.0, y: 0.5)
            case .bottom: self.init(x: 0.5, y: 1.0)
            case .trailing: self.init(x: 1.0, y: 0.5)
        }
    }
    
    package func `in`(_ size: CGSize) -> CGPoint {
        CGPoint(x: size.width * x, y: size.height * y)
    }
    
    package func `in`(_ rect: CGRect) -> CGPoint {
        CGPoint(x: rect.width * x + rect.x, y: rect.height * y + rect.y)
    }
    
    /// The origin of a view.
    ///
    /// A view's origin appears in the top-left corner in a left-to-right
    /// language environment, with positive x toward the right. It appears in
    /// the top-right corner in a right-to-left language, with positive x toward
    /// the left. Positive y is always toward the bottom of the view.
    public static let zero: UnitPoint = UnitPoint(x: 0.0, y: 0.0)
    
    /// A point that's centered in a view.
    ///
    /// This point occupies the position where the horizontal and vertical
    /// alignment guides intersect for ``Alignment/center`` alignment.
    public static let center: UnitPoint = UnitPoint(x: 0.5, y: 0.5)
    
    /// A point that's centered vertically on the leading edge of a view.
    ///
    /// This point occupies the position where the horizontal and vertical
    /// alignment guides intersect for ``Alignment/leading`` alignment.
    /// The leading edge appears on the left in a left-to-right language
    /// environment and on the right in a right-to-left environment.
    public static let leading: UnitPoint = UnitPoint(x: 0.0, y: 0.5)
    
    /// A point that's centered vertically on the trailing edge of a view.
    ///
    /// This point occupies the position where the horizontal and vertical
    /// alignment guides intersect for ``Alignment/trailing`` alignment.
    /// The trailing edge appears on the right in a left-to-right language
    /// environment and on the left in a right-to-left environment.
    public static let trailing: UnitPoint = UnitPoint(x: 1, y: 0.5)
    
    /// A point that's centered horizontally on the top edge of a view.
    ///
    /// This point occupies the position where the horizontal and vertical
    /// alignment guides intersect for ``Alignment/top`` alignment.
    public static let top: UnitPoint = UnitPoint(x: 0.5, y: 0.0)
    
    /// A point that's centered horizontally on the bottom edge of a view.
    ///
    /// This point occupies the position where the horizontal and vertical
    /// alignment guides intersect for ``Alignment/bottom`` alignment.
    public static let bottom: UnitPoint = UnitPoint(x: 0.5, y: 1.0)
    
    /// A point that's in the top, leading corner of a view.
    ///
    /// This point occupies the position where the horizontal and vertical
    /// alignment guides intersect for ``Alignment/topLeading`` alignment.
    /// The leading edge appears on the left in a left-to-right language
    /// environment and on the right in a right-to-left environment.
    public static let topLeading: UnitPoint = UnitPoint(x: 0.0, y: 0.0)
    
    /// A point that's in the top, trailing corner of a view.
    ///
    /// This point occupies the position where the horizontal and vertical
    /// alignment guides intersect for ``Alignment/topTrailing`` alignment.
    /// The trailing edge appears on the right in a left-to-right language
    /// environment and on the left in a right-to-left environment.
    public static let topTrailing: UnitPoint = UnitPoint(x: 1.0, y: 0.0)
    
    /// A point that's in the bottom, leading corner of a view.
    ///
    /// This point occupies the position where the horizontal and vertical
    /// alignment guides intersect for ``Alignment/bottomLeading`` alignment.
    /// The leading edge appears on the left in a left-to-right language
    /// environment and on the right in a right-to-left environment.
    public static let bottomLeading: UnitPoint = UnitPoint(x: 0.0, y: 1.0)
    
    /// A point that's in the bottom, trailing corner of a view.
    ///
    /// This point occupies the position where the horizontal and vertical
    /// alignment guides intersect for ``Alignment/bottomTrailing`` alignment.
    /// The trailing edge appears on the right in a left-to-right language
    /// environment and on the left in a right-to-left environment.
    public static let bottomTrailing: UnitPoint = UnitPoint(x: 1.0, y: 1.0)
    
    package static let infinity: UnitPoint = UnitPoint(x: .infinity, y: .infinity)
}

// MARK: - UnitPoint + Axis

extension UnitPoint {
    package subscript(d: Axis) -> CGFloat {
        get { d == .horizontal ? x : y }
        set { if d == .horizontal { x = newValue } else { y = newValue } }
    }
    
    package init(_ l1: CGFloat, in first: Axis, by l2: CGFloat) {
        self = first == .horizontal ? UnitPoint(x: l1, y: l2) : UnitPoint(x: l2, y: l1)
    }
}

// MARK: - UnitPoint + Animatable

extension UnitPoint: Animatable {
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(x.scaled(by: .unitScale), y.scaled(by: .unitScale)) }
        set { x = newValue.first.scaled(by: .inverseUnitScale) ; y = newValue.second.scaled(by: .inverseUnitScale) }
    }
}

// MARK: - UnitPoint + Codable

extension UnitPoint: CodableByProxy {
    package var codingProxy: CodableUnitPoint {
        CodingProxy(self)
    }
}

package struct CodableUnitPoint: CodableProxy {
    package var base: UnitPoint
    package init(_ base: UnitPoint) {
        self.base = base
    }
    package func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(base.x)
        try container.encode(base.y)
    }
    
    package init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(CGFloat.self)
        let y = try container.decode(CGFloat.self)
        base = UnitPoint(x: x, y: y)
    }
}

// MARK: - UnitPoint + ProtobufMessage

extension UnitPoint: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.cgFloatField(1, x)
        encoder.cgFloatField(2, y)
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
        var x: CGFloat = .zero
        var y: CGFloat = .zero
        while let field = try decoder.nextField() {
            switch field.tag {
                case 1: x = try decoder.cgFloatField(field)
                case 2: y = try decoder.cgFloatField(field)
                default: try decoder.skipField(field)
            }
        }
        self.init(x: x, y: y)
    }
}
