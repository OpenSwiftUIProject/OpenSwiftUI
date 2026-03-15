//
//  AccessibilityCoreUserSettings.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if canImport(UIKit)
import Accessibility
package import OpenSwiftUICore
import UIKit

extension AccessibilityCore {
    package enum UserSettings {
        package static func resolve(into environment: inout EnvironmentValues) {
            environment.accessibilityDifferentiateWithoutColor = UIAccessibility.shouldDifferentiateWithoutColor
            environment.accessibilityReduceTransparency = UIAccessibility.isReduceTransparencyEnabled
            environment.accessibilityReduceMotion = UIAccessibility.isReduceMotionEnabled
            environment.accessibilityInvertColors = UIAccessibility.isInvertColorsEnabled
            environment.accessibilityPrefersCrossFadeTransitions = UIAccessibility.prefersCrossFadeTransitions
            environment.accessibilityShowButtonShapes = UIAccessibility.buttonShapesEnabled
            environment.accessibilityDimFlashingLights = _AXSPhotosensitiveMitigationEnabled()
            environment.accessibilityPlayAnimatedImages = AccessibilitySettings.animatedImagesEnabled
            environment.accessibilityEnabledTechnologies = .enabledTechnologies
            environment._accessibilityLargeContentViewerEnabled = UILargeContentViewerInteraction.isEnabled
            environment._accessibilityQuickActionsEnabled = false
            environment.accessibilityPrefersOnOffLabels = _AXSIncreaseButtonLegibility()
        }
    }
}

// MARK: - AccessibilityTechnologies + enabledTechnologies

extension AccessibilityTechnologies {
    package static var enabledTechnologies: AccessibilityTechnologies {
        let enabled = AccessibilityTechnology.allCases.filter { technology in
            switch technology {
            case .voiceOver: UIAccessibility.isVoiceOverRunning
            case .switchControl: UIAccessibility.isSwitchControlRunning
            case .fullKeyboardAccess: _AXSFullKeyboardAccessEnabled()
            case .voiceControl: _AXSCommandAndControlEnabled()
            case .hoverText: _AXSHoverTextEnabled()
            case .assistiveAccess: AXAssistiveAccessEnabled()
            }
        }
        return AccessibilityTechnologies(list: enabled)
    }
}

// MARK: - Private C functions

@_silgen_name("_AXSPhotosensitiveMitigationEnabled")
private func _AXSPhotosensitiveMitigationEnabled() -> Bool

@_silgen_name("_AXSIncreaseButtonLegibility")
private func _AXSIncreaseButtonLegibility() -> Bool

@_silgen_name("_AXSFullKeyboardAccessEnabled")
private func _AXSFullKeyboardAccessEnabled() -> Bool

@_silgen_name("_AXSCommandAndControlEnabled")
private func _AXSCommandAndControlEnabled() -> Bool

@_silgen_name("_AXSHoverTextEnabled")
private func _AXSHoverTextEnabled() -> Bool

@_silgen_name("AXAssistiveAccessEnabled")
private func AXAssistiveAccessEnabled() -> Bool

#endif
