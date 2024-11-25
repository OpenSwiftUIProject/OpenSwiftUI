//
//  ColorResolved.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 7C95FE02C0C9104041ABD4890B043CBE (SwiftUICore?)

import Foundation
import OpenSwiftUI_SPI

// MARK: - Color.Resolved

extension Color {
    /// A concrete color value.
    ///
    /// `Color.Resolved` is a set of RGBA values that represent a color that can
    /// be shown. The values are in Linear sRGB color space, extended range. This is
    /// a low-level type, most colors are represented by the `Color` type.
    ///
    /// - SeeAlso: `Color`
    @frozen
    public struct Resolved: Hashable {
        /// The amount of red in the color in the sRGB linear color space.
        public var linearRed: Float
        
        /// The amount of green in the color in the sRGB linear color space.
        public var linearGreen: Float
        
        /// The amount of blue in the color in the sRGB linear color space.
        public var linearBlue: Float
        /// The degree of opacity in the color, given in the range `0` to `1`.
        ///
        /// A value of `0` means 100% transparency, while a value of `1` means
        /// 100% opacity.
        public var opacity: Float
        
        package init(linearRed: Float, linearGreen: Float, linearBlue: Float, opacity: Float = 1) {
            self.linearRed = linearRed
            self.linearGreen = linearGreen
            self.linearBlue = linearBlue
            self.opacity = opacity
        }
        
        package func multiplyingOpacity(by opacity: Float) -> Color.Resolved {
            Color.Resolved(linearRed: linearRed, linearGreen: linearGreen, linearBlue: linearBlue, opacity: opacity * self.opacity)
        }
        
        package func over(_ s: Color.Resolved) -> Color.Resolved {
            let red = s.red * s.opacity * (1 - opacity) + red * opacity
            let green = s.green * s.opacity * (1 - opacity) + green * opacity
            let blue = s.blue * s.opacity * (1 - opacity) + blue * opacity
            
            let factor = 1 - (1 - opacity) * (1 - s.opacity)
            guard factor != .zero else { return .init(linearWhite: 0) }
            return .init(red: red / factor, green: green / factor, blue: blue / factor, opacity: factor)
        }
    }
    
    package struct ResolvedVibrant: Equatable {
        package var scale: Float
        package var bias: (Float, Float, Float)
        
        package var colorMatrix: _ColorMatrix {
            return _ColorMatrix(
                row1: (scale, 0, 0, 0, bias.0),
                row2: (0, scale, 0, 0, bias.1),
                row3: (0, 0, scale, 0, bias.2),
                row4: (0, 0, 0, 1, 0)
            )
        }
        
        package static func == (lhs: ResolvedVibrant, rhs: ResolvedVibrant) -> Bool {
            lhs.scale == rhs.scale && lhs.bias == rhs.bias
        }
    }
    
    /// Creates a constant color with the values specified by the resolved
    /// color.
    public init(_ resolved: Resolved) {
        self.init(provider: ResolvedColorProvider(color: resolved))
    }
}

private struct ResolvedColorProvider: ColorProvider {
    var color: Color.Resolved
    
    func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        color
    }
    
    #if canImport(Darwin)
    var staticColor: CGColor? {
        // cache
        preconditionFailure("")
    }
    #endif
    
    var colorDescription: String {
        // FIXME
        color.description
    }
}

// MARK: - Color.Resolved + ShapeStyle

extension Color.Resolved: ShapeStyle, PrimitiveShapeStyle {
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        preconditionFailure("TODO")
    }
    
    public typealias Resolved = Never
}

extension Color.Resolved: CustomStringConvertible {
    public var description: String {
        String(
            format: "#%02X%02X%02X%02X",
            Int(red * 255.0 + 0.5),
            Int(green * 255.0 + 0.5),
            Int(blue * 255.0 + 0.5),
            Int(opacity * 255.0 + 0.5)
        )
    }
}

// MARK: - Color.Resolved + Animatable

extension Color.Resolved : Animatable {
    package static var legacyInterpolation: Bool = {
        // TODO: Semantic.v6
        return false
    }()

