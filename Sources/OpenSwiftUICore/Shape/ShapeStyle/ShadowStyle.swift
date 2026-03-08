//
//  ShadowStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

// MARK: - ShadowStyle

/// A style to use when rendering shadows.
@available(OpenSwiftUI_v4_0, *)
public struct ShadowStyle: Equatable, Sendable {
    package struct Kind: OptionSet {
        package let rawValue: UInt8

        package init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        package static let drop: Kind = []

        package static let inner: Kind = .init(rawValue: 1 << 0)

        package static let only: Kind = .init(rawValue: 1 << 1)

        package static let nonOpaque: Kind = .init(rawValue: 1 << 2)

        package static let ignoresFill: Kind = .init(rawValue: 1 << 3)

        package static let requiresKnockout: Kind = .init(rawValue: 1 << 4)
    }

    enum Storage: Equatable {
        case standard(Kind)
        case custom(Kind, Color, CGFloat, CGSize)

        @inline(__always)
        var kind: Kind {
            get {
                switch self {
                case let .standard(kind): kind
                case let .custom(kind, _, _, _): kind
                }
            }
            set {
                switch self {
                case .standard:
                    self = .standard(newValue)
                case let .custom(_, color, radius, offset):
                    self = .custom(newValue, color, radius, offset)
                }
            }
        }
    }

    private var storage: Storage
    
    private var midpoint: Float

    @_spi(Private)
    public static let drop: ShadowStyle = .drop(radius: 0)

    @_spi(Private)
    public static let inner: ShadowStyle = .inner(radius: 0)

