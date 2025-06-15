//
//  ModifiedColor.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: B495DF025D9B78431A787E266E7D8FB1 (SwiftUI)
//  ID: F28C5F7FF836E967BAC87540A3CB4F65 (SwiftUICore)

#if canImport(Darwin)
import CoreGraphics
import Foundation
#endif
import OpenSwiftUI_SPI

@available(OpenSwiftUI_v1_0, *)
extension Color {
    // MARK: - OpacityColor [6.4.41]

    private struct OpacityColor: ColorProvider, CustomStringConvertible {
        var base: Color

        var opacity: Double

        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            base.provider.resolve(in: environment).multiplyingOpacity(by: Float(opacity))
        }

        #if canImport(Darwin)
        var staticColor: CGColor? {
            guard let baseStaticColor = base.provider.staticColor else {
                return nil
            }
            return baseStaticColor.copy(alpha: opacity * baseStaticColor.alpha)!
        }
        #endif

        var description: String {
            "\(Int(opacity * 100 + 0.5))% \(base)"
        }
    }

    /// Multiplies the opacity of the color by the given amount.
    ///
    /// - Parameter opacity: The amount by which to multiply the opacity of the
    ///   color.
    /// - Returns: A view with modified opacity.
    public func opacity(_ opacity: Double) -> Color {
        Color(provider: OpacityColor(base: self, opacity: opacity))
    }

    // MARK: - HierarchicalOpacityColor [6.4.41]

    private struct HierarchicalOpacityColor: ColorProvider, CustomStringConvertible {
        var base: Color

        var level: Int

        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            let opacity = base.provider.opacity(at: level, environment: environment)
            return base.provider.resolve(in: environment).multiplyingOpacity(by: opacity)
        }

        var description: String {
            "\(level) \(base)"
        }
    }

    package func multiplyingHierarchicalOpacity(at level: Int) -> Color {
        Color(provider: HierarchicalOpacityColor(base: self, level: level))
    }

    // MARK: - DestinationOverProvider [6.4.41]

    private struct DestinationOverProvider: ColorProvider {
        var lhs: Color

        var rhs: Color

        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            lhs.resolve(in: environment).over(rhs.resolve(in: environment))
        }
    }

    package func over(_ rhs: Color) -> Color {
        Color(provider: DestinationOverProvider(lhs: self, rhs: rhs))
    }

    // MARK: - MixProvider [6.4.41]

    private struct MixProvider: ColorProvider {
        var lhs: Color
        var rhs: Color
        var colorSpace: Gradient.ColorSpace
        var fraction: Float

        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            colorSpace.base.mix(
                lhs.resolve(in: environment),
                rhs.resolve(in: environment),
                by: fraction
            )
        }
    }

    /// Returns a version of self mixed with `rhs` by the amount specified
    /// by `fraction`.
    ///
    /// - Parameters:
    ///   - rhs: The color to mix `self` with.
    ///   - fraction: The amount of blending, `0.5` means `self` is mixed in
    ///               equal parts with `rhs`.
    ///   - colorSpace: The color space used to mix the colors.
    /// - Returns: A new `Color` based on `self` and `rhs`.
    @available(OpenSwiftUI_v6_0, *)
    public func mix(
        with rhs: Color,
        by fraction: Double,
        in colorSpace: Gradient.ColorSpace = .perceptual
    ) -> Color {
        Color(provider: MixProvider(
            lhs: self,
            rhs: rhs,
            colorSpace: colorSpace,
            fraction: Float(fraction)
        ))
    }

    @_spi(Private)
    @available(*, deprecated, renamed: "mix(with:by:in:)")
    public func blend(
        with rhs: Color,
        in colorSpace: Gradient.ColorSpace = .perceptual,
        by fraction: Double
    ) -> Color {
        Color(provider: MixProvider(
            lhs: self,
            rhs: rhs,
            colorSpace: colorSpace,
            fraction: Float(fraction)
        ))
    }
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension Color {
    // MARK: - SettingOpacityProvider [6.4.41]

    private struct SettingOpacityProvider: ColorProvider {
        var base: Color

        var opacity: Float

        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            var resolved = base.provider.resolve(in: environment)
            resolved.opacity = opacity
            return resolved
        }

        #if canImport(Darwin)
        var staticColor: CGColor? {
            guard let baseStaticColor = base.provider.staticColor else {
                return nil
            }
            return baseStaticColor.copy(alpha: CGFloat(opacity))!
        }
        #endif
    }

    public func _settingOpacity(_ opacity: Double) -> Color {
        Color(provider: SettingOpacityProvider(base: self, opacity: Float(opacity)))
    }
}

// MARK: - CustomVibrantColor_Watch [6.4.41] [WIP]

struct CustomVibrantColor_Watch: ColorProvider {
    var base: Color
    var vibrantMatrix: _ColorMatrix
    var tertiaryOpacity: Float

    func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        base.provider.resolve(in: environment)
    }

    func opacity(at level: Int, environment: EnvironmentValues) -> Float {
        guard level != 2 else {
            return tertiaryOpacity
        }
        return environment.systemColorDefinition.base.opacity(at: level, environment: environment)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(base)
        #if canImport(Darwin)
        hasher.combine(NSValue(caColorMatrix: vibrantMatrix.caColorMatrix))
        #endif
        hasher.combine(tertiaryOpacity)
    }
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
extension Color {
    public func vibrancy(_ vibrantMatrix: _ColorMatrix, tertiaryOpacity: Double) -> Color {
        Color(provider: CustomVibrantColor_Watch(
            base: self,
            vibrantMatrix: vibrantMatrix,
            tertiaryOpacity: Float(tertiaryOpacity)
        ))
    }
}
