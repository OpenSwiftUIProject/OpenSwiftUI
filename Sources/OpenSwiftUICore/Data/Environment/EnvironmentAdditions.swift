//
//  EnvironmentAdditions.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 1B17C64D9E901A0054B49B69A4A2439D (SwiftUICore)

public import Foundation
package import OpenAttributeGraphShims

// MARK: - EnvironmentValues + Root

extension EnvironmentValues {
    package mutating func configureForRoot() {
        locale = .current
        calendar = .current
        timeZone = .current
    }

    package func configuredForRoot() -> EnvironmentValues {
        var environment = self
        environment.configureForRoot()
        return environment
    }
}

// TODO: EnvironementValues + Font

// MARK: - EnvironmentValues + Display

private struct DisplayScaleKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1.0
}

private struct DefaultPixelLengthKey: EnvironmentKey {
    static var defaultValue: CGFloat? { nil }
}

extension CachedEnvironment.ID {
    package static let pixelLength: CachedEnvironment.ID = .init()
}

extension _ViewInputs {
    package var pixelLength: Attribute<CGFloat> {
        mapEnvironment(id: .pixelLength) { $0.pixelLength }
    }
}

@available(OpenSwiftUI_v1_0, *)
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

// MARK: - EnvironmentValues + ? [6.4.41]

private struct LegibilityWeightKey: EnvironmentKey {
    static var defaultValue: LegibilityWeight? { nil }
}

private struct LocaleKey: EnvironmentKey {
    static let defaultValue: Locale = Locale(identifier: "")
}

private struct TimeZoneKey: EnvironmentKey {
    static let defaultValue: TimeZone = .autoupdatingCurrent
}

private struct CalendarKey: EnvironmentKey {
    static let defaultValue: Calendar = .autoupdatingCurrent
}

private struct DisplayGamutKey: EnvironmentKey {
    static var defaultValue: DisplayGamut { .sRGB }
}

@available(OpenSwiftUI_v1_0, *)
extension EnvironmentValues {
    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public var dividerThickness: CGFloat {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }

//    package var defaultRenderingMode: Image.TemplateRenderingMode {
//        get { _openSwiftUIUnimplementedFailure() }
//        set { _openSwiftUIUnimplementedFailure() }
//    }

    @_spi(ClarityBoard)
    @available(OpenSwiftUI_v4_0, *)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(macCatalyst, unavailable)
    public var displayCornerRadius: CGFloat? {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }

    /// The font weight to apply to text.
    ///
    /// This value reflects the value of the Bold Text display setting found in
    /// the Accessibility settings.
    public var legibilityWeight: LegibilityWeight? {
        get { self[LegibilityWeightKey.self] }
        set { self[LegibilityWeightKey.self] = newValue }
    }

    /// The current locale that views should use.
    public var locale: Locale {
        get { self[LocaleKey.self] }
        set { self[LocaleKey.self] = newValue }
    }

    /// The current calendar that views should use when handling dates.
    public var calendar: Calendar {
        get { self[CalendarKey.self] }
        set { self[CalendarKey.self] = newValue }
    }

    /// The current time zone that views should use when handling dates.
    public var timeZone: TimeZone {
        get { self[TimeZoneKey.self] }
        set { self[TimeZoneKey.self] = newValue }
    }

    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public var displayGamut: DisplayGamut {
        get { self[DisplayGamutKey.self] }
        set { self[DisplayGamutKey.self] = newValue }
    }

//    @available(iOS, unavailable)
//    @available(macOS, deprecated, message: "Use `EnvironmentValues.appearsActive` instead.")
//    @available(tvOS, unavailable)
//    @available(watchOS, unavailable)
//    @available(visionOS, unavailable)
//    public var controlActiveState: ControlActiveState {
//        get { _openSwiftUIUnimplementedFailure() }
//        set { _openSwiftUIUnimplementedFailure() }
//    }
//
//    @available(OpenSwiftUI_v1_0, *)
//    public var horizontalSizeClass: UserInterfaceSizeClass? {
//        get { _openSwiftUIUnimplementedFailure() }
//        set { _openSwiftUIUnimplementedFailure() }
//    }
//
//    @available(OpenSwiftUI_v1_0, *)
//    @usableFromInline
//    var realHorizontalSizeClass: UserInterfaceSizeClass? {
//        get { _openSwiftUIUnimplementedFailure() }
//        set { _openSwiftUIUnimplementedFailure() }
//    }
//
//    @available(OpenSwiftUI_v1_0, *)
//    public var verticalSizeClass: UserInterfaceSizeClass? {
//        get { _openSwiftUIUnimplementedFailure() }
//        set { _openSwiftUIUnimplementedFailure() }
//    }
//
//    @available(OpenSwiftUI_v1_0, *)
//    @usableFromInline
//    var realVerticalSizeClass: UserInterfaceSizeClass? {
//        get { _openSwiftUIUnimplementedFailure() }
//        set { _openSwiftUIUnimplementedFailure() }
//    }
}

// MARK: - EnvironmentValues + Vibrant

struct AllowsVibrantBlendingKey: EnvironmentKey {
    static var defaultValue: Bool? { nil }
}

private struct ReduceDesktopTintingKey: EnvironmentKey {
    static var defaultValue: Bool { false }
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
        get { backgroundMaterial != nil }
        set {
            if newValue {
                backgroundMaterial = nil
            } else {
                backgroundMaterial = .regular
            }
        }
    }

    @available(OpenSwiftUI_v3_0, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    package var reduceDesktopTinting: Bool {
        get { self[ReduceDesktopTintingKey.self] }
        set { self[ReduceDesktopTintingKey.self] = newValue }
    }
}

// MARK: - EnvironmentValues + Typography

private struct DefaultKerningKey: EnvironmentKey {
    static let defaultValue: CGFloat = .zero
}

private struct DefaultTrackingKey: EnvironmentKey {
    static let defaultValue: CGFloat = .zero
}

private struct DefaultBaselineOffsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = .zero
}

extension EnvironmentValues {
    package var defaultKerning: CGFloat {
        get { self[DefaultKerningKey.self] }
        set { self[DefaultKerningKey.self] = newValue }
    }

    package var defaultTracking: CGFloat {
        get { self[DefaultTrackingKey.self] }
        set { self[DefaultTrackingKey.self] = newValue }
    }

    package var defaultBaselineOffset: CGFloat {
        get { self[DefaultBaselineOffsetKey.self] }
        set { self[DefaultBaselineOffsetKey.self] = newValue }
    }
}
