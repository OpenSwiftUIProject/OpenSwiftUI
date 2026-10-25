//
//  AccessibilityAdjustableAction.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore
import OpenSwiftUI_SPI
#if os(macOS)
import AppKit
#endif

// MARK: - AccessibilityAdjustmentDirection

/// A directional indicator you use when making an accessibility adjustment.
@available(OpenSwiftUI_v1_0, *)
public enum AccessibilityAdjustmentDirection: Sendable {
    case increment
    case decrement
}

// MARK: - View + AccessibilityAdjustableAction

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Adds an accessibility adjustable action to the view. Actions allow
    /// assistive technologies, such as the VoiceOver, to interact with the
    /// view by invoking the action.
    ///
    /// For example, this is how an adjustable action to navigate
    /// through pages could be added to a view.
    ///
    ///     var body: some View {
    ///         PageControl()
    ///             .accessibilityAdjustableAction { direction in
    ///                 switch direction {
    ///                 case .increment:
    ///                     // Go to next page
    ///                 case .decrement:
    ///                     // Go to previous page
    ///                 }
    ///             }
    ///     }
    ///
    nonisolated public func accessibilityAdjustableAction(
        _ handler: @escaping (AccessibilityAdjustmentDirection) -> Void
    ) -> ModifiedContent<Self, AccessibilityAttachmentModifier> {
        accessibilityAction(AccessibilityAdjustableAction(continuous: nil), handler)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension ModifiedContent where Modifier == AccessibilityAttachmentModifier {
    /// Adds an accessibility adjustable action to the view. Actions allow
    /// assistive technologies, such as the VoiceOver, to interact with the
    /// view by invoking the action.
    ///
    /// For example, this is how an adjustable action to navigate
    /// through pages could be added to a view.
    ///
    ///     var body: some View {
    ///         PageControl()
    ///             .accessibilityAdjustableAction { direction in
    ///                 switch direction {
    ///                 case .increment:
    ///                     // Go to next page
    ///                 case .decrement:
    ///                     // Go to previous page
    ///                 }
    ///             }
    ///     }
    ///
    nonisolated public func accessibilityAdjustableAction(
        _ handler: @escaping (AccessibilityAdjustmentDirection) -> Void
    ) -> ModifiedContent<Content, Modifier> {
        accessibilityAction(AccessibilityAdjustableAction(continuous: nil), handler)
    }
}

// MARK: - AccessibilityAdjustableAction

struct AccessibilityAdjustableAction: AccessibilityAction {
    typealias Value = AccessibilityAdjustmentDirection

    let continuous: Bool?

    func impliedRole(for traits: AccessibilityTraitStorage) -> AccessibilityRole? {
        #if os(macOS)
        AccessibilityRole(resolved: .init(
            role: continuous.map { $0 ? .slider : .incrementor },
            subrole: nil,
            traits: .adjustable
        ))
        #else
        AccessibilityRole(resolved: .init(
            traits: .adjustable,
            automationType: continuous.map { $0 ? .slider : .stepper }
        ))
        #endif
    }

    func matches<Other>(_ other: Other) -> Bool where Other: AccessibilityAction {
        other is AccessibilityAdjustableAction
    }
}
