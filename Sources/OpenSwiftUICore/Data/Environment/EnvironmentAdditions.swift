//
//  EnvironmentAdditions.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 1B17C64D9E901A0054B49B69A4A2439D (SwiftUICore)

public import Foundation
package import OpenAttributeGraphShims

// MARK: - Image + Additions

@available(OpenSwiftUI_v1_0, *)
extension Image {

    /// A type that indicates how OpenSwiftUI renders images.
    public enum TemplateRenderingMode: Sendable {

        /// A mode that renders all non-transparent pixels as the foreground
        /// color.
        case template

        /// A mode that renders pixels of bitmap images as-is.
        ///
        /// For system images created from the SF Symbol set, multicolor symbols
        /// respect the current foreground and accent colors.
        case original
    }

    /// A scale to apply to vector images relative to text.
    ///
    /// Use this type with the ``View/imageScale(_:)`` modifier, or the
    /// ``EnvironmentValues/imageScale`` environment key, to set the image scale.
    ///
    /// The following example shows the three `Scale` values as applied to
    /// a system symbol image, each set against a text view:
    ///
    ///     HStack { Image(systemName: "swift").imageScale(.small); Text("Small") }
    ///     HStack { Image(systemName: "swift").imageScale(.medium); Text("Medium") }
    ///     HStack { Image(systemName: "swift").imageScale(.large); Text("Large") }
    ///
    /// ![Vertically arranged text views that read Small, Medium, and
    /// Large. On the left of each view is a system image that uses the Swift symbol.
    /// The image next to the Small text is slightly smaller than the text.
    /// The image next to the Medium text matches the size of the text. The
    /// image next to the Large text is larger than the
    /// text.](OpenSwiftUI-EnvironmentAdditions-Image-scale.png)
    ///
    @available(OpenSwiftUI_macOS_v2_0, *)
    public enum Scale: Hashable, Sendable {

        /// A scale that produces small images.
        case small

        /// A scale that produces medium-sized images.
        case medium

        /// A scale that produces large images.
        case large

        @_spi(ForOpenSwiftUIOnly)
        @available(OpenSwiftUI_v6_0, *)
        case _fittingCircleRadius(_fixedPointFraction: UInt16)

        @_spi(Private)
        @available(OpenSwiftUI_v6_0, *)
        @available(*, deprecated, renamed: "_controlCenter_large")
        @_alwaysEmitIntoClient
        public static func fittingCircleRadius(pointSizeMultiple: CGFloat) -> Image.Scale {
            ._controlCenter_large
        }

        @_spi(Private)
        @available(OpenSwiftUI_v6_0, *)
        case _controlCenter_small, _controlCenter_medium, _controlCenter_large
    }
}

// MARK: - UserInterfaceSizeClass

/// A set of values that indicate the visual size available to the view.
///
/// You receive a size class value when you read either the
/// ``EnvironmentValues/horizontalSizeClass`` or
/// ``EnvironmentValues/verticalSizeClass`` environment value. The value tells
/// you about the amount of space available to your views in a given
/// direction. You can read the size class like any other of the
/// ``EnvironmentValues``, by creating a property with the ``Environment``
/// property wrapper:
///
///     @Environment(\.horizontalSizeClass) private var horizontalSizeClass
///     @Environment(\.verticalSizeClass) private var verticalSizeClass
///
/// OpenSwiftUI sets the size class based on several factors, including:
///
/// * The current device type.
/// * The orientation of the device.
/// * The appearance of Slide Over and Split View on iPad.
///
/// Several built-in views change their behavior based on the size class.
/// For example, a ``NavigationView`` presents a multicolumn view when
/// the horizontal size class is ``UserInterfaceSizeClass/regular``,
/// but a single column otherwise. You can also adjust the appearance of
/// custom views by reading the size class and conditioning your views.
/// If you do, be prepared to handle size class changes while
/// your app runs, because factors like device orientation can change at
/// runtime.
@available(OpenSwiftUI_v1_0, *)
public enum UserInterfaceSizeClass: Sendable {

    /// The compact size class.
    case compact

    /// The regular size class.
    case regular
}

// MARK: - DisplayGamut

#if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
import CoreUI_Private
import CoreUI
#endif

@_spi(Private)
public enum DisplayGamut: Int {
    case sRGB
    case displayP3

    package static var deviceDefault: DisplayGamut {
        #if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
        switch _CUIDefaultDisplayGamut() {
        case .SRGB: .sRGB
        case .P3: .displayP3
        }
        #else
        return .sRGB
        #endif
    }

    #if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
    @inline(__always)
    var cuiDisplayGamut: CUIDisplayGamut {
        switch self {
        case .sRGB: .SRGB
        case .displayP3: .P3
        }
    }
    #endif
}

@_spi(Private)
@available(*, unavailable)
extension DisplayGamut: Sendable {}

@_spi(Private)
extension DisplayGamut: ProtobufEnum {}

// MARK: - ControlActiveState

/// The active appearance expected of controls in a window.
///
/// `ControlActiveState` and `EnvironmentValues.controlActiveState` are
/// deprecated, use `EnvironmentValues.appearsActive` instead.
@available(*, deprecated, message: "Use `EnvironmentValues.appearsActive` instead.")
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public enum ControlActiveState: Equatable, CaseIterable, Sendable {

    case key

    case active

    case inactive
}

// MARK: - LegibilityWeight

/// The Accessibility Bold Text user setting options.
///
/// The app can't override the user's choice before iOS 16, tvOS 16 or
/// watchOS 9.0.
@available(OpenSwiftUI_v1_0, *)
public enum LegibilityWeight: Hashable, Sendable {

    /// Use regular font weight (no Accessibility Bold).
    case regular

    /// Use heavier font weight (force Accessibility Bold).
    case bold
}

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
