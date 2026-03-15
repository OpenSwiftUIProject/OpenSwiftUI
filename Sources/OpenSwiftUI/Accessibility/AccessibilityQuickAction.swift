//
//  AccessibilityQuickAction.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: TODO
//  ID: B8D2E4520F2964BB14185EE65411F685 (SwiftUI)

#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif
import OpenSwiftUICore

// MARK: - AccessibilityQuickActionProxy [TODO]

private class AccessibilityQuickActionProxy {
    @Published var state: AccessibilityQuickActionState = .inactive
    var label: String?
    var isActive: Binding<Bool>?
    var action: (() -> Void)?
    var isEnabled: Bool = true
    let style: _AccessibilityQuickActionStyle.RawValue

    init(style: _AccessibilityQuickActionStyle.RawValue) {
        self.style = style
    }
}

// MARK: - _AccessibilityQuickActionStyle

@available(OpenSwiftUI_v4_0, *)
public struct _AccessibilityQuickActionStyle {
    enum RawValue: Equatable {
        case prompt
        case outline
    }

    let rawValue: RawValue
}

@available(*, unavailable)
extension _AccessibilityQuickActionStyle: Sendable {}

// MARK: - AccessibilityQuickActionStyle

/// A type that describes the presentation style of an
/// accessibility quick action.
@available(OpenSwiftUI_v4_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
public protocol AccessibilityQuickActionStyle {
    var _style: _AccessibilityQuickActionStyle { get }
}

// MARK: - AccessibilityQuickActionPromptStyle

/// A presentation style that displays a prompt to the user when
/// the accessibility quick action is active.
///
/// Don't use this type directly. Instead, use ``AccessibilityQuickActionStyle/prompt``.
@available(OpenSwiftUI_v4_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
public struct AccessibilityQuickActionPromptStyle: AccessibilityQuickActionStyle {
    public var _style: _AccessibilityQuickActionStyle {
        .init(rawValue: .prompt)
    }

    @usableFromInline
    init() {}
}

@available(*, unavailable)
extension AccessibilityQuickActionPromptStyle: Sendable {}

@available(OpenSwiftUI_v4_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
extension AccessibilityQuickActionStyle where Self == AccessibilityQuickActionPromptStyle {
    @_alwaysEmitIntoClient
    public static var prompt: AccessibilityQuickActionPromptStyle {
        AccessibilityQuickActionPromptStyle()
    }
}

// MARK: - AccessibilityQuickActionOutlineStyle

/// A presentation style that displays a prompt to the user when
/// the accessibility quick action is active.
///
/// Don't use this type directly. Instead, use ``AccessibilityQuickActionStyle/outline``.
@available(OpenSwiftUI_v4_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
public struct AccessibilityQuickActionOutlineStyle: AccessibilityQuickActionStyle {
    public var _style: _AccessibilityQuickActionStyle {
        .init(rawValue: .outline)
    }

    @usableFromInline
    init() {}
}

@available(OpenSwiftUI_v4_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
extension AccessibilityQuickActionStyle where Self == AccessibilityQuickActionOutlineStyle {
    @_alwaysEmitIntoClient
    public static var outline: AccessibilityQuickActionOutlineStyle {
        AccessibilityQuickActionOutlineStyle()
    }
}

// MARK: - AccessibilityQuickActionState

enum AccessibilityQuickActionState {
    case inactive
    case willHint
    case willPulse
    case willActivate
}

// MARK: - AccessibilityQuickActionsKey

private struct AccessibilityQuickActionsKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

// MARK: - EnvironmentValues + AccessibilityQuickActions

extension EnvironmentValues {

    /// A Boolean that indicates whether the quick actions feature is enabled.
    ///
    /// The system uses quick actions to provide users with a
    /// fast alternative interaction method. Quick actions can be
    /// presented to users with a textual banner at the top of their
    /// screen and/or an outline around a view that is already on screen.
    @available(OpenSwiftUI_v4_0, *)
    public var accessibilityQuickActionsEnabled: Bool {
        self[AccessibilityQuickActionsKey.self]
    }

    @available(OpenSwiftUI_v4_0, *)
    public var _accessibilityQuickActionsEnabled: Bool {
        get { self[AccessibilityQuickActionsKey.self] }
        set { self[AccessibilityQuickActionsKey.self] = newValue }
    }
}

// MARK: - View + AccessibilityQuickAction

@available(OpenSwiftUI_v4_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
extension View {

    /// Adds a quick action to be shown by the system when active.
    ///
    /// The quick action will automatically become active when the
    /// view appears. If the view is disabled, the action will defer
    /// becoming active until the view is no longer disabled.
    ///
    /// The following example shows how to add a quick action to
    /// pause and resume a workout, with the ``AccessibilityQuickActionStyle/prompt`` style.
    ///
    ///     @State private var isPaused = false
    ///
    ///     var body: some View {
    ///         WorkoutView(isPaused: $isPaused)
    ///             .accessibilityQuickAction(style: .prompt) {
    ///                 Button(isPaused ? "Resume" : "Pause") {
    ///                     isPaused.toggle()
    ///                 }
    ///             }
    ///     }
    ///
    /// The following example shows how to add a quick action to
    /// play and pause music, with the ``AccessibilityQuickActionStyle/outline`` style.
    ///
    ///     @State private var isPlaying = false
    ///
    ///     var body: some View {
    ///         PlayButton(isPlaying: $isPlaying)
    ///             .contentShape(.focusEffect, Circle())
    ///             .accessibilityQuickAction(style: .outline) {
    ///                 Button(isPlaying ? "Pause" : "Play") {
    ///                     isPlaying.toggle()
    ///                 }
    ///             }
    ///     }
    ///
    public func accessibilityQuickAction<Style: AccessibilityQuickActionStyle, Content: View>(
        style: Style,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            AccessibilityQuickActionModifier(
                content: content(),
                style: style._style.rawValue
            )
        )
    }

    /// Adds a quick action to be shown by the system when active.
    ///
    /// The following example shows how to add a quick action to
    /// pause and resume a workout, with the ``AccessibilityQuickActionStyle/prompt`` style.
    ///
    ///     @State private var isPaused = false
    ///     @State private var isQuickActionActive = false
    ///
    ///     var body: some View {
    ///         WorkoutView(isPaused: $isPaused)
    ///             .accessibilityQuickAction(style: .prompt, isActive: $isQuickActionActive) {
    ///                 Button(isPaused ? "Resume" : "Pause") {
    ///                     isPaused.toggle()
    ///                 }
    ///             }
    ///     }
    ///
    /// The following example shows how to add a quick action to
    /// play and pause music, with the ``AccessibilityQuickActionStyle/outline`` style.
    ///
    ///     @State private var isPlaying = false
    ///     @State private var isQuickActionActive = false
    ///
    ///     var body: some View {
    ///         PlayButton(isPlaying: $isPlaying)
    ///             .contentShape(.focusEffect, Circle())
    ///             .accessibilityQuickAction(style: .outline, isActive: $isQuickActionActive) {
    ///                 Button(isPlaying ? "Pause" : "Play") {
    ///                     isPlaying.toggle()
    ///                 }
    ///             }
    ///     }
    ///
    public func accessibilityQuickAction<Style: AccessibilityQuickActionStyle, Content: View>(
        style: Style,
        isActive: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            AccessibilityQuickActionModifier(
                content: content(),
                isActive: isActive,
                style: style._style.rawValue
            )
        )
    }
}


// MARK: - AccessibilityQuickActionModifier [WIP]

private struct AccessibilityQuickActionModifier<Content>: MultiViewModifier, PrimitiveViewModifier where Content: View {
    var content: Content
    var isActive: Binding<Bool>?
    var style: _AccessibilityQuickActionStyle.RawValue

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        _openSwiftUIPlatformUnimplementedFailure()
    }
}
