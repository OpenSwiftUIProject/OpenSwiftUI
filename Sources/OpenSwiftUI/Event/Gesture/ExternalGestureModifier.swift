//
//  ExternalGestureModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 5C4016F384C56651B3106555DFC3249E (SwiftUI)

import Foundation
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
public import OpenSwiftUICore

// MARK: - View + HandGestureShortcut

@available(OpenSwiftUI_v6_0, *)
@available(visionOS, unavailable)
extension View {
    /// Assigns a hand gesture shortcut to the modified control.
    ///
    /// Performing the control's shortcut while the control is anywhere in the
    /// frontmost scene is equivalent to direct interaction with the control to
    /// perform its primary action.
    ///
    /// The following example lets users of a watchOS music app toggle playback
    /// by double-tapping their thumb and index finger together:
    ///
    ///     struct PlaybackControls: View {
    ///         let model: TrackModel
    ///
    ///         var body: some View {
    ///             HStack {
    ///                 Button("Skip Back") {
    ///                     model.skipBack()
    ///                 }
    ///
    ///                 Button("Play/Pause") {
    ///                     model.playPause()
    ///                 }
    ///                 .handGestureShortcut(.primaryAction)
    ///
    ///                 Button("Skip Forward") {
    ///                     model.skipForward()
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// The target of a hand gesture shortcut is resolved in a
    /// leading-to-trailing traversal of the active scene.
    ///
    /// - Parameters:
    ///     - shortcut: The shortcut to associate with this control.
    ///     - isEnabled: A Boolean value that indicates whether the shortcut is
    ///       is enabled for this control.
    nonisolated public func handGestureShortcut(_ shortcut: HandGestureShortcut, isEnabled: Bool = true) -> some View {
        handGestureShortcutBuilder(shortcut, isEnabled: isEnabled)
            .input(IsHandGestureShortcut.self)
    }

    @ViewBuilder
    nonisolated private func handGestureShortcutBuilder(
        _ shortcut: HandGestureShortcut,
        isEnabled: Bool
    ) -> some View {
        if shortcut == .primaryAction {
            modifier(ExternalGestureActionModifier(enabled: isEnabled))
        } else {
            self
        }
    }
}

// MARK: - HandGestureShortcut

/// Hand gesture shortcuts describe finger and wrist movements that the user can
/// perform in order to activate a button or toggle.
@available(OpenSwiftUI_v6_0, *)
@available(visionOS, unavailable)
public struct HandGestureShortcut: Sendable, Equatable {
    enum Storage: Sendable {
        case primaryAction
    }

    var storage: Storage

    /// The hand gesture shortcut for the primary action.
    ///
    /// On watchOS, this is performed by double-tapping the thumb and index
    /// finger together.
    public static let primaryAction = HandGestureShortcut(storage: .primaryAction)
}

// MARK: - ExternalGestureActionModifier

struct ExternalGestureActionModifier: ViewModifier {
    var enabled: Bool

    func body(content: Content) -> some View {
        ContentView(content: content, enabled: enabled)
            .environment(\.isHandGestureShortcutEnabled, enabled)
            .input(IsHandGestureShortcut.self)
    }

    struct ContentView: ConditionallyArchivableView {
        var content: Content
        var enabled: Bool

        var body: some View { content }

        var archivedBody: some View { content }
    }
}

private struct IsHandGestureShortcut: ViewInputBoolFlag {}

private struct IsHandGestureShortcutEnabled: EnvironmentKey {
    static let defaultValue = false
}

private struct IsArchivingHandGesture: ViewInputPredicate {
    static func evaluate(inputs: _GraphInputs) -> Bool {
        inputs[ArchivedViewInput.self].isArchived
    }
}

extension EnvironmentValues {
    var isHandGestureShortcutEnabled: Bool {
        get { self[IsHandGestureShortcutEnabled.self] }
        set { self[IsHandGestureShortcutEnabled.self] = newValue }
    }
}

// MARK: - HandGestureShortcutInteractiveControl

struct HandGestureShortcutInteractiveControl: ViewModifier {
    func body(content: Content) -> some View {
        content.modifier(HandGestureShortcutEnvironmentReader().requiring(
            IsHandGestureShortcut.self,
            and: IsArchivingHandGesture.self
        ))
    }

    struct HandGestureShortcutEnvironmentReader: ViewModifier {
        @Environment(\.isHandGestureShortcutEnabled) var isEnabled
        @Environment(\._buttonBorderShape) var borderShape

        func body(content: Content) -> some View {
            if isEnabled {
                content.modifier(HandGestureShortcutPreferenceWriter(buttonShape: BorderShape(borderShape)))
            } else {
                content
            }
        }
    }

    struct HandGestureShortcutPreferenceWriter: _ArchivableViewModifier {
        var buttonShape: BorderShape?

        func body(content: Content) -> some View { content }
    }

    enum BorderShape: Codable {
        case automatic
        case capsule
        case roundedRectangleAutomatic
        case roundedRectangle(radius: CGFloat)
        case circle

        init(_ shape: ButtonBorderShape) {
            switch shape.guts {
            case .automatic: self = .automatic
            case .capsule: self = .capsule
            case .roundedRectangleAutomatic: self = .roundedRectangleAutomatic
            case let .roundedRectangle(radius): self = .roundedRectangle(radius: radius)
            case .circle: self = .circle
            }
        }
    }
}

@_spi(Widget)
@available(OpenSwiftUI_v6_0, *)
extension View {
    nonisolated public func addingHandGestureShortcutPlatformLayer() -> some View {
        self
    }
}
