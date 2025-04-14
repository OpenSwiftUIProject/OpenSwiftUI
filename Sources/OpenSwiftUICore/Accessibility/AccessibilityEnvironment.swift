//
//  AccessibilityEnvironment.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 1E80A5D8CD82563C298D64AC1337E839 (SwiftUICore)

private struct AccessibilityReduceTransparencyKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

extension EnvironmentValues {
    /// Whether the system preference for Reduce Transparency is enabled.
    ///
    /// If this property's value is true, UI (mainly window) backgrounds should
    /// not be semi-transparent; they should be opaque.
    public var accessibilityReduceTransparency: Bool {
        get { self[AccessibilityReduceTransparencyKey.self] }
        set { self[AccessibilityReduceTransparencyKey.self] = newValue }
    }
}
