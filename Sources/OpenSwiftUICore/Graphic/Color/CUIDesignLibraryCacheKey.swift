//
//  CUIDesignLibraryCacheKey.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: WIP
//  ID: EBD1C829A869D5EC3C2FDA55F4467D9A (SwiftUICore?)

#if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
import OpenSwiftUI_SPI
package import CoreUI

package struct CUIDesignLibraryCacheKey: Hashable {
    package struct Entry: Hashable {
        package var color: Color.Resolved

        package var blendMode: BlendMode

        package init(color: Color.Resolved, blendMode: BlendMode) {
            self.color = color
            self.blendMode = blendMode
        }
    }

    @AtomicBox
    package static var cache: [CUIDesignLibraryCacheKey: CUIDesignLibraryCacheKey.Entry] = [:]

    package struct Props: Hashable, DerivedEnvironmentKey {
        package var scheme: ColorScheme
        package var contrast: ColorSchemeContrast
        package var gamut: DisplayGamut
        package var styling: CUIDesignStyling

        package static func value(in env: EnvironmentValues) -> Props {
            Props(
                scheme: env.colorScheme,
                contrast: env.colorSchemeContrast,
                gamut: env.displayGamut,
                styling: env.backgroundMaterial == nil
                    ? ._0
                    : (env.allowsVibrantBlending ? ._1 : ._2 )
            )
        }
    }

    package var name: CUIColorName

    package var props: CUIDesignLibraryCacheKey.Props

    package init(name: CUIColorName, in env: EnvironmentValues, allowsBlendMode: Bool = true) {
        self.name = name
        var props = env[Props.self]
        if !allowsBlendMode, props.styling == ._1 {
            props.styling = ._2
        }
        self.props = props
    }

    package func fetch() -> CUIDesignLibraryCacheKey.Entry {
        if let value = Self.cache[self] {
            return value
        } else {
            let entry: Entry
            if let color = try? CUIDesignLibrary.color(with:
                CUIDesignColorTraits(
                    name: name,
                    designSystem: 0,
                    palette: 0,
                    colorScheme: cuiColorScheme,
                    contrast: cuiColorSchemeContrast,
                    styling: cuiDesignStyling,
                    displayGamut: cuiDisplayGamut
                )
            ) {
                entry = Entry(
                    color: Color.Resolved(failableCGColor: color.cgColor) ?? .clear,
                    blendMode: BlendMode(color.blendMode)
                )
            } else {
                Log.internalWarning("A color was requested from CoreUI but was not found. Returning clear color instead.")
                entry = Entry(color: .clear, blendMode: .normal)
            }
            Self.cache[self] = entry
            return entry
        }
    }

    @inline(__always)
    var cuiColorScheme: CUIColorScheme {
        switch props.scheme {
        case .light: .light
        case .dark: .dark
        }
    }

    @inline(__always)
    var cuiColorSchemeContrast: CUIColorSchemeContrast {
        switch props.contrast {
        case .standard: .standard
        case .increased: .increased
        }
    }

    @inline(__always)
    var cuiDesignStyling: CUIDesignStyling {
        props.styling
    }

    package var cuiDisplayGamut: CUIDisplayGamut {
        switch props.gamut {
        case .sRGB: .SRGB
        case .displayP3: .P3
        }
    }
}
#endif
