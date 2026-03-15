//
//  AccessibilityEnvironmentAdditions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E3F97FE8C846010147E7A62076265464 (SwiftUI)

import OpenSwiftUICore

// MARK: - EnabledTechnologiesKey

private struct EnabledTechnologiesKey: EnvironmentKey {
    static var defaultValue: AccessibilityTechnologies { AccessibilityTechnologies() }
}

// MARK: - EnvironmentValues + Accessbility

extension EnvironmentValues {
    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public var accessibilityEnabledTechnologies: AccessibilityTechnologies {
        get { self[EnabledTechnologiesKey.self] }
        set { self[EnabledTechnologiesKey.self] = newValue }
    }

    fileprivate func isEnabled(for technology: AccessibilityTechnology) -> Bool {
        let member = AccessibilityTechnologies(list: [technology])
        return accessibilityEnabledTechnologies.contains(member)
    }

    fileprivate mutating func setIsEnabled(_ enabled: Bool, for technology: AccessibilityTechnology) {
        guard isEnabled(for: technology) != enabled else { return }
        let member = AccessibilityTechnologies(list: [technology])
        if enabled {
            accessibilityEnabledTechnologies.insert(member)
        } else {
            accessibilityEnabledTechnologies.remove(member)
        }
    }

}

@available(OpenSwiftUI_v3_0, *)
extension EnvironmentValues {

    /// A Boolean value that indicates whether the VoiceOver screen reader is in use.
    ///
    /// The state changes as the user turns on or off the VoiceOver screen reader.
    public var accessibilityVoiceOverEnabled: Bool {
        isEnabled(for: .voiceOver)
    }

    /// A Boolean value that indicates whether the Switch Control motor accessibility feature is in use.
    ///
    /// The state changes as the user turns on or off the Switch Control feature.
    public var accessibilitySwitchControlEnabled: Bool {
        isEnabled(for: .switchControl)
    }
}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension EnvironmentValues {
    public var accessibilityFullKeyboardAccessEnabled: Bool {
        isEnabled(for: .fullKeyboardAccess)
    }

    public var accessibilityVoiceControlEnabled: Bool {
        isEnabled(for: .voiceControl)
    }
}

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension EnvironmentValues {
    public var accessibilityHoverTextEnabled: Bool {
        isEnabled(for: .hoverText)
    }
}

@available(OpenSwiftUI_v6_0, *)
extension EnvironmentValues {
    /// A Boolean value that indicates whether Assistive Access is in use.
    public var accessibilityAssistiveAccessEnabled: Bool {
        isEnabled(for: .assistiveAccess)
    }
}
