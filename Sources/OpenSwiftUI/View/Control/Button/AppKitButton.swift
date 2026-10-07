//
//  AppKitButton.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Partial-Stubbed
//  ID: 9FEBA96B0BC70E1682E82D239F242E73 (SwiftUI)

#if os(macOS)
import AppKit
import OpenSwiftUICore

// MARK: - AppKitButtonStyle

struct AppKitButtonStyle: PrimitiveButtonStyle {
    var appearance: AppKitButtonAppearance

    func makeBody(configuration: Configuration) -> some View {
        Content(appearance: appearance, configuration: configuration)
    }

    struct Content: EnvironmentalView {
        var appearance: AppKitButtonAppearance
        var configuration: PrimitiveButtonStyleConfiguration

        func body(environment: EnvironmentValues) -> some View {
            // TODO: AppKitButtonConfiguration, AppKitButton, CoordinateSpaceNameModifier
            _openSwiftUIUnimplementedFailure()
        }
    }
}

// MARK: - AppKitButtonAppearance

struct AppKitButtonAppearance {
    let bezelStyle: NSButton.BezelStyle
    let isBordered: Bool
    private let tint: Tint?
    let showsBorderOnHover: Bool
    private let heightBehavior: HeightBehavior
    let isInToolbar: Bool

    static func borderless(tint: Color?) -> AppKitButtonAppearance {
        AppKitButtonAppearance(
            bezelStyle: .flexiblePush,
            isBordered: false,
            tint: tint.map { .content($0) },
            showsBorderOnHover: false,
            heightBehavior: .flexible,
            isInToolbar: false
        )
    }

    private enum Tint {
        case bezel(Color)
        case content(Color)
    }

    private enum HeightBehavior: Hashable {
        case fixed
        case fixedWithFlexibleFallback
        case flexible
    }

    // TODO: Resolved, accessoryBarAction, link
}

// TODO: AppKitButtonConfiguration, AppKitButton

#endif
