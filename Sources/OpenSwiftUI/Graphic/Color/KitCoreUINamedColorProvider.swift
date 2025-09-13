//
//  KitCoreUINamedColorProvider.swift
//  OpenSwiftUI
//
//  Status: Complete

#if OPENSWIFTUI_LINK_COREUI

import CoreUI
import OpenSwiftUICore
#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct KitCoreUINamedColorProvider: CoreUINamedColorProvider {
    static func effectiveCGColor(cuiColor: CUINamedColor, in environment: EnvironmentValues) -> CGColor? {
        let name = cuiColor.systemColorName
        let selector = Selector(name)
        #if os(iOS) || os(visionOS) // 6.4.41
        guard UIColor.responds(to: selector) else {
            return nil
        }
        return withTraitCollection(
            cuiColor: cuiColor,
            environment: environment
        ) {
            let color = UIColor.perform(selector).takeRetainedValue() as! UIColor
            return color.cgColor
        }
        #elseif os(macOS) // 6.5.4
        guard NSColor.responds(to: selector) else {
            return nil
        }
        return withAppearance(cuiColor: cuiColor, environment: environment) {
            let color = NSColor.perform(selector).takeRetainedValue() as! NSColor
            return color.cgColor
        }
        #endif
    }

    #if os(iOS) || os(visionOS)
    @inline(__always)
    static func withTraitCollection(
        cuiColor: CUINamedColor,
        environment: EnvironmentValues,
        _ body: () -> CGColor
    ) -> CGColor {
        let current = UITraitCollection.current
        let collection = (environment[InheritedTraitCollectionKey.self] ?? .current).byOverriding(
            with: environment,
            viewPhase: .init(),
            focusedValues: .init()
        )
        UITraitCollection.current = collection
        defer { UITraitCollection.current = current }
        return body()
    }
    #elseif os(macOS)
    static func withAppearance(
        cuiColor: CUINamedColor,
        environment: EnvironmentValues,
        _ body: () -> CGColor
    ) -> CGColor? {
        // TODO
        return body()
    }
    #endif
}

#endif
