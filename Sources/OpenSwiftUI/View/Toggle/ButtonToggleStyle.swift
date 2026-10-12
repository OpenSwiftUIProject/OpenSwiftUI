//
//  ButtonToggleStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: FAB054272EC923B321C919912F503583 (SwiftUI)

public import OpenSwiftUICore

// MARK: - ToggleStyle + ButtonToggleStyle

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
extension ToggleStyle where Self == ButtonToggleStyle {
    /// A toggle style that displays as a button with its label as the title.
    ///
    /// Apply this style to a ``Toggle`` or to a view hierarchy that contains
    /// toggles using the ``View/toggleStyle(_:)`` modifier:
    ///
    ///     Toggle(isOn: $isFlagged) {
    ///         Label("Flag", systemImage: "flag.fill")
    ///     }
    ///     .toggleStyle(.button)
    ///
    /// The style produces a button with a label that describes the purpose
    /// of the toggle. The user taps or clicks the button to change the
    /// toggle's state. The button indicates the `on` state by filling in the
    /// background with its tint color. You can change the tint color using
    /// the ``View/tint(_:)`` modifier. OpenSwiftUI uses this style as the
    /// default for toggles that appear in a toolbar.
    ///
    /// The following table shows the toggle in both the `off` and `on` states,
    /// respectively:
    ///
    ///   | Platform    | Appearance |
    ///   |-------------|------------|
    ///   | iOS, iPadOS | ![A screenshot of two buttons with a flag icon and the word flag inside. The first button isn't highlighted; the second one is.](ToggleStyle-button-1-iOS) |
    ///   | macOS       | ![A screenshot of two buttons with a flag icon and the word flag inside. The first button isn't highlighted; the second one is.](ToggleStyle-button-1-macOS) |
    ///
    /// A ``Label`` instance is a good choice for a button toggle's label.
    /// Based on the context, OpenSwiftUI decides whether to display both the title
    /// and icon, as in the example above, or just the icon, like when the
    /// toggle appears in a toolbar. You can also control the label's style
    /// by adding a ``View/labelStyle(_:)`` modifier. In any case, OpenSwiftUI
    /// always uses the title to identify the control using VoiceOver.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var button: ButtonToggleStyle {
        .init()
    }
}

// MARK: - ButtonToggleStyle

/// A toggle style that displays as a button with its label as the title.
///
/// You can also use ``ToggleStyle/button`` to construct this style.
///
///     Toggle(isOn: $isFlagged) {
///         Label("Flag", systemImage: "flag.fill")
///     }
///     .toggleStyle(.button)
///
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
public struct ButtonToggleStyle: ToggleStyle {
    @Environment(\.tintColor)
    private var controlTint: Color?

    private let tint: Color?

    /// Creates a button toggle style.
    ///
    /// Don't call this initializer directly. Instead, use the
    /// ``ToggleStyle/button`` static variable to create this style:
    ///
    ///     Toggle(isOn: $isFlagged) {
    ///         Label("Flag", systemImage: "flag.fill")
    ///     }
    ///     .toggleStyle(.button)
    ///
    public init() {
        tint = nil
    }

    public func makeBody(configuration: Configuration) -> some View {
        func toggleState() {
            configuration.isOn.toggle()
        }
        return Button(action: toggleState) {
            configuration.label
                .environment(\.defaultToggleIsOn, nil)
                .inputFalse(IsToggleButton.self)
        }
        .environment(\.defaultToggleIsOn, configuration.isOn)
        .input(IsToggleButton.self)
        .modifier(StaticIf(
            idiom: .widget,
            then: ButtonStyleModifier(style: WidgetBorderedProminentButtonStyle())
                .requiring(ButtonStylePredicate<DefaultButtonStyle>.self),
            else: EmptyModifier()
        ))
    }
}

@available(*, unavailable)
extension ButtonToggleStyle: Sendable {}

// MARK: - EnvironmentValues + ButtonToggleStyle

extension EnvironmentValues {
    @_spi(UIFrameworks)
    @available(OpenSwiftUI_v4_0, *)
    public var isToggleOn: Bool? {
        defaultToggleIsOn
    }

    var defaultToggleIsOn: Bool? {
        get { self[DefaultToggleIsOnKey.self] }
        set { self[DefaultToggleIsOnKey.self] = newValue }
    }
}

// MARK: - IsToggleButton

struct IsToggleButton: ViewInputBoolFlag {}

// MARK: - DefaultToggleIsOnKey

private struct DefaultToggleIsOnKey: EnvironmentKey {
    static let defaultValue: Bool? = nil
}
