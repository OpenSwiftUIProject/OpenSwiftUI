//
//  SwitchToggleStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1246D37251EA3A918B392E2B95F8B7EF (SwiftUI)

@_spi(Private)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - ToggleStyle + SwitchToggleStyle

extension ToggleStyle where Self == SwitchToggleStyle {
    /// A toggle style that displays a leading label and a trailing switch.
    ///
    /// Apply this style to a ``Toggle`` or to a view hierarchy that contains
    /// toggles using the ``View/toggleStyle(_:)`` modifier:
    ///
    ///     Toggle("Enhance Sound", isOn: $isEnhanced)
    ///         .toggleStyle(.switch)
    ///
    /// The style produces a label that describes the purpose of the toggle
    /// and a switch that shows the toggle's state. The user taps or clicks
    /// the switch to change the toggle's state. The default appearance is
    /// similar across platforms, although the way you use switches in your
    /// user interface varies a little, as described in
    /// [Toggles](https://developer.apple.com/design/human-interface-guidelines/toggles)
    /// in the Human Interface Guidelines.
    ///
    /// @TabNavigator {
    ///     @Tab("iOS") {
    ///         @Image(source: "ToggleStyle-switch-1-iOS", alt: "A screenshot of the text On appearing to the left of a toggle switch that's on. The toggle's tint color is green. The toggle and its text appear in a rounded rectangle, and are aligned with opposite edges of the rectangle.")
    ///     }
    ///     @Tab("macOS") {
    ///         @Image(source: "ToggleStyle-switch-1-macOS", alt: "A screenshot of the text On appearing to the left of a toggle switch that's on. The toggle's tint color is blue. The toggle and its text are adjacent to each other.")
    ///     }
    ///     @Tab("watchOS") {
    ///         @Image(source: "ToggleStyle-switch-1-watchOS", alt: "A screenshot of the text On appearing to the left of a toggle switch that's on. The toggle's tint color is green. The toggle and its text appear in a rounded rectangle, and are aligned with opposite edges of the rectangle.")
    ///     }
    ///     @Tab("tvOS") {
    ///         @Image(source: "ToggleStyle-automatic-2-tvOS", alt: "A screenshot of three buttons labeled Show Lyrics, Shuffle, and Repeat, stacked vertically. The first is highlighted. The second is on, while the others are off.")
    ///     }
    /// }
    ///
    /// In iOS, iPadOS, watchOS, and tvOS, the label and switch fill as much
    /// horizontal space as the toggle's parent offers by aligning the label's
    /// leading edge and the switch's trailing edge with the containing view's
    /// respective leading and trailing edges. In macOS, the style uses a
    /// minimum of horizontal space by aligning the trailing edge of the label
    /// with the leading edge of the switch. OpenSwiftUI helps you to manage the
    /// spacing and alignment when this style appears in a ``Form``.
    ///
    /// OpenSwiftUI uses this style as the default for iOS, iPadOS, watchOS, and
    /// tvOS in most contexts when you don't set a style, or when you apply
    /// the ``ToggleStyle/automatic`` style.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var `switch`: SwitchToggleStyle {
        .init()
    }
}

// MARK: - SwitchToggleStyle

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

    public func makeBody(configuration: Configuration) -> some View {
        LabeledContent {
            #if os(iOS) || os(visionOS)
            Switch(isOn: configuration.$isOn, tint: tint ?? controlTint, thumbTint: placementTint[.switchThumb], font: font)
                .fixedSize()
                .contentShape(Capsule())
                .accessibilityConfiguration(AccessibilityToggleModifier.Switch())
            #elseif os(macOS)
            Switch(isOn: configuration.$isOn, tint: tint ?? controlTint, font: font)
                .fixedSize()
                .modifier(
                    _EnvironmentKeyTransformModifier(keyPath: \.explicitControlSize) { size in
                        if size == nil {
                            size = .mini
                        }
                    }
                    .requiring(GroupedFormStyleContext.self)
                )
                .layoutValue(key: TopAlignedFormValueKey.self, value: controlSize == .large)
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        } label: {
            configuration.label
        }
        .listLabeledContentPrefersHorizontalLayout()
        .accessibilityLabeledContent()
        #if os(iOS) || os(visionOS)
        .modifier(FocusEventProxyModifier())
        .gesture(PhysicalButtonPressGesture(allowedButtonTypes: [.select]).onEnded { _ in
            configuration.isOn.toggle()
        })
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

// MARK: - AccessibilityToggleModifier.Switch

#if os(iOS) || os(visionOS)
extension AccessibilityToggleModifier {
    struct Switch: AccessibilityConfigurationModifier {
        func body(content: Content) -> some View {
            content
                .accessibilityCaptureViewResponders()
                .accessibilityAddTraits(.isSwitch)
                .accessibilityIgnoreViewResponders()
        }
    }
}
#endif

// MARK: - Switch

#if os(iOS) || os(visionOS)
typealias PlatformSwitch = UISwitch

private struct Switch: UIViewRepresentable {
    @Binding var isOn: Bool
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
        let transaction = context.transaction
        Update.enqueueAction(reason: nil) { [transaction] in
            uiView.setOn(isOn, animated: !transaction.disablesAnimations)
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
private final class PlatformSwitch: NSSwitch, AcceptsFirstMouseCustomizing {
    var customAcceptsFirstMouse: Bool?

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        if ResponderBasedHitTesting.isEnabled {
            customAcceptsFirstMouse ?? super.acceptsFirstMouse(for: event)
        } else {
            effectiveAcceptsFirstMouse ?? super.acceptsFirstMouse(for: event)
        }
    }
}

private struct Switch: NSViewRepresentable {
    @Binding var isOn: Bool
    var tint: Color?
    var font: Font
    @Environment(\.allowsWindowActivationEvents) var acceptsFirstMouse: Bool?

    func makeNSView(context: Context) -> PlatformSwitch {
        let view = PlatformSwitch()
        view.target = context.coordinator
        view.action = #selector(PlatformSwitchCoordinator.isOnChanged)
        return view
    }

    func updateNSView(_ nsView: PlatformSwitch, context: Context) {
        let isOn = isOn
        if context.transaction.disablesAnimations {
            nsView.state = isOn ? .on : .off
        } else {
            nsView.animator().state = isOn ? .on : .off
        }
        context.coordinator._isOn = _isOn
        nsView.font = font.platformFont(in: context.environment)
        if let superview = nsView.superview {
            let appearance = superview.effectiveAppearance
            nsView.appearance = if let tint, tint != Color.accentColor {
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
#elseif os(macOS)
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
