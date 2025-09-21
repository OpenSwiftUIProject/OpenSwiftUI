//
//  SwitchToggleStyle.swift
//  OpenSwiftUI
//
//  Audited for iOS 6.5.4
//  Status: WIP
//  ID: 1246D37251EA3A918B392E2B95F8B7EF (SwiftUI)

import OpenSwiftUICore

// MARK: - SwitchToggleStyle [WIP]

extension ToggleStyle where Self == SwitchToggleStyle {
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var `switch`: SwitchToggleStyle {
        .init()
    }
}

/// A toggle style that displays a leading label and a trailing switch.
///
/// Use the ``ToggleStyle/switch`` static variable to create this style:
///
///     Toggle("Enhance Sound", isOn: $isEnhanced)
///         .toggleStyle(.switch)
///
@available(OpenSwiftUI_v1_0, *)
public struct SwitchToggleStyle: ToggleStyle {
    @Environment(\.controlSize)
    private var controlSize: ControlSize

//    @Environment(\.tintColor)
//    private var controlTint: Color?

//    @Environment(\.placementTint)
//    private var placementTint: [TintPlacement: AnyShapeStyle]

    @Environment(\.effectiveFont)
    private var font: Font

    let tint: Color?

    /// Creates a switch toggle style.
    ///
    /// Don't call this initializer directly. Instead, use the
    /// ``ToggleStyle/switch`` static variable to create this style:
    ///
    ///     Toggle("Enhance Sound", isOn: $isEnhanced)
    ///         .toggleStyle(.switch)
    ///
    public init() {
        tint = nil
    }

    /// Creates a switch style with a tint color.
    @available(OpenSwiftUI_v2_0, *)
    @available(*, deprecated, message: "Use ``View/tint(_)`` instead.")
    @available(tvOS, unavailable)
    public init(tint: Color) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        #if canImport(Darwin)
        Switch(isOn: configuration.$isOn, tint: tint)
            .fixedSize()
            // .contentShape(Capsule())
            // .accessibilityLabel
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}

@available(*, unavailable)
extension SwitchToggleStyle: Sendable {}

#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Switch [WIP]

#if os(iOS) || os(visionOS)
private struct Switch: UIViewRepresentable {
    typealias UIViewType = UISwitch

    typealias Coordinator = PlatformSwitchCoordinator

    @Binding var isOn: Bool

    var tint: Color?

    func makeUIView(context: Context) -> UISwitch {
        let view = UISwitch()
        view.addTarget(
            context.coordinator,
            action: #selector(PlatformSwitchCoordinator.isOnChanged),
            for: .valueChanged
        )
        return view
    }

    func updateUIView(_ uiView: UISwitch, context: Context) {
        let isOn = isOn
        let animated: Bool
        if let _ = context.transaction.animation, !context.transaction.disablesAnimations {
            animated = true
        } else {
            animated = false
        }
        uiView.setOn(isOn, animated: animated)
        uiView.preferredStyle = .sliding

        let color: UIColor?
        if let _ = tint {
            // TODO: Resolve the color from the environment
            color = nil
        } else {
            color = nil
        }
        let onTintColor = uiView.onTintColor
        if let color {
            if onTintColor == nil || color != onTintColor {
                uiView.onTintColor = color
            }
        } else {
            if onTintColor != nil {
                uiView.onTintColor = nil
            }
        }
        context.coordinator._isOn = $isOn
    }
    func makeCoordinator() -> Coordinator {
        PlatformSwitchCoordinator(isOn: $isOn)
    }
}
#elseif os(macOS)
private struct Switch: NSViewRepresentable {
    typealias NSViewType = NSSwitch

    typealias Coordinator = PlatformSwitchCoordinator

    @Binding var isOn: Bool

    var tint: Color?

    func makeNSView(context: Context) -> NSSwitch {
        let view = NSSwitch()
        return view
    }

    func updateNSView(_ nsView: NSSwitch, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        PlatformSwitchCoordinator(isOn: $isOn)
    }
}
#endif


// MARK: - PlatformSwitchCoordinator

#if os(iOS) || os(visionOS)
private class PlatformSwitchCoordinator: PlatformViewCoordinator {
    var _isOn: Binding<Bool>

    var isOn: Bool {
        get { _isOn.wrappedValue }
        set { _isOn.wrappedValue = newValue }
    }

    init(isOn: Binding<Bool>) {
        _isOn = isOn
        super.init()
    }

    @objc
    func isOnChanged(_ sender: UISwitch) {
        weakDispatchUpdate {
            isOn = sender.isOn
        }
        sender.setOn(isOn, animated: !_isOn.transaction.disablesAnimations)
    }
}
#else
private class PlatformSwitchCoordinator: PlatformViewCoordinator {
    var _isOn: Binding<Bool>

    var isOn: Bool {
        get { _isOn.wrappedValue }
        set { _isOn.wrappedValue = newValue }
    }

    init(isOn: Binding<Bool>) {
        _isOn = isOn
        super.init()
    }

    @objc
    func isOnChanged(_ sender: NSSwitch) {
        weakDispatchUpdate {
            isOn = sender.state == .on
        }
        if _isOn.transaction.disablesAnimations {
            sender.state = isOn ? .on : .off
        } else {
            sender.animator().state = isOn ? .on : .off
        }
    }
}
#endif