    public var animatableData: AnimatablePair<Float, AnimatablePair<Float, AnimatablePair<Float, Float>>> {
        get {
            if Self.legacyInterpolation {
                // ResolvedGradient.Color.Space.convertIn(self)
                preconditionFailure("TODO")
            } else {
                let factor: Float = 128.0
                return AnimatablePair(linearRed * factor, AnimatablePair(linearGreen * factor, AnimatablePair(linearBlue * factor, opacity * factor)))
            }
        }

        set {
            let factor: Float = 0.0078125
            if Self.legacyInterpolation {
                // ResolvedGradient.Color.Space.convertOut(self)
                preconditionFailure("TODO")
            } else {
                linearRed = newValue.first * factor
                linearGreen = newValue.second.first * factor
                linearBlue = newValue.second.second.first * factor
                opacity = newValue.second.second.second * factor
            }
        }
    }
}

extension Color.ResolvedVibrant: Animatable {
    package var animatableData: AnimatablePair<Float, AnimatablePair<Float, AnimatablePair<Float, Float>>> {
        get {
            let factor: Float = 128.0
            return AnimatablePair(scale * factor, AnimatablePair(bias.0 * factor, AnimatablePair(bias.1 * factor, bias.2 * factor)))
        }
        set {
            let factor: Float = 0.0078125
            scale = newValue.first * factor
            bias = (newValue.second.first * factor, newValue.second.second.first * factor, newValue.second.second.second * factor)
        }
    }
}

// MARK: - Color.Resolved + extension

extension Color.Resolved {
    package static let clear: Color.Resolved = Color.Resolved(linearWhite: 0, opacity: 0)
    package static let black: Color.Resolved = Color.Resolved(linearWhite: 0)
    package static let gray_75: Color.Resolved = Color.Resolved(linearWhite: 0.522522, opacity: 1)
    package static let gray_50: Color.Resolved = Color.Resolved(linearWhite: 0.214041, opacity: 1)
    package static let gray_25: Color.Resolved = Color.Resolved(linearWhite: 0.0508761, opacity: 1)
    package static let white: Color.Resolved = Color.Resolved(linearWhite: 1)
    package static let red: Color.Resolved = Color.Resolved(linearRed: 1, linearGreen: 0, linearBlue: 0, opacity: 1)
    package static let blue: Color.Resolved = Color.Resolved(linearRed: 0, linearGreen: 0, linearBlue: 1, opacity: 1)
    package static let green: Color.Resolved = Color.Resolved(linearRed: 0, linearGreen: 1, linearBlue: 0, opacity: 1)

    package init(red: Float, green: Float, blue: Float, opacity: Float = 1) {
        self.init(linearRed: sRGBToLinear(red), linearGreen: sRGBToLinear(green), linearBlue: sRGBToLinear(blue), opacity: opacity)
    }

    public init(colorSpace: Color.RGBColorSpace = .sRGB, red: Float, green: Float, blue: Float, opacity: Float = 1) {
        switch colorSpace {
        case .sRGB:
            self.init(red: red, green: green, blue: blue, opacity: opacity)
        case .sRGBLinear:
            self.init(linearRed: red, linearGreen: green, linearBlue: blue, opacity: opacity)
        case .displayP3:
            self.init(displayP3Red: red, green: green, blue: blue, opacity: opacity)
        }
    }

    package init(linearWhite: Float, opacity: Float = 1) {
        self.init(linearRed: linearWhite, linearGreen: linearWhite, linearBlue: linearWhite, opacity: opacity)
    }

    package init(white: Float, opacity: Float = 1) {
        let linearWhite = sRGBToLinear(white)
        self.init(linearWhite: linearWhite, opacity: opacity)
    }

    package var red: Float {
        get { sRGBFromLinear(linearRed) }
        set { linearRed = sRGBToLinear(newValue) }
    }

    package var green: Float {
        get { sRGBFromLinear(linearGreen) }
        set { linearGreen = sRGBToLinear(newValue) }
    }

    package var blue: Float {
        get { sRGBFromLinear(linearBlue) }
        set { linearBlue = sRGBToLinear(newValue) }
    }

    package var white: Float {
        sRGBFromLinear(linearWhite)
    }

    package var linearWhite: Float {
        linearRed * 0.2126 + linearGreen * 0.7152 + linearBlue * 0.0722
    }
}

// MARK: - Color.Resolved + Display P3

extension Color {
    struct DisplayP3: ColorProvider {
        #if canImport(Darwin)
        private static let p3ColorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
        #endif
        
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let opacity: Float
        
        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            Color.Resolved(displayP3Red: Float(red), green: Float(green), blue: Float(blue), opacity: opacity)
        }
        
        #if canImport(Darwin)
        var staticColor: CGColor? {
            var components: [CGFloat] = [red, green, blue, CGFloat(opacity)]
            return CGColor(colorSpace: Self.p3ColorSpace, components: &components)
        }
        #endif
    }
}

