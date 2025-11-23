//
//  EnvironmentAdditions.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 1B17C64D9E901A0054B49B69A4A2439D (SwiftUICore)

public import Foundation
package import OpenAttributeGraphShims

// MARK: - View + Font [WIP]

extension View {

    /// Sets the default font for text in this view.
    ///
    /// Use `font(_:)` to apply a specific font to all of the text in a view.
    ///
    /// The example below shows the effects of applying fonts to individual
    /// views and to view hierarchies. Font information flows down the view
    /// hierarchy as part of the environment, and remains in effect unless
    /// overridden at the level of an individual view or view container.
    ///
    /// Here, the outermost ``VStack`` applies a 16-point system font as a
    /// default font to views contained in that ``VStack``. Inside that stack,
    /// the example applies a ``Font/largeTitle`` font to just the first text
    /// view; this explicitly overrides the default. The remaining stack and the
    /// views contained with it continue to use the 16-point system font set by
    /// their containing view:
    ///
    ///     VStack {
    ///         Text("Font applied to a text view.")
    ///             .font(.largeTitle)
    ///
    ///         VStack {
    ///             Text("These 2 text views have the same font")
    ///             Text("applied to their parent hierarchy")
    ///         }
    ///     }
    ///     .font(.system(size: 16, weight: .light, design: .default))
    ///
    /// ![A screenshot showing the application fonts to an individual text field
    /// and view hierarchy.](OpenSwiftUI-view-font.png)
    ///
    /// - Parameter font: The default font to use in this view.
    ///
    /// - Returns: A view with the default font set to the value you supply.
    @inlinable
    nonisolated public func font(_ font: Font?) -> some View {
        environment(\.font, font)
    }

    @_spi(UIFrameworks)
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func defaultFont(_ font: Font?) -> some View {
        environment(\.defaultFont, font)
    }
}

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

// MARK: - EnvironementValues + Font

private struct FontKey: EnvironmentKey {
    static var defaultValue: Font? { nil }
}

private struct SymbolFontKey: EnvironmentKey {
    static var defaultValue: Font? { nil }
}

private struct DefaultFontKey: EnvironmentKey {
    static var defaultValue: Font? { nil }
}

private struct DefaultSymbolFontKey: EnvironmentKey {
    static var defaultValue: Font? { nil }
}

private struct FallbackFontProviderKey: EnvironmentKey {
    static let defaultValue: any FallbackFontProvider = DefaultFallbackFontProvider()
}

private struct InTouchBarKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

@available(OpenSwiftUI_v1_0, *)
extension EnvironmentValues {

    /// The default font of this environment.
    public var font: Font? {
        get { self[FontKey.self] }
        set { self[FontKey.self] = newValue }
    }

    private struct EffectiveFontKey: DerivedEnvironmentKey {
        typealias Value = Font

        static func value(in environment: EnvironmentValues) -> Font {
            environment.font
            ?? environment.defaultFont
            ?? environment.fallbackFont
        }
    }

    package var effectiveFont: Font {
        self[EffectiveFontKey.self]
    }

    private struct EffectiveSymbolFontKey: DerivedEnvironmentKey {
        static func value(in environment: EnvironmentValues) -> Font {
            environment.symbolFont
            ?? environment.font
            ?? environment.defaultSymbolFont
            ?? environment.effectiveFont
        }
    }

    package var effectiveSymbolFont: Font {
        self[EffectiveSymbolFontKey.self]
    }

    private struct FallbackFontKey: DerivedEnvironmentKey {
        typealias Value = Font

        static func value(in environment: EnvironmentValues) -> Font {
            environment.fallbackFontProvider.makeFont(in: environment)
        }
    }

    package var fallbackFont: Font {
        self[FallbackFontKey.self]
    }

    package var fallbackFontProvider: any FallbackFontProvider {
        get { self[FallbackFontProviderKey.self] }
        set { self[FallbackFontProviderKey.self] = newValue }
    }

    package var defaultFont: Font? {
        get { self[DefaultFontKey.self] }
        set { self[DefaultFontKey.self] = newValue }
    }

    package var defaultSymbolFont: Font? {
        get { self[DefaultSymbolFontKey.self] }
        set { self[DefaultSymbolFontKey.self] = newValue }
    }

    @_spi(ForOpenSwiftUIOnly)
    @available(OpenSwiftUI_v5_0, *)
    public var symbolFont: Font? {
        get { self[SymbolFontKey.self] }
        set { self[SymbolFontKey.self] = newValue }
    }

//    /// The image scale for this environment.
//    @available(macOS 11.0, *)
//    public var imageScale: Image.Scale {
//        get { _openSwiftUIUnimplementedFailure() }
//        set { _openSwiftUIUnimplementedFailure() }
//    }

    package var isInTouchBar: Bool {
        get { self[InTouchBarKey.self] }
        set { self[InTouchBarKey.self] = newValue }
    }
}

// MARK: - FallbackFontProvider

package protocol FallbackFontProvider {
    func makeFont(in env: EnvironmentValues) -> Font
}

package struct DefaultFallbackFontProvider: FallbackFontProvider {
    package init() {
        _openSwiftUIEmptyStub()
    }

    package func makeFont(in env: EnvironmentValues) -> Font {
        Font.body
    }
}

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
