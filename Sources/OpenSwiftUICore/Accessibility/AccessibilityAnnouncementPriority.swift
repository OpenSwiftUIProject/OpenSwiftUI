//
//  AccessibilityAnnouncementPriority.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by Text.Style

package import Foundation

// MARK: - AccessibilityAnnouncementPriority

@_spi(_)
@available(OpenSwiftUI_v5_0, *)
public enum AccessibilityAnnouncementPriority: Sendable {
    case low

    case `default`

    case high
}

@_spi(_)
extension AccessibilityAnnouncementPriority {
    package var platformRawValue: String {
        if isUIKitBased() {
            switch self {
            case .low: "UIAccessibilityPriorityLow"
            case .default: "UIAccessibilityPriorityDefault"
            case .high: "UIAccessibilityPriorityHigh"
            }
        } else {
            switch self {
            case .low: "low"
            case .default: "default"
            case .high: "high"
            }
        }
    }
}

// MARK: - AccessibilitySpeechAttributes

package struct AccessibilitySpeechAttributes: Equatable {
    package var alwaysIncludesPunctuation: Bool?

    package var spellsOutCharacters: Bool?

    package var adjustedPitch: Double?

    package var announcementsPriority: AccessibilityAnnouncementPriority?

    package var phoneticRepresentation: String?

    package init(
        alwaysIncludesPunctuation: Bool? = nil,
        spellsOutCharacters: Bool? = nil,
        adjustedPitch: Double? = nil,
        announcementsPriority: AccessibilityAnnouncementPriority? = nil,
        phoneticRepresentation: String? = nil
    ) {
        self.alwaysIncludesPunctuation = alwaysIncludesPunctuation
        self.spellsOutCharacters = spellsOutCharacters
        self.adjustedPitch = adjustedPitch
        self.announcementsPriority = announcementsPriority
        self.phoneticRepresentation = phoneticRepresentation
    }

    package init(in environment: EnvironmentValues) {
        self.init(
            alwaysIncludesPunctuation: environment.speechAlwaysIncludesPunctuation,
            spellsOutCharacters: environment.speechSpellsOutCharacters,
            adjustedPitch: environment.speechAdjustedPitch,
            announcementsPriority: environment.speechAnnouncementsPriority
        )
    }

    package func applyTo(environment: inout EnvironmentValues) {
        environment.speechAlwaysIncludesPunctuation = alwaysIncludesPunctuation
        environment.speechSpellsOutCharacters = spellsOutCharacters
        environment.speechAdjustedPitch = adjustedPitch
        environment.speechAnnouncementsPriority = announcementsPriority
    }

    package func combined(with other: AccessibilitySpeechAttributes) -> AccessibilitySpeechAttributes {
        AccessibilitySpeechAttributes(
            alwaysIncludesPunctuation: alwaysIncludesPunctuation ?? other.alwaysIncludesPunctuation,
            spellsOutCharacters: spellsOutCharacters ?? other.spellsOutCharacters,
            adjustedPitch: adjustedPitch ?? other.adjustedPitch,
            announcementsPriority: announcementsPriority ?? other.announcementsPriority,
            phoneticRepresentation: phoneticRepresentation ?? other.phoneticRepresentation
        )
    }
}

// MARK: - Text.Style + AccessibilitySpeechAttributes

extension Text.Style {
    package func resolveAccessibilitySpeechAttributes(
        into attributes: inout [NSAttributedString.Key: Any],
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool = true
    ) {
        let speechAttributes = AccessibilitySpeechAttributes(
            alwaysIncludesPunctuation: speech?.alwaysIncludesPunctuation ?? environment.speechAlwaysIncludesPunctuation,
            spellsOutCharacters: speech?.spellsOutCharacters ?? environment.speechSpellsOutCharacters,
            adjustedPitch: speech?.adjustedPitch ?? environment.speechAdjustedPitch,
            announcementsPriority: speech?.announcementsPriority ?? environment.speechAnnouncementsPriority
        )
        AccessibilityCore.resolveAccessibilitySpeechAttributes(
            into: &attributes,
            speechAttr: speechAttributes,
            environment: environment,
            includeDefaultAttributes: includeDefaultAttributes
        )
    }
}
