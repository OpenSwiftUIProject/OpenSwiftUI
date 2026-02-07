//
//  ResolvedMulticolorStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - ResolvedMulticolorStyle

package struct ResolvedMulticolorStyle: Equatable, @unchecked Sendable {
    package var accentColor: Color.Resolved

    package var colorScheme: ColorScheme

    package var colorSchemeContrast: ColorSchemeContrast

    package var displayGamut: DisplayGamut

    package var bundle: Bundle?

    package init(in environment: EnvironmentValues, bundle: Bundle?) {
        self.accentColor = environment.resolvedTintColor
        self.colorScheme = environment.colorScheme
        self.colorSchemeContrast = environment.colorSchemeContrast
        self.displayGamut = environment.displayGamut
        self.bundle = bundle
    }

    package var environment: EnvironmentValues {
        var env = EnvironmentValues()
        env.colorScheme = colorScheme
        env._colorSchemeContrast = colorSchemeContrast
        env.displayGamut = displayGamut
        return env
    }

    package func resolve(name: String?, proposed: Color.Resolved) -> Color.Resolved? {
        if let name {
            return resolve(name: name)
        } else {
            return proposed
        }
    }

    package func resolve(name: String) -> Color.Resolved? {
        switch name {
        case "controlAccentColor":
            return accentColor
        case "white":
            return .white
        case "black":
            return .black
        default:
            return Color.Resolved.named(name, bundle: bundle, environment: environment)
        }
    }

    package static func == (a: ResolvedMulticolorStyle, b: ResolvedMulticolorStyle) -> Bool {
        a.accentColor == b.accentColor
            && a.colorScheme == b.colorScheme
            && a.colorSchemeContrast == b.colorSchemeContrast
            && a.displayGamut == b.displayGamut
            && a.bundle == b.bundle
    }
}
