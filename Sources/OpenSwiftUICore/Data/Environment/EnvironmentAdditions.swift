//
//  EnvironmentAdditions.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 1B17C64D9E901A0054B49B69A4A2439D (SwiftUICore)

private struct DisplayGamutKey: EnvironmentKey {
    static var defaultValue: DisplayGamut { .sRGB }
}

extension EnvironmentValues {
    @_spi(Private)
    public var displayGamut: DisplayGamut {
        get { self[DisplayGamutKey.self] }
        set { self[DisplayGamutKey.self] = newValue }
    }
}
struct AllowsVibrantBlendingKey: EnvironmentKey {
    static var defaultValue: Bool? { nil }
}

extension EnvironmentValues {
    package var allowsVibrantBlending: Bool {
        get { self[AllowsVibrantBlendingKey.self] ?? true }
        set { self[AllowsVibrantBlendingKey.self] = newValue }
    }

    @available(iOS, unavailable)
    @available(macOS, deprecated, message: "Use `backgroundMaterial` instead")
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public var _useVibrantStyling: Bool {
        get { preconditionFailure("TODO") }
        set { preconditionFailure("TODO") }
    }

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    package var reduceDesktopTinting: Bool {
        get { preconditionFailure("TODO") }
        set { preconditionFailure("TODO") }
    }
}