extension Color.Resolved {
    // SwiftUI iOS 18:
    // lienarRed: 0.07322389539
    // red: 0.2999999982
    // Output: #4C4C4C4D
    
    // OpenSwiftUI
    // lienarRed: 0.07323897
    // red: 0.3
    // Output: #4D4D4D4D
    /// OpenSwiftUI's implementation gives more accurate result.
    /// But in case we need to match SwiftUI implementation on iOS 18, we can set this flag to true.
    @_spi(ForTestOnly)
    public static var _alignWithSwiftUIImplementation = false
    
    package init(linearDisplayP3Red: Float, green: Float, blue: Float, opacity: Float = 1) {
        // Convert from Display P3 to sRGB linear color space
        let linearRed = linearDisplayP3Red * 1.2249 + green * -0.2247
        let linearGreen = linearDisplayP3Red * -0.0420 + green * 1.0419
        let linearBlue = linearDisplayP3Red * -0.0197 + green * -0.0786 + blue * 1.0979
        self.init(linearRed: linearRed, linearGreen: linearGreen, linearBlue: linearBlue, opacity: opacity)
    }

    package init(displayP3Red: Float, green: Float, blue: Float, opacity: Float = 1) {
        self.init(linearDisplayP3Red: sRGBToLinear(displayP3Red), green: sRGBToLinear(green), blue: sRGBToLinear(blue), opacity: opacity)
    }

    package var linearDisplayP3Components: (Float, Float, Float) {
        // Convert from sRGB linear color space to Display P3
        let linearDisplayP3Red = linearRed * 0.8225 + linearGreen * 0.1774
        let linearDisplayP3Green = linearRed * 0.0332 + linearGreen * 0.9669
        let linearDisplayP3Blue = linearRed * 0.0171 + linearGreen * 0.0724 + blue * 0.9108
        return (linearDisplayP3Red, linearDisplayP3Green, linearDisplayP3Blue)
    }

    package var displayP3Components: (Float, Float, Float) {
        let linearDisplayP3Components = linearDisplayP3Components
        return (sRGBFromLinear(linearDisplayP3Components.0), sRGBFromLinear(linearDisplayP3Components.1), sRGBFromLinear(linearDisplayP3Components.2))
    }
}

// MARK: - Color.Resolved + Codable

extension Color.Resolved: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(red)
        try container.encode(green)
        try container.encode(blue)
        try container.encode(opacity)
    }

    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let red = try container.decode(Float.self)
        let green = try container.decode(Float.self)
        let blue = try container.decode(Float.self)
        let opacity = try container.decode(Float.self)
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - Color.Resolved + ProtobufMessage

extension Color.Resolved: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) {
        encoder.floatField(1, red)
        encoder.floatField(2, green)
        encoder.floatField(3, blue)
        encoder.floatField(4, opacity)
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
        var red: Float = .zero
        var green: Float = .zero
        var blue: Float = .zero
        var opacity: Float = 1
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: red = try decoder.floatField(field)
            case 2: green = try decoder.floatField(field)
            case 3: blue = try decoder.floatField(field)
            case 4: opacity = try decoder.floatField(field)
            default: try decoder.skipField(field)
            }
        }
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - Util method

@inline(__always)
func sRGBFromLinear(_ linear: Float) -> Float {
    let nonNegativeLinear = linear > 0 ? linear : -linear
    let result = if nonNegativeLinear <= 0.0031308 {
        nonNegativeLinear * 12.92
    } else if nonNegativeLinear == 1.0 {
        Float(1.0)
    } else {
        pow(nonNegativeLinear, 1.0 / 2.4) * 1.055 - 0.055
    }
    return linear > 0 ? result : -result
}

@inline(__always)
func sRGBToLinear(_ sRGB: Float) -> Float {
    let nonNegativeSRGB = sRGB > 0 ? sRGB : -sRGB
    let result = if nonNegativeSRGB <= 0.04045 {
        nonNegativeSRGB * (1 / 12.92)
    } else if nonNegativeSRGB == 1.0 {
        Float(1.0)
    } else {
        if Color.Resolved._alignWithSwiftUIImplementation {
            pow(nonNegativeSRGB * (1 / 1.055) + 0.055 * (1 / 1.055), 2.4)
        } else {
            pow((nonNegativeSRGB + 0.055) / 1.055, 2.4)
        }
    }
    return sRGB > 0 ? result : -result
}
