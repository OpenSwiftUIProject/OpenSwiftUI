//
//  WindowEnvironment.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - WindowEnvironmentKeys

package enum WindowEnvironmentKeys {

    package struct AppearsFocused: EnvironmentKey {
        package static var defaultValue: Bool { true }
    }

    package struct AppearsMain: EnvironmentKey {
        package static var defaultValue: Bool { false }
    }

    package struct AppearsActive: EnvironmentKey {
        package static var defaultValue: Bool { true }
    }

    package struct IsFocused: EnvironmentKey {
        package static var defaultValue: Bool { true }
    }

    package struct IsMain: EnvironmentKey {
        package static var defaultValue: Bool { true }
    }
}

// MARK: - EnvironmentValues + WindowEnvironmentKeys

@_spi(ForOpenSwiftUIOnly)
@_spi(DoNotImport)
@available(OpenSwiftUI_v6_0, *)
extension EnvironmentValues {

    public var windowAppearsFocused: Bool {
        get { self[WindowEnvironmentKeys.AppearsFocused.self] }
        set { self[WindowEnvironmentKeys.AppearsFocused.self] = newValue }
    }

    public var windowAppearsMain: Bool {
        get { self[WindowEnvironmentKeys.AppearsMain.self] }
        set { self[WindowEnvironmentKeys.AppearsMain.self] = newValue }
    }

    public var windowAppearsActive: Bool {
        get { self[WindowEnvironmentKeys.AppearsActive.self] }
        set { self[WindowEnvironmentKeys.AppearsActive.self] = newValue }
    }

    public var windowIsFocused: Bool {
        get { self[WindowEnvironmentKeys.IsFocused.self] }
        set { self[WindowEnvironmentKeys.IsFocused.self] = newValue }
    }

    public var windowIsMain: Bool {
        get { self[WindowEnvironmentKeys.IsMain.self] }
        set { self[WindowEnvironmentKeys.IsMain.self] = newValue }
    }
}
