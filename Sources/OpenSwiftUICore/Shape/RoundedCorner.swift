//
//  RoundedCorner.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

public import Foundation
package import OpenCoreGraphicsShims

// MARK: - RoundedCornerStyle

/// Defines the shape of a rounded rectangle's corners.
public enum RoundedCornerStyle: Sendable {
    /// Quarter-circle rounded rect corners.
    case circular

    /// Continuous curvature rounded rect corners.
    case continuous
}

// MARK: - FixedRoundedRect [WIP]

@usableFromInline
package struct FixedRoundedRect: Equatable {
    package var rect: CGRect
    
    package var cornerSize: CGSize
    
    package var style: RoundedCornerStyle
  
    package init(_ rect: CGRect, cornerSize: CGSize, style: RoundedCornerStyle) {
        self.rect = rect
        self.cornerSize = cornerSize
        self.style = style
    }

    package init(_ rect: CGRect) {
        self.rect = rect
        self.cornerSize = .zero
        self.style = .circular
    }

    package init(_ rect: CGRect, cornerRadius: CGFloat, style: RoundedCornerStyle) {
        self.rect = rect
        self.cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
        self.style = style
    }

    package var isRounded: Bool {
        cornerSize != .zero
    }

    package var isUniform: Bool {
        cornerSize.width == cornerSize.height
    }

    package var needsContinuousCorners: Bool {
        style == .continuous && isRounded
    }

    package var clampedCornerSize: CGSize {
        let minRadius = min(abs(rect.width) / 2, abs(rect.height) / 2)
        return CGSize(width: min(minRadius, cornerSize.width), height: min(minRadius, cornerSize.height))

    }

    package var clampedCornerRadius: CGFloat {
        min(min(rect.width, rect.height) / 2, cornerSize.width)
    }

    // TODO: RenderBox
    // package func withTemporaryPath<R>(_ body: (ORBPath) -> R) -> R

    package func contains(_ point: CGPoint) -> Bool {
        // TODO: ORBPath
        _openSwiftUIUnimplementedFailure()
    }

    package func applying(_ m: CGAffineTransform) -> FixedRoundedRect {
        FixedRoundedRect(
            rect.applying(m),
            cornerSize: cornerSize.isFinite ? cornerSize.applying(m) : cornerSize, // FIXME
            style: style
        )
    }

    package func contains(_ rhs: FixedRoundedRect) -> Bool {
        guard rect.insetBy(dx: -0.001, dy: -0.001).contains(rhs.rect) else {
            return false
        }
        guard !(cornerSize.width <= rhs.cornerSize.width && cornerSize.height <= rhs.cornerSize.height) else {
            return true
        }
        let minCornerWidth = min(abs(rect.size.width) / 2, cornerSize.width)
        let minCornerHeight = min(abs(rect.size.height) / 2, cornerSize.height)
        let factor = 1 - cos(45 * Double.pi / 180)
        return rect.insetBy(dx: minCornerWidth * factor, dy: minCornerHeight * factor).contains(rhs.rect)
    }

    package func contains(rect: CGRect) -> Bool {
        contains(FixedRoundedRect(rect))
    }

    package func contains(path: Path, offsetBy delta: CGSize) -> Bool {
        var rhs: FixedRoundedRect
        switch path.storage {
        case .rect(let cGRect):
            rhs = FixedRoundedRect(cGRect)
        case .ellipse(let cGRect):
            let size = cGRect.size
            if size.width == size.height {
                rhs = FixedRoundedRect(cGRect, cornerRadius: size.width / 2, style: .circular)
            } else {
                rhs = FixedRoundedRect(path.boundingRect)
            }
        case let .roundedRect(fixedRoundedRect):
            rhs = fixedRoundedRect
        default:
            rhs = FixedRoundedRect(path.boundingRect)
        }
        rhs.rect.origin += delta
        return contains(rhs)
    }

    package func hasIntersection(_ rect: CGRect) -> Bool {
        !self.rect.intersection(rect).isEmpty
    }

    package func insetBy(dx: CGFloat, dy: CGFloat) -> FixedRoundedRect? {
        guard dx != 0 || dy != 0 else {
            return self
        }
        let insetedRect = rect.insetBy(dx: dx, dy: dy)
        guard !insetedRect.isEmpty else {
            return nil
        }
        return FixedRoundedRect(
            insetedRect,
            cornerSize: CGSize(width: max(cornerSize.width - dx, 0), height: max(cornerSize.height - dy, 0)),
            style: style
        )
    }

    #if canImport(CoreGraphics)
    package var cgPath: CGPath {
        _openSwiftUIUnimplementedFailure()
    }
    #endif

    @usableFromInline
    package static func == (a: FixedRoundedRect, b: FixedRoundedRect) -> Bool {
        a.rect == b.rect && a.cornerSize == b.cornerSize && a.style == b.style
    }
}

