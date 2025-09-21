//
//  AccessibilityEnvironment.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1E80A5D8CD82563C298D64AC1337E839 (SwiftUICore)

// MARK: - Accessibility Environment Values [WIP]

private struct AccessibilityEnabledKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

@available(OpenSwiftUI_v1_0, *)
extension EnvironmentValues {
    /// A Boolean value that indicates whether the user has enabled an assistive
    /// technology.
    public var accessibilityEnabled: Bool {
        get { self[AccessibilityEnabledKey.self] }
        set { self[AccessibilityEnabledKey.self] = newValue }
    }

    private struct AccessibilitySpeechAlwaysIncludesPunctuationKey: EnvironmentKey {
        static var defaultValue: Bool? { nil }
    }

    package var speechAlwaysIncludesPunctuation: Bool? {
        get { self[AccessibilitySpeechAlwaysIncludesPunctuationKey.self] }
        set { self[AccessibilitySpeechAlwaysIncludesPunctuationKey.self] = newValue }
    }

    private struct AccessibilitySpeechSpellsOutCharactersKey: EnvironmentKey {
        static var defaultValue: Bool? { nil }
    }

    package var speechSpellsOutCharacters: Bool? {
        get { self[AccessibilitySpeechSpellsOutCharactersKey.self] }
        set { self[AccessibilitySpeechSpellsOutCharactersKey.self] = newValue }
    }

    private struct AccessibilitySpeechAdjustedPitchKey: EnvironmentKey {
        static var defaultValue: Double? { nil }
    }

    package var speechAdjustedPitch: Double? {
        get { self[AccessibilitySpeechAdjustedPitchKey.self] }
        set { self[AccessibilitySpeechAdjustedPitchKey.self] = newValue }
    }

    private struct AccessibilitySpeechAnnouncementsPriorityKey: EnvironmentKey {
        static var defaultValue: AccessibilityAnnouncementPriority? { nil }
    }

    package var speechAnnouncementsPriority: AccessibilityAnnouncementPriority? {
        get { self[AccessibilitySpeechAnnouncementsPriorityKey.self] }
        set { self[AccessibilitySpeechAnnouncementsPriorityKey.self] = newValue }
    }
}

// MARK: - EnvironmentValues + Accessibility v1

private struct AccessibilityDifferentiateWithoutColorKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

private struct AccessibilityReduceTransparencyKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

private struct AccessibilityReduceMotionKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

private struct AccessibilityPrefersCrossFadeTransitionsKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

private struct AccessibilityInvertColorsKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

extension EnvironmentValues {
    /// Whether the system preference for Differentiate without Color is enabled.
    ///
    /// If this is true, UI should not convey information using color alone
    /// and instead should use shapes or glyphs to convey information.
    public package(set) var accessibilityDifferentiateWithoutColor: Bool {
        get { _accessibilityDifferentiateWithoutColor }
        set { _accessibilityDifferentiateWithoutColor = newValue }
    }

    public var _accessibilityDifferentiateWithoutColor: Bool {
        get { self[AccessibilityDifferentiateWithoutColorKey.self] }
        set { self[AccessibilityDifferentiateWithoutColorKey.self] = newValue }
    }

    /// Whether the system preference for Reduce Transparency is enabled.
    ///
    /// If this property's value is true, UI (mainly window) backgrounds should
    /// not be semi-transparent; they should be opaque.
    public package(set) var accessibilityReduceTransparency: Bool {
        get { _accessibilityReduceTransparency }
        set { _accessibilityReduceTransparency = newValue }
    }

    public var _accessibilityReduceTransparency: Bool {
        get { self[AccessibilityReduceTransparencyKey.self] }
        set { self[AccessibilityReduceTransparencyKey.self] = newValue }
    }

    /// Whether the system preference for Reduce Motion is enabled.
    ///
    /// If this property's value is true, UI should avoid large animations,
    /// especially those that simulate the third dimension.
    public package(set) var accessibilityReduceMotion: Bool {
        get { _accessibilityReduceMotion }
        set { _accessibilityReduceMotion = newValue }
    }

    public var _accessibilityReduceMotion: Bool {
        get { self[AccessibilityReduceMotionKey.self] }
        set { self[AccessibilityReduceMotionKey.self] = newValue }
    }

