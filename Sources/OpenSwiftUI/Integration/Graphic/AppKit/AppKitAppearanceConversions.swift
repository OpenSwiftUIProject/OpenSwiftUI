//
//  AppKitAppearanceConversions.swift
//  OpenSwiftUI
//
//  Status: WIP
//  ID: FE0226775232C57AACFCDAD271FF7831 (SwiftUI)

#if canImport(AppKit)

import AppKit
import COpenSwiftUI

// MARK: - NSAppearance Conversions [6.5.4]

extension NSAppearance {
    func apply(to environment: inout EnvironmentValues, vibrantBlendingStyle: NSViewVibrantBlendingStyle) {
        // TODO
    }

    convenience init?(_ scheme: ColorScheme) {
        // TODO
        return nil
    }

    var bestColorScheme: ColorScheme? {
        // TODO
        nil
    }

//    static func makeAppearance(_ appearance: _ResolvedAppearance) -> NSAppearance? {
//        // TODO
//        nil
//    }

    static func appearance(from environment: EnvironmentValues, allowsVibrantBlending: Bool?) -> NSAppearance? {
        // TODO
        nil
    }
}

// private func lastAppearance(in appearance: _ResolvedAppearance) -> CatalogAppearance?

#endif
