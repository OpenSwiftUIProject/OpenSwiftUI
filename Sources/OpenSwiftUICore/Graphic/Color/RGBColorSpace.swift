//
//  RGBColorSpace.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

import Foundation
#if canImport(Darwin)
import CoreGraphics
#endif

extension Color {
    /// A profile that specifies how to interpret a color value for display.
    public enum RGBColorSpace: Sendable {
        /// The extended red, green, blue (sRGB) color space.
        ///
        /// For information about the sRGB colorimetry and nonlinear
        /// transform function, see the IEC 61966-2-1 specification.
        ///
        /// Standard sRGB color spaces clamp the red, green, and blue
        /// components of a color to a range of `0` to `1`, but OpenSwiftUI colors
        /// use an extended sRGB color space, so you can use component values
        /// outside that range.
        case sRGB
        
        /// The extended sRGB color space with a linear transfer function.
        ///
        /// This color space has the same colorimetry as ``sRGB``, but uses
        /// a linear transfer function.
        ///
        /// Standard sRGB color spaces clamp the red, green, and blue
        /// components of a color to a range of `0` to `1`, but OpenSwiftUI colors
        /// use an extended sRGB color space, so you can use component values
        /// outside that range.
        case sRGBLinear
        
        /// The Display P3 color space.
        ///
        /// This color space uses the Digital Cinema Initiatives - Protocol 3
        /// (DCI-P3) primary colors, a D65 white point, and the ``sRGB``
        /// transfer function.
        case displayP3
    }

    /// Creates a constant color from red, green, and blue component values.
    ///
    /// This initializer creates a constant color that doesn't change based
    /// on context. For example, it doesn't have distinct light and dark
    /// appearances, unlike various system-defined colors, or a color that
    /// you load from an Asset Catalog with ``init(_:bundle:)``.
    ///
    /// A standard sRGB color space clamps each color component — `red`,
    /// `green`, and `blue` — to a range of `0` to `1`, but OpenSwiftUI colors
    /// use an extended sRGB color space, so
    /// you can use component values outside that range. This makes it
    /// possible to create colors using the ``RGBColorSpace/sRGB`` or
    /// ``RGBColorSpace/sRGBLinear`` color space that make full use of the wider
    /// gamut of a diplay that supports ``RGBColorSpace/displayP3``.
    ///
    /// - Parameters:
    ///   - colorSpace: The profile that specifies how to interpret the color
    ///     for display. The default is ``RGBColorSpace/sRGB``.
    ///   - red: The amount of red in the color.
    ///   - green: The amount of green in the color.
    ///   - blue: The amount of blue in the color.
    ///   - opacity: An optional degree of opacity, given in the range `0` to
    ///     `1`. A value of `0` means 100% transparency, while a value of `1`
    ///     means 100% opacity. The default is `1`.
    public init(_ colorSpace: Color.RGBColorSpace = .sRGB, red: Double, green: Double, blue: Double, opacity: Double = 1) {
        switch colorSpace {
            case .sRGB:
                self.init(Color.Resolved(red: Float(red), green: Float(green), blue: Float(blue), opacity: Float(opacity)))
            case .sRGBLinear:
                self.init(Color.Resolved(linearRed: Float(red), linearGreen: Float(green), linearBlue: Float(blue), opacity: Float(opacity)))
            case .displayP3:
                self.init(provider: DisplayP3(red: red, green: green, blue: blue, opacity: Float(opacity)))
        }
    }
    
    /// Creates a constant grayscale color.
    ///
    /// This initializer creates a constant color that doesn't change based
    /// on context. For example, it doesn't have distinct light and dark
    /// appearances, unlike various system-defined colors, or a color that
    /// you load from an Asset Catalog with ``init(_:bundle:)``.
    ///
    /// A standard sRGB color space clamps the `white` component
    /// to a range of `0` to `1`, but OpenSwiftUI colors
    /// use an extended sRGB color space, so
    /// you can use component values outside that range. This makes it
    /// possible to create colors using the ``RGBColorSpace/sRGB`` or
    /// ``RGBColorSpace/sRGBLinear`` color space that make full use of the wider
    /// gamut of a diplay that supports ``RGBColorSpace/displayP3``.
    ///
    /// - Parameters:
    ///   - colorSpace: The profile that specifies how to interpret the color
    ///     for display. The default is ``RGBColorSpace/sRGB``.
    ///   - white: A value that indicates how white
    ///     the color is, with higher values closer to 100% white, and lower
    ///     values closer to 100% black.
    ///   - opacity: An optional degree of opacity, given in the range `0` to
    ///     `1`. A value of `0` means 100% transparency, while a value of `1`
    ///     means 100% opacity. The default is `1`.
    public init(_ colorSpace: RGBColorSpace = .sRGB, white: Double, opacity: Double = 1) {
        self.init(colorSpace, red: white, green: white, blue: white, opacity: opacity)
    }

    /// Creates a constant color from hue, saturation, and brightness values.
    ///
    /// This initializer creates a constant color that doesn't change based
    /// on context. For example, it doesn't have distinct light and dark
    /// appearances, unlike various system-defined colors, or a color that
    /// you load from an Asset Catalog with ``init(_:bundle:)``.
    ///
    /// - Parameters:
    ///   - hue: A value in the range `0` to `1` that maps to an angle
    ///     from 0° to 360° to represent a shade on the color wheel.
    ///   - saturation: A value in the range `0` to `1` that indicates
    ///     how strongly the hue affects the color. A value of `0` removes the
    ///     effect of the hue, resulting in gray. As the value increases,
    ///     the hue becomes more prominent.
    ///   - brightness: A value in the range `0` to `1` that indicates
    ///     how bright a color is. A value of `0` results in black, regardless
    ///     of the other components. The color lightens as you increase this
    ///     component.
    ///   - opacity: An optional degree of opacity, given in the range `0` to
    ///     `1`. A value of `0` means 100% transparency, while a value of `1`
    ///     means 100% opacity. The default is `1`.
    public init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
        let (red, green, blue) = HSBToRGB(hue: hue, saturation: saturation, brightness: brightness)
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

/// Converts HSB (Hue, Saturation, Brightness) values to RGB (Red, Green, Blue).
///
/// - Parameters:
///   - hue: Hue value in the range [0.0, 1.0].
///   - saturation: Saturation value in the range [0.0, 1.0].
///   - brightness: Brightness value in the range [0.0, 1.0].
/// - Returns: A tuple containing RGB values (red, green, blue) in the range [0.0, 1.0].
package func HSBToRGB(hue: Double, saturation: Double, brightness: Double) -> (red: Double, green: Double, blue: Double) {
    let h = hue == 1.0 ? 0 : hue * 6.0
    let x = Int(h)
    let f = h - Double(x)
    let p = brightness * (1 - saturation)
    let q = brightness * (1 - f * saturation)
    let t = brightness * (1 - (1 - f) * saturation)
    switch x % 6 {
        case 0: return (red: brightness, green: t, blue: p)
        case 1: return (red: q, green: brightness, blue: p)
        case 2: return (red: p, green: brightness, blue: t)
        case 3: return (red: p, green: q, blue: brightness)
        case 4: return (red: t, green: p, blue: brightness)
        default: return (red: brightness, green: p, blue: q)
    }
}