    package var accessibilityPrefersCrossFadeTransitions: Bool {
        get { self[AccessibilityPrefersCrossFadeTransitionsKey.self] }
        set { self[AccessibilityPrefersCrossFadeTransitionsKey.self] = newValue }
    }

    /// Whether the system preference for Invert Colors is enabled.
    ///
    /// If this property's value is true then the display will be inverted.
    /// In these cases it may be needed for UI drawing to be adjusted to in
    /// order to display optimally when inverted.
    public var accessibilityInvertColors: Bool {
        get { _accessibilityInvertColors }
        set { _accessibilityInvertColors = newValue }
    }

    public var _accessibilityInvertColors: Bool {
        get { self[AccessibilityInvertColorsKey.self] }
        set { self[AccessibilityInvertColorsKey.self] = newValue }
    }
}

// MARK: - EnvironmentValues + Accessibility v2

private struct AccessibilityButtonShapesKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

@available(OpenSwiftUI_v2_0, *)
extension EnvironmentValues {
    /// Whether the system preference for Show Button Shapes is enabled.
    ///
    /// If this property's value is true, interactive custom controls
    /// such as buttons should be drawn in such a way that their edges
    /// and borders are clearly visible.
    public package(set) var accessibilityShowButtonShapes: Bool {
        get { _accessibilityShowButtonShapes }
        set { _accessibilityShowButtonShapes = newValue }
    }

    public var _accessibilityShowButtonShapes: Bool {
        get { self[AccessibilityButtonShapesKey.self] }
        set { self[AccessibilityButtonShapesKey.self] = newValue }
    }
}

// MARK: - EnvironmentValues + Accessibility v5

private struct AccessibilityDimFlashingLightsKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

private struct AccessibilityPlayAnimatedImagesKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

@available(OpenSwiftUI_v5_0, *)
extension EnvironmentValues {
    /// Whether the setting to reduce flashing or strobing lights in video
    /// content is on. This setting can also be used to determine if UI in
    /// playback controls should be shown to indicate upcoming content that
    /// includes flashing or strobing lights.
    public package(set) var accessibilityDimFlashingLights: Bool {
        get { self[AccessibilityDimFlashingLightsKey.self] }
        set { self[AccessibilityDimFlashingLightsKey.self] = newValue }
    }

    /// Whether the setting for playing animations in an animated image is
    /// on. When this value is false, any presented image that contains
    /// animation should not play automatically.
    public private(set) var accessibilityPlayAnimatedImages: Bool {
        get { self[AccessibilityPlayAnimatedImagesKey.self] }
        set { self[AccessibilityPlayAnimatedImagesKey.self] = newValue }
    }
}

private struct AccessibilityOnOffLabelsKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

extension EnvironmentValues {
    package var accessibilityPrefersOnOffLabels: Bool {
        get { self[AccessibilityOnOffLabelsKey.self] }
        set { self[AccessibilityOnOffLabelsKey.self] = newValue }
    }
}

private struct AccessibilityHeadAnchorAlternativeKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

private struct AccessibilityIncreaseFocusStateKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

private struct AccessibilityReduceHoverRevealKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

@available(OpenSwiftUI_v5_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension EnvironmentValues {
    /// Whether the system setting to prefer alternatives to head-anchored
    /// content is on.
    ///
    /// If this property's value is true, alternate anchors should be used for
    /// most head-anchored UI, such as world anchors.
    public package(set) var accessibilityPrefersHeadAnchorAlternative: Bool {
        get { self[AccessibilityHeadAnchorAlternativeKey.self] }
        set { self[AccessibilityHeadAnchorAlternativeKey.self] = newValue }
    }

    @_spi(Private)
    public var accessibilityIncreaseFocusStateEnabled: Bool {
        get { self[AccessibilityIncreaseFocusStateKey.self] }
        set { self[AccessibilityIncreaseFocusStateKey.self] = newValue }
    }

    package var accessibilityReduceHoverReveal: Bool {
        get { self[AccessibilityReduceHoverRevealKey.self] }
        set { self[AccessibilityReduceHoverRevealKey.self] = newValue }
    }
}
