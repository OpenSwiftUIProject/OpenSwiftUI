//
//  BorderedButtonStyle_CarMac.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP (TBA)
//  ID: 5EE504DA55D2DCE4B6A4398A8AB30726 (SwiftUI)

import Foundation
import OpenSwiftUICore
#if os(macOS)
import AppKit
#endif

// MARK: - BorderedButtonStyle_CarMac

struct BorderedButtonStyle_CarMac: PrimitiveButtonStyle {
    let tint: Color?
    var isProminent: Bool

    init(tint: Color?, isProminent: Bool) {
        self.tint = tint
        self.isProminent = isProminent
    }

    func makeBody(configuration: Configuration) -> some View {
        _UnaryViewAdaptor(BorderedButton(
            tint: tint,
            isProminent: isProminent,
            configuration: configuration
        ))
    }
}

// MARK: - EnforceButtonDestructiveRoleAppearance

struct EnforceButtonDestructiveRoleAppearance: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var enforceButtonDestructiveRoleAppearance: Bool {
        get { self[EnforceButtonDestructiveRoleAppearance.self] }
        set { self[EnforceButtonDestructiveRoleAppearance.self] = newValue }
    }
}

#if os(macOS)
extension View {
    func enforceButtonDestructiveRoleAppearance(_ enforce: Bool) -> some View {
        environment(\.enforceButtonDestructiveRoleAppearance, enforce)
    }
}
#endif

// MARK: - BorderedButton [TBA]

private struct BorderedButton: View {
    let tint: Color?
    var isProminent: Bool
    var configuration: PrimitiveButtonStyleConfiguration

    @Environment(\.isEnabled)
    var isEnabled: Bool

    @Environment(\.isInTouchBar)
    var isInTouchBar: Bool

    @Environment(\.tintColor)
    var controlTint: Color?

    @Environment(\.isToggleOn)
    var isOn: Bool?

    @Environment(\.buttonBorderShape)
    var borderShape: ButtonBorderShape

    @Environment(\.enforceButtonDestructiveRoleAppearance)
    var forceDestructiveAppearance: Bool

    #if os(macOS)
    var effectiveTint: Color? {
        guard isProminent, isOn != false else {
            return nil
        }
        return tint ?? controlTint ?? .accentColor
    }

    func effectiveForeground(forRole role: ButtonRole?) -> Color? {
        guard role == .destructive, forceDestructiveAppearance else {
            return nil
        }
        return Color("_NSDestructiveActionControlTextColor", bundle: .kit)
    }
    #endif

    var body: some View {
        #if os(macOS)
        Button(configuration)
            .modifier(
                PrimitiveButtonStyleContainerModifier(
                    style: AppKitButtonStyle(appearance: toolbarButtonAppearance)
                )
                .requiring(ToolbarStyleContext.self)
            )
            .modifier(
                PrimitiveButtonStyleContainerModifier(style: PlatformItemListButtonStyle())
                    .requiring(ControlGroupStyleContext.self)
            )
            .modifier(
                PrimitiveButtonStyleContainerModifier(style: PlatformItemListButtonStyle())
                    .requiring(MenuStyleContext.self)
            )
            .buttonStyle(AppKitButtonStyle(appearance: defaultButtonAppearance))
            .foregroundColor(effectiveForeground(forRole: configuration.role))
            .dynamicToolbarStyleContext()
        #else
        // TODO: UIKitButton, UIKitSystemButtonConfigurationModifier, ToolbarButtonLabelModifier
        _openSwiftUIUnimplementedFailure()
        #endif
    }

    #if os(macOS)
    var toolbarButtonAppearance: AppKitButtonAppearance {
        if isInTouchBar {
            return AppKitButtonAppearance(
                bezelStyle: AllowsVerticallyFlexibleMacButtons.isEnabled ? .init(rawValue: 28)! : .push,
                tint: effectiveTint,
                isInToolbar: false
            )
        } else {
            return AppKitButtonAppearance(
                bezelStyle: .toolbar,
                tint: effectiveTint,
                isInToolbar: true
            )
        }
    }

    var defaultButtonAppearance: AppKitButtonAppearance {
        let bezelStyle: NSButton.BezelStyle
        switch borderShape.guts {
        case .circle:
            bezelStyle = .circular
        default:
            bezelStyle = AllowsVerticallyFlexibleMacButtons.isEnabled ? .init(rawValue: 28)! : .push
        }
        return AppKitButtonAppearance(
            bezelStyle: bezelStyle,
            tint: effectiveTint,
            isInToolbar: false
        )
    }
    #else
    var carPlayPaddingModifier: some ViewModifier {
        StaticIf(
            idiom: .carPlay,
            then: _PaddingLayout(insets: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)),
            else: EmptyModifier()
        )
    }
    #endif
}