    /// Creates a custom drop shadow style.
    ///
    /// Drop shadows draw behind the source content by blurring,
    /// tinting and offsetting its per-pixel alpha values.
    ///
    /// - Parameters:
    ///   - color: The shadow's color.
    ///   - radius: The shadow's size.
    ///   - x: A horizontal offset you use to position the shadow
    ///     relative to this view.
    ///   - y: A vertical offset you use to position the shadow
    ///     relative to this view.
    ///
    /// - Returns: A new shadow style.
    public static func drop(
        color: Color = .init(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> ShadowStyle {
        ShadowStyle(
            storage: .custom(.drop, color, radius, CGSize(width: x, height: y)),
            midpoint: 0.5
        )
    }

    /// Creates a custom inner shadow style.
    ///
    /// Inner shadows draw on top of the source content by blurring,
    /// tinting, inverting and offsetting its per-pixel alpha values.
    ///
    /// - Parameters:
    ///   - color: The shadow's color.
    ///   - radius: The shadow's size.
    ///   - x: A horizontal offset you use to position the shadow
    ///     relative to this view.
    ///   - y: A vertical offset you use to position the shadow
    ///     relative to this view.
    ///
    /// - Returns: A new shadow style.
    public static func inner(
        color: Color = .init(.sRGBLinear, white: 0, opacity: 0.55),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> ShadowStyle {
        ShadowStyle(
            storage: .custom(.inner, color, radius, CGSize(width: x, height: y)),
            midpoint: 0.5
        )
    }
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension ShadowStyle {
    @_spi(Private)
    public func ignoresFill(_ enabled: Bool = true) -> ShadowStyle {
        ignoresFill(enabled, knockout: false)
    }

    package func ignoresFill(_ enabled: Bool, knockout: Bool) -> ShadowStyle {
        var result = self
        var kind = result.storage.kind
        if enabled {
            if knockout {
                kind.formUnion([.ignoresFill, .requiresKnockout])
            } else {
                kind.formUnion(.ignoresFill)
                kind.subtract(.requiresKnockout)
            }
        } else {
            kind.subtract([.ignoresFill, .requiresKnockout])
        }
        result.storage.kind = kind
        return result
    }

    @_spi(Private)
    public func midpoint(_ value: Double) -> ShadowStyle {
        var result = self
        result.midpoint = Float(value)
        return result
    }
}

@available(OpenSwiftUI_v4_0, *)
extension ShadowStyle {
    @inline(__always)
    package func resolve(in environment: EnvironmentValues) -> ResolvedShadowStyle {
        switch storage {
        case let .standard(kind):
            return ResolvedShadowStyle(
                color: .init(white: 0, opacity: 0.33),
                radius: 1.0,
                offset: CGSize(width: 0, height: 1.5),
                midpoint: midpoint,
                kind: kind
            )
        case let .custom(kind, color, radius, offset):
            return ResolvedShadowStyle(
                color: color.resolve(in: environment),
                radius: radius,
                offset: offset,
                midpoint: midpoint,
                kind: kind
            )
        }
    }
}

// MARK: - ShapeStyle + shadow

@available(OpenSwiftUI_v4_0, *)
extension ShapeStyle {

    /// Applies the specified shadow effect to the shape style.
    ///
    /// For example, you can create a rectangle that adds a drop shadow to
    /// the ``ShapeStyle/red`` shape style.
    ///
    ///     Rectangle().fill(.red.shadow(.drop(radius: 2, y: 3)))
    ///
    /// - Parameter style: The shadow style to apply.
    ///
    /// - Returns: A new shape style that uses the specified shadow style.
    @inlinable
    public func shadow(_ style: ShadowStyle) -> some ShapeStyle {
        return _ShadowShapeStyle(style: self, shadowStyle: style)
    }
}

@available(OpenSwiftUI_v4_0, *)
extension ShapeStyle where Self == AnyShapeStyle {

    /// Returns a shape style that applies the specified shadow style to the
    /// current style.
    ///
    /// In most contexts the current style is the foreground, but not always.
    /// For example, when setting the value of the background style, that
    /// becomes the current implicit style.
    ///
    /// The following example creates a circle filled with the current
    /// foreground style that uses an inner shadow:
    ///
    ///     Circle().fill(.shadow(.inner(radius: 1, y: 1)))
    ///
    /// - Parameter style: The shadow style to apply.
    ///
    /// - Returns: A new shape style based on the current style that uses the
    ///   specified shadow style.
    @_alwaysEmitIntoClient
    public static func shadow(_ style: ShadowStyle) -> some ShapeStyle {
        return _ShadowShapeStyle(
            style: _ImplicitShapeStyle(), shadowStyle: style)
    }
}

// MARK: - _ShadowShapeStyle

@available(OpenSwiftUI_v4_0, *)
@frozen
public struct _ShadowShapeStyle<Style>: ShapeStyle, PrimitiveShapeStyle where Style: ShapeStyle {
    @usableFromInline
    var style: Style

    @usableFromInline
    var shadowStyle: ShadowStyle

    @inlinable
    init(style: Style, shadowStyle: ShadowStyle) {
        self.style = style
        self.shadowStyle = shadowStyle
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
        case .prepareText:
            shape.result = .preparedText(.foregroundKeyColor)
        case let .resolveStyle(name, levels):
            style._apply(to: &shape)
            let resolved = shadowStyle.resolve(in: shape.environment)
            shape.stylePack.modify(name: name, levels: levels) { style in
                let effect: ShapeStyle.Pack.Effect
                if Semantics.ShapeStyleDownwardsModifiers.isEnabled {
                    effect = ShapeStyle.Pack.Effect(
                        kind: .shadow(resolved),
                        opacity: 1.0,
                        _blend: nil
                    )
                } else {
                    effect = ShapeStyle.Pack.Effect(
                        kind: .shadow(resolved),
                        opacity: style.opacity,
                        _blend: style._blend
                    )
                }
                style.effects.append(effect)
            }
        case .copyStyle:
            style.mapCopiedStyle(in: &shape) { copiedStyle in
                _ShadowShapeStyle<AnyShapeStyle>(style: copiedStyle, shadowStyle: shadowStyle)
            }
        case .fallbackColor, .modifyBackground, .multiLevel:
            style._apply(to: &shape)
        case .primaryStyle:
            break
        }
    }

    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        Style._apply(to: &type)
    }
}

// MARK: - ResolvedShadowStyle

package struct ResolvedShadowStyle: Equatable, Sendable {
    package var color: Color.Resolved

    package var radius: CGFloat

    package var offset: CGSize

    package var midpoint: Float

    package var kind: ShadowStyle.Kind

    package init(
        color: Color.Resolved,
        radius: CGFloat,
        offset: CGSize,
        midpoint: Float = 0.5,
        kind: ShadowStyle.Kind = .drop
    ) {
        self.color = color
        self.radius = radius
        self.offset = offset
        self.midpoint = midpoint
        self.kind = kind
    }

    package var insets: EdgeInsets {
        guard !kind.contains(.inner) else {
            return EdgeInsets()
        }
        let spread = radius * -2.8
        return EdgeInsets(
            top: offset.height + spread,
            leading: offset.width + spread,
            bottom: spread - offset.height,
            trailing: spread - offset.width
        )
    }

    package static func == (a: ResolvedShadowStyle, b: ResolvedShadowStyle) -> Bool {
        a.color == b.color
            && a.radius == b.radius
            && a.offset == b.offset
            && a.midpoint == b.midpoint
            && a.kind == b.kind
    }
}

#if canImport(Darwin)
import OpenSwiftUI_SPI

extension ResolvedShadowStyle {
    package init?(nsShadow: NSObject) {
        let offset = CoreShadowGetOffset(nsShadow)
        let blurRadius = CoreShadowGetBlurRadius(nsShadow)
        guard offset.width >= 0,
              offset.height >= 0,
              blurRadius >= 0 else {
            return nil
        }
        guard let platformColor = CoreShadowGetPlatformColor(nsShadow) as AnyObject? else {
            return nil
        }
        guard let resolvedColor = Color.Resolved(platformColor: platformColor) else {
            return nil
        }
        self.init(
            color: resolvedColor,
            radius: blurRadius,
            offset: offset,
            midpoint: 0.5,
            kind: .drop
        )
    }
}
#endif

// MARK: - ResolvedShadowStyle + Animatable

extension ResolvedShadowStyle: Animatable {
    package typealias AnimatableData = AnimatablePair<Color.Resolved.AnimatableData, AnimatablePair<CGFloat, CGSize.AnimatableData>>

    package var animatableData: AnimatableData {
        get {
            AnimatablePair(
                color.animatableData,
                AnimatablePair(radius, offset.animatableData)
            )
        }
        set {
            color.animatableData = newValue.first
            radius = newValue.second.first
            offset.animatableData = newValue.second.second
        }
    }
}

// MARK: - ResolvedShadowStyle + ProtobufMessage

extension ResolvedShadowStyle: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, color, defaultValue: .black)
        encoder.cgFloatField(2, radius)
        try encoder.messageField(3, offset, defaultValue: .zero)
        encoder.uintField(4, UInt(kind.rawValue))
        encoder.floatField(5, midpoint, defaultValue: 0.5)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var color: Color.Resolved = .black
        var radius: CGFloat = .zero
        var offset: CGSize = .zero
        var midpoint: Float = 0.5
        var kind: ShadowStyle.Kind = .drop
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: color = try decoder.messageField(field)
            case 2: radius = try decoder.cgFloatField(field)
            case 3: offset = try decoder.messageField(field)
            case 4: kind = ShadowStyle.Kind(rawValue: try decoder.uint8Field(field))
            case 5: midpoint = try decoder.floatField(field)
            default: try decoder.skipField(field)
            }
        }
        self.init(color: color, radius: radius, offset: offset, midpoint: midpoint, kind: kind)
    }
}
