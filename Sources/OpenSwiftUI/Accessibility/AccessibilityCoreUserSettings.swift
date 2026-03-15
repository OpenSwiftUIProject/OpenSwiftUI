//
//  AccessibilityCoreUserSettings.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 005A2BB2D44F4D559B7E508DC5B95FFB (SwiftUI)

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
            // TODO: environment[EnabledTechnologiesKey.self] = .enabledTechnologies
            // TODO: environment[AccessibilityLargeContentViewerKey.self] = UILargeContentViewerInteraction.isEnabled
            // TODO: environment[AccessibilityQuickActionsKey.self] = false
            environment.accessibilityPrefersOnOffLabels = _AXSIncreaseButtonLegibility() != 0
        }
    }
}

@_silgen_name("_AXSPhotosensitiveMitigationEnabled")
private func _AXSPhotosensitiveMitigationEnabled() -> Bool

@_silgen_name("_AXSIncreaseButtonLegibility")
private func _AXSIncreaseButtonLegibility() -> Int32

#endif
