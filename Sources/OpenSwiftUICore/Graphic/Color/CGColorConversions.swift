//
//  CGColorConversions.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: A45C110C8134A7DB30776EFC6CE1E8A6 (SwiftUICore)

import Foundation
public import OpenCoreGraphicsShims

// MARK: - CGColor + Color

extension Color {
    /// Creates a color from a Core Graphics color.
    ///
    /// - Parameter color: A
    ///   [CGColor](https://developer.apple.com/documentation/CoreGraphics/CGColor) instance
    ///   from which to create a color.
    @available(iOS, deprecated: 100000.0, message: "Use Color(cgColor:) when converting a CGColor, or create a standard Color directly")
    @available(macOS, deprecated: 100000.0, message: "Use Color(cgColor:) when converting a CGColor, or create a standard Color directly")
    @available(tvOS, deprecated: 100000.0, message: "Use Color(cgColor:) when converting a CGColor, or create a standard Color directly")
    @available(watchOS, deprecated: 100000.0, message: "Use Color(cgColor:) when converting a CGColor, or create a standard Color directly")
    @available(visionOS, deprecated: 100000.0, message: "Use Color(cgColor:) when converting a CGColor, or create a standard Color directly")
    public init(_ cgColor: CGColor) {
        self.init(cgColor: cgColor)
    }
}

extension Color {
    /// Creates a color from a Core Graphics color.
    ///
    /// - Parameter color: A
    ///   [CGColor](https://developer.apple.com/documentation/CoreGraphics/CGColor) instance
    ///   from which to create a color.
    public init(cgColor: CGColor) {
        self.init(provider: cgColor)
    }
}

extension CGColor: ColorProvider {
    package func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        Color.Resolved(self)
    }
    
    package var staticColor: CGColor? {
        self
    }
}

extension Color.Resolved {
    package static let srgb: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    package static let srgbExtended: CGColorSpace = CGColorSpace(name: CGColorSpace.extendedSRGB)!
    package static let srgbLinear: CGColorSpace = CGColorSpace(name: CGColorSpace.linearSRGB)!
    package static let srgbExtendedLinear: CGColorSpace = CGColorSpace(name: CGColorSpace.extendedLinearSRGB)!
    package static let displayP3: CGColorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
    
    package init(_ cgColor: CGColor) {
        self = Color.Resolved(failableCGColor: cgColor) ?? .init(linearWhite: 0)
    }
    
    package init?(failableCGColor cgColor: CGColor) {
        let colorSpace: Color.RGBColorSpace
        let convertedColor: CGColor
        switch cgColor.colorSpace {
            case Color.Resolved.srgb, Color.Resolved.srgbExtended:
                colorSpace = .sRGB
                convertedColor = cgColor
            case Color.Resolved.srgbLinear, Color.Resolved.srgbExtendedLinear:
                colorSpace = .sRGBLinear
                convertedColor = cgColor
            case Color.Resolved.displayP3:
                colorSpace = .displayP3
                convertedColor = cgColor
            default:
                guard let color = cgColor.converted(to: Color.Resolved.srgbExtended, intent: .defaultIntent, options: nil) else {
                    return nil
                }
                colorSpace = .sRGB
                convertedColor = color
        }
        guard let components = convertedColor.components else {
            return nil
        }
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        let alpha = Float(cgColor.alpha)
        self.init(colorSpace: colorSpace, red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension Color.Resolved {
    private static let cache: ObjectCache<Color.Resolved, CGColor> = ObjectCache { resolved in
        var components: [CGFloat] = [CGFloat(resolved.red), CGFloat(resolved.green), CGFloat(resolved.blue), CGFloat(resolved.opacity)]
        return CGColor(colorSpace: Self.srgbExtended, components: &components)!
    }
    
    public var cgColor: CGColor {
        Self.cache[self]
    }
}

// MARK: - ResolvedGradient + CGGradient

#if canImport(CoreGraphics)

extension ResolvedGradient {
    package var cgGradient: CGGradient? {
        CGGradient(
            colorsSpace: Color.Resolved.srgbExtended,
            colors: stops.map { $0.color.cgColor } as CFArray,
            locations: stops.map(\.location)
        )
    }
}

#endif