@available(*, unavailable)
extension FixedRoundedRect: Sendable {}

extension FixedRoundedRect: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, rect, defaultValue: .zero)
        try encoder.messageField(2, cornerSize, defaultValue: .zero)
        encoder.enumField(3, style, defaultValue: .circular)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var fixedRoundedRect = FixedRoundedRect(.zero)
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: fixedRoundedRect.rect = try decoder.messageField(field)
            case 2: fixedRoundedRect.cornerSize = try decoder.messageField(field)
            case 3: fixedRoundedRect.style = try decoder.enumField(field) ?? .circular
            default: try decoder.skipField(field)
            }
        }
        self = fixedRoundedRect
    }
}

extension RoundedCornerStyle: ProtobufEnum {
    package var protobufValue: UInt {
        switch self {
        case .circular: 0
        case .continuous: 1
        }
    }

    package init?(protobufValue value: UInt) {
        switch value {
        case 0: self = .circular
        case 1: self = .continuous
        default: return nil
        }
    }
}

// MARK: - RectangleCornerRadii

/// Describes the corner radius values of a rounded rectangle with
/// uneven corners.
@frozen
public struct RectangleCornerRadii: Equatable, Animatable {
    @usableFromInline
    package var topLeft: CGFloat

    @usableFromInline
    package var topRight: CGFloat

    @usableFromInline
    package var bottomRight: CGFloat

    @usableFromInline
    package var bottomLeft: CGFloat

    /// The radius of the top-leading corner.
    @_alwaysEmitIntoClient
    public var topLeading: CGFloat {
        get { topLeft }
        set { topLeft = newValue }
    }

    /// The radius of the bottom-leading corner.
    @_alwaysEmitIntoClient
    public var bottomLeading: CGFloat {
        get { bottomLeft }
        set { bottomLeft = newValue }
    }

    /// The radius of the bottom-trailing corner.
    @_alwaysEmitIntoClient
    public var bottomTrailing: CGFloat {
        get { bottomRight }
        set { bottomRight = newValue }
    }

    /// The radius of the top-trailing corner.
    @_alwaysEmitIntoClient
    public var topTrailing: CGFloat {
        get { topRight }
        set { topRight = newValue }
    }

    @usableFromInline
    package init(topLeft: CGFloat, topRight: CGFloat, bottomRight: CGFloat, bottomLeft: CGFloat) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
    }

    /// Creates a new set of corner radii for a rounded rectangle with
    /// uneven corners.
    ///
    /// - Parameters:
    ///   - topLeading: the radius of the top-leading corner.
    ///   - bottomLeading: the radius of the bottom-leading corner.
    ///   - bottomTrailing: the radius of the bottom-trailing corner.
    ///   - topTrailing: the radius of the top-trailing corner.
    @_alwaysEmitIntoClient
    public init(topLeading: CGFloat = 0, bottomLeading: CGFloat = 0, bottomTrailing: CGFloat = 0, topTrailing: CGFloat = 0) {
        self.init(
            topLeft: topLeading, topRight: topTrailing,
            bottomRight: bottomTrailing, bottomLeft: bottomLeading
        )
    }

    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
        get { AnimatablePair(AnimatablePair(topLeft, topRight), AnimatablePair(bottomLeft, bottomRight)) }
        set {
            topLeft = newValue.first.first
            topRight = newValue.first.second
            bottomLeft = newValue.second.first
            bottomRight = newValue.second.second
        }
    }
}
