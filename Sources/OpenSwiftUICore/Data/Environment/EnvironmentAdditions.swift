//
//  EnvironmentAdditions.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 1B17C64D9E901A0054B49B69A4A2439D (SwiftUICore)

public import Foundation

// MARK: - EnvironmentValues + Display [6.4.41]

private struct DisplayScaleKey: EnvironmentKey {
    static var defaultValue: CGFloat { 1.0 }
}

private struct DefaultPixelLengthKey: EnvironmentKey {
    static var defaultValue: CGFloat? { nil }
}

extension EnvironmentValues {
    /// The display scale of this environment.
    public var displayScale: CGFloat {
        get { self[DisplayScaleKey.self] }
        set { self[DisplayScaleKey.self] = newValue }
    }

    /// The size of a pixel on the screen.
    ///
    /// This value is usually equal to `1` divided by
    /// ``EnvironmentValues/displayScale``.
    public var pixelLength: CGFloat {
        defaultPixelLength ?? (1.0 / displayScale)
    }

    package var defaultPixelLength: CGFloat? {
        get { self[DefaultPixelLengthKey.self] }
        set { self[DefaultPixelLengthKey.self] = newValue }
    }
}

extension CachedEnvironment.ID {
    package static let pixelLength: CachedEnvironment.ID = .init()
}

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
        get { openSwiftUIUnimplementedFailure() }
        set { openSwiftUIUnimplementedFailure() }
    }

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    package var reduceDesktopTinting: Bool {
        get { openSwiftUIUnimplementedFailure() }
        set { openSwiftUIUnimplementedFailure() }
    }
}
