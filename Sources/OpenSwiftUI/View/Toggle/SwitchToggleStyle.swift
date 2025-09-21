//
//  SwitchToggleStyle.swift
//  OpenSwiftUI
//
//  Audited for iOS 6.5.4
//  Status: WIP
//  ID: 1246D37251EA3A918B392E2B95F8B7EF (SwiftUI)

@_spi(Private)
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

    @Environment(\.tintColor)
    private var controlTint: Color?

    #if os(iOS) || os(visionOS)
    @Environment(\.placementTint)
    private var placementTint: [TintPlacement: AnyShapeStyle]
    #endif

    @Environment(\.effectiveFont)
    private var font: Font

    private let tint: Color?

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

    // FIXME
    public func makeBody(configuration: Configuration) -> some View {
        #if os(iOS) || os(visionOS)
        Switch(_isOn: configuration.$isOn, tint: tint, thumbTint: placementTint[.switchThumb], font: font)
            .fixedSize()
            // .contentShape(Capsule())
            // .accessibilityLabel
            // .gesture
        #elseif os(macOS)
        Switch(_isOn: configuration.$isOn, tint: tint, font: font, _acceptsFirstMouse: .init(\.acceptsFirstMouse))
            .fixedSize()
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

// MARK: - Switch

#if os(iOS) || os(visionOS)
typealias PlatformSwitch = UISwitch

private struct Switch: UIViewRepresentable {
    var _isOn: Binding<Bool>
    var tint: Color?
    var thumbTint: AnyShapeStyle?
    var font: Font

    func makeUIView(context: Context) -> PlatformSwitch {
        let view = PlatformSwitch()
        view.addTarget(
            context.coordinator,
            action: #selector(PlatformSwitchCoordinator.isOnChanged),
            for: .valueChanged
        )
        return view
    }

    func updateUIView(_ uiView: PlatformSwitch, context: Context) {
        let isOn = _isOn.wrappedValue
        let transaction = context.transaction
        Update.enqueueAction(reason: nil) { [transaction] in
            uiView.setOn(isOn, animated: transaction.disablesAnimations)
        }
        uiView.preferredStyle = .sliding
        let newTintColor: UIColor? = if let tint {
            (tint.resolve(in: context.environment).kitColor as! UIColor)
        } else {
            nil
        }
        if newTintColor != uiView.onTintColor {
            uiView.onTintColor = newTintColor
        }
        if let thumbTint, let thumbColor = thumbTint.fallbackColor(in: context.environment) {
            let newThumbColor = thumbColor.resolve(in: context.environment).kitColor as! UIColor
            if newThumbColor != uiView.thumbTintColor {
                uiView.thumbTintColor = newThumbColor
            }
        }
        context.coordinator._isOn = _isOn
    }
    func makeCoordinator() -> PlatformSwitchCoordinator {
        PlatformSwitchCoordinator(isOn: _isOn)
    }
}
#elseif os(macOS)
// FIXME
protocol AcceptsFirstMouseCustomizing {
    var customAcceptsFirstMouse: Bool? { get }
}

extension AcceptsFirstMouseCustomizing {
    var effectiveAcceptsFirstMouse: Bool? {
        // FIXME: Find via view hierarchy if not set directly
        customAcceptsFirstMouse
    }
}

extension EnvironmentValues {
    var acceptsFirstMouse: Bool? {
        // FIXME
        get { controlSize == .mini }
    }
}

private final class PlatformSwitch: NSSwitch, AcceptsFirstMouseCustomizing {
    var customAcceptsFirstMouse: Bool?

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        if ResponderBasedHitTesting.enabled {
            customAcceptsFirstMouse ?? super.acceptsFirstMouse(for: event)
        } else {
            effectiveAcceptsFirstMouse ?? super.acceptsFirstMouse(for: event)
        }
    }
}

private struct Switch: NSViewRepresentable {
    var _isOn: Binding<Bool>
    var tint: Color?
    var font: Font
    var _acceptsFirstMouse: Environment<Bool?>

    func makeNSView(context: Context) -> PlatformSwitch {
        let view = PlatformSwitch()
        view.target = context.coordinator
        return view
    }

    func updateNSView(_ nsView: PlatformSwitch, context: Context) {
        let isOn = _isOn.wrappedValue
        if context.transaction.disablesAnimations {
            nsView.state = isOn ? .on : .off
        } else {
            nsView.animator().state = isOn ? .on : .off
        }
        context.coordinator._isOn = _isOn
        nsView.font = font.platformFont(in: context.environment)
        if let superview = nsView.superview {
            let appearance = superview.effectiveAppearance
            nsView.appearance = if let tint, tint != Color.accent {
                appearance.applyingTintColor(.init(tint))
            } else {
                nil
            }
        }
        nsView.customAcceptsFirstMouse = _acceptsFirstMouse.wrappedValue
    }

    func makeCoordinator() -> PlatformSwitchCoordinator {
        PlatformSwitchCoordinator(isOn: _isOn)
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
