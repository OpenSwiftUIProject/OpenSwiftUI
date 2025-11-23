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

// MARK: - View + Text Additions

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Scales images within the view according to one of the relative sizes
    /// available including small, medium, and large images sizes.
    ///
    /// The example below shows the relative scaling effect. The system renders
    /// the image at a relative size based on the available space and
    /// configuration options of the image it is scaling.
    ///
    ///     VStack {
    ///         HStack {
    ///             Image(systemName: "heart.fill")
    ///                 .imageScale(.small)
    ///             Text("Small")
    ///         }
    ///         HStack {
    ///             Image(systemName: "heart.fill")
    ///                 .imageScale(.medium)
    ///             Text("Medium")
    ///         }
    ///
    ///         HStack {
    ///             Image(systemName: "heart.fill")
    ///                 .imageScale(.large)
    ///             Text("Large")
    ///         }
    ///     }
    ///
    /// ![A view showing small, medium, and large hearts rendered at a size
    /// relative to the available space.](OpenSwiftUI-View-imageScale.png)
    ///
    /// - Parameter scale: One of the relative sizes provided by the image scale
    ///   enumeration.
    @available(OpenSwiftUI_macOS_v2_0, *)
    nonisolated public func imageScale(_ scale: Image.Scale) -> some View {
        environment(\.imageScale, scale)
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    @available(*, deprecated, message: "Use View/textSizing(.adjustsForOversizedCharacters)")
    nonisolated public func adjustsTextFrameForOversizedCharacters(_ adjustsTextFrame: Bool = true) -> some View {
        environment(\.textSizing, adjustsTextFrame ? .adjustsForOversizedCharacters : .standard)
    }

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

    /// Modifies the fonts of all child views to use fixed-width digits, if
    /// possible, while leaving other characters proportionally spaced.
    ///
    /// Using fixed-width digits allows you to easily align numbers of the
    /// same size in a table-like arrangement. This feature is also known as
    /// "tabular figures" or "tabular numbers."
    ///
    /// This modifier only affects numeric characters, and leaves all other
    /// characters unchanged.
    ///
    /// The following example shows the effect of `monospacedDigit()` on
    /// multiple child views. The example consists of two ``VStack`` views
    /// inside an ``HStack``. Each `VStack` contains two ``Button`` views, with
    /// the second `VStack` applying the `monospacedDigit()` modifier to its
    /// contents. As a result, the digits in the buttons in the trailing
    /// `VStack` are the same width, which in turn gives the buttons equal widths.
    ///
    ///     var body: some View {
    ///         HStack(alignment: .top) {
    ///             VStack(alignment: .leading) {
    ///                 Button("Delete 111 messages") {}
    ///                 Button("Delete 222 messages") {}
    ///             }
    ///             VStack(alignment: .leading) {
    ///                 Button("Delete 111 messages") {}
    ///                 Button("Delete 222 messages") {}
    ///             }
    ///             .monospacedDigit()
    ///         }
    ///         .padding()
    ///         .navigationTitle("monospacedDigit() Child Views")
    ///     }
    ///
    /// ![A macOS window showing four buttons, arranged in two columns. Each
    /// column's buttons contain the same text: Delete 111 messages and Delete
    /// 222 messages. The right column's buttons have fixed width, or
    /// monospaced, digits, which make the 1 characters wider than they would be
    /// in a proportional font. Because the 1 and 2 characters are the same
    /// width in the right column, the buttons are the same
    /// width.](View-monospacedDigit-1)
    ///
    /// If a child view's base font doesn't support fixed-width digits, the font
    /// remains unchanged.
    ///
    /// - Returns: A view whose child views' fonts use fixed-width numeric
    /// characters, while leaving other characters proportionally spaced.
    @available(OpenSwiftUI_v3_0, *)
    nonisolated public func monospacedDigit() -> some View {
        transformEnvironment(\.fontModifiers) {
            $0.append(.static(Font.MonospacedDigitModifier.self))
        }
    }

    /// Modifies the fonts of all child views to use the fixed-width variant of
    /// the current font, if possible.
    ///
    /// If a child view's base font doesn't support fixed-width, the font
    /// remains unchanged.
    ///
    /// - Returns: A view whose child views' fonts use fixed-width characters,
    /// while leaving other characters proportionally spaced.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func monospaced(_ isActive: Bool = true) -> some View {
        transformEnvironment(\.fontModifiers) {
            let modifier: AnyFontModifier = .static(Font.MonospacedModifier.self)
            if isActive {
                $0.append(modifier)
            } else {
                $0.removeAll { $0.isEqual(to: modifier)}
            }
        }
    }

    /// Sets the font weight of the text in this view.
    ///
    /// - Parameter weight: One of the available font weights.
    ///   Providing `nil` removes the effect of any font weight
    ///   modifier applied higher in the view hierarchy.
    ///
    /// - Returns: A view that uses the font weight you specify.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func fontWeight(_ weight: Font.Weight?) -> some View {
        transformEnvironment(\.fontModifiers) {
            if let weight {
                $0.append(.dynamic(Font.WeightModifier(weight: weight)))
            } else {
                $0.removeAll {
                    $0 is AnyDynamicFontModifier<Font.WeightModifier>
                    || $0.isEqual(to: .static(Font.BoldModifier.self))
                }
            }
        }
    }

    /// Sets the font width of the text in this view.
    ///
    /// - Parameter width: One of the available font widths.
    ///   Providing `nil` removes the effect of any font width
    ///   modifier applied higher in the view hierarchy.
    ///
    /// - Returns: A view that uses the font width you specify.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func fontWidth(_ width: Font.Width?) -> some View {
        transformEnvironment(\.fontModifiers) {
            if let width {
                $0.append(.dynamic(Font.WidthModifier(width: width.value)))
            } else {
                $0.removeAll {
                    $0 is AnyDynamicFontModifier<Font.WidthModifier>
                }
            }
        }
    }

    /// Applies a bold font weight to the text in this view.
    ///
    /// - Parameter isActive: A Boolean value that indicates
    ///   whether bold font styling is added. The default value is `true`.
    ///
    /// - Returns: A view with bold text.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func bold(_ isActive: Bool = true) -> some View {
        transformEnvironment(\.fontModifiers) {
            let modifier: AnyFontModifier = .static(Font.BoldModifier.self)
            if isActive {
                $0.append(modifier)
            } else {
                $0.removeAll { $0.isEqual(to: modifier)}
            }
        }
    }

    /// Applies italics to the text in this view.
    ///
    /// - Parameter isActive: A Boolean value that indicates
    ///   whether italic styling is added. The default value is `true`.
    ///
    /// - Returns: A View with italic text.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func italic(_ isActive: Bool = true) -> some View {
        transformEnvironment(\.fontModifiers) {
            let modifier: AnyFontModifier = .static(Font.ItalicModifier.self)
            if isActive {
                $0.append(modifier)
            } else {
                $0.removeAll { $0.isEqual(to: modifier)}
            }
        }
    }

    /// Sets the font design of the text in this view.
    ///
    /// - Parameter design: One of the available font designs.
    ///   Providing `nil` removes the effect of any font design
    ///   modifier applied higher in the view hierarchy.
    ///
    /// - Returns: A view that uses the font design you specify.
    @available(OpenSwiftUI_v4_1, *)
    nonisolated public func fontDesign(_ design: Font.Design?) -> some View {
        transformEnvironment(\.fontModifiers) {
            if let design {
                $0.append(.dynamic(Font.DesignModifier(design: design)))
            } else {
                $0.removeAll {
                    $0 is AnyDynamicFontModifier<Font.DesignModifier>
                }
            }
        }
    }

    @_spi(UIFrameworks)
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func symbolFont(_ font: Font?) -> some View {
       environment(\.symbolFont, font)
    }

    @_spi(UIFrameworks)
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func defaultFont(_ font: Font?) -> some View {
        environment(\.defaultFont, font)
    }

    @_spi(UIFrameworks)
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func defaultSymbolFont(_ font: Font?) -> some View {
        environment(\.defaultSymbolFont, font)
    }

    /// Sets the spacing, or kerning, between characters for the text in this view.
    ///
    /// - Parameter kerning: The spacing to use between individual characters in text.
    ///   Value of `0` sets the kerning to the system default value.
    ///
    /// - Returns: A view where text has the specified amount of kerning.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func kerning(_ kerning: CGFloat) -> some View {
        environment(\.defaultKerning, kerning)
    }

    /// Sets the tracking for the text in this view.
    ///
    /// - Parameter tracking: The amount of additional space, in points, that
    ///   the view should add to each character cluster after layout. Value of `0`
    ///   sets the tracking to the system default value.
    ///
    /// - Returns: A view where text has the specified amount of tracking.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func tracking(_ tracking: CGFloat) -> some View {
        environment(\.defaultTracking, tracking)
    }

    /// Sets the vertical offset for the text relative to its baseline
    /// in this view.
    ///
    /// - Parameter baselineOffset: The amount to shift the text
    ///   vertically (up or down) relative to its baseline.
    ///
    /// - Returns: A view where text is above or below its baseline.
    @available(OpenSwiftUI_v4_0, *)
    nonisolated public func baselineOffset(_ baselineOffset: CGFloat) -> some View {
        environment(\.defaultBaselineOffset, baselineOffset)
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

// MARK: - EnvironementValues + Text Additions

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

    /// The image scale for this environment.
    @available(OpenSwiftUI_macOS_v2_0, *)
    public var imageScale: Image.Scale {
        get { self[ImageScaleKey.self] }
        set { self[ImageScaleKey.self] = newValue }
    }

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

// MARK: - EnvironmentValues + Control

private struct DividerThicknessKey: EnvironmentKey {
    static var defaultValue: CGFloat? { nil }
}

private struct DisplayCornerRadiusKey: EnvironmentKey {
    static var defaultValue: CGFloat? { nil }
}

private struct ImageScaleKey: EnvironmentKey {
    static var defaultValue: Image.Scale { .medium }
}

private struct LegibilityWeightKey: EnvironmentKey {
    static var defaultValue: LegibilityWeight? { nil }
}

private struct DisplayGamutKey: EnvironmentKey {
    static var defaultValue: DisplayGamut { .sRGB }
}

private struct DefaultRenderingModeKey: EnvironmentKey {
    static var defaultValue: Image.TemplateRenderingMode { .original }
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

private struct HorizontalUserInterfaceSizeClassKey: EnvironmentKey {
    static var defaultValue: UserInterfaceSizeClass? { .regular }
}

private struct VerticalUserInterfaceSizeClassKey: EnvironmentKey {
    static var defaultValue: UserInterfaceSizeClass? { .regular }
}

extension CachedEnvironment.ID {
    package static let horizontalSizeClass: CachedEnvironment.ID = .init()

    package static let verticalSizeClass: CachedEnvironment.ID = .init()

    package static let isPlatterPresent: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    package var horizontalSizeClass: Attribute<UserInterfaceSizeClass?> {
        mapEnvironment(id: .horizontalSizeClass) { $0.horizontalSizeClass }
    }

    package var verticalSizeClass: Attribute<UserInterfaceSizeClass?> {
        mapEnvironment(id: .verticalSizeClass) { $0.verticalSizeClass }
    }
}

@available(OpenSwiftUI_v1_0, *)
extension EnvironmentValues {
    @_spi(Private)
    @available(OpenSwiftUI_v3_0, *)
    public var dividerThickness: CGFloat {
        get { self[DividerThicknessKey.self] ?? (dynamicTypeSize.isAccessibilitySize ? 1.0 : pixelLength) }
        set { self[DividerThicknessKey.self] = newValue }
    }

    package var defaultRenderingMode: Image.TemplateRenderingMode {
        get { self[DefaultRenderingModeKey.self] }
        set { self[DefaultRenderingModeKey.self] = newValue }
    }

    @_spi(ClarityBoard)
    @available(OpenSwiftUI_v4_0, *)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(macCatalyst, unavailable)
    public var displayCornerRadius: CGFloat? {
        get { self[DisplayCornerRadiusKey.self] }
        set { self[DisplayCornerRadiusKey.self] = newValue }
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

    /// The active appearance expected of controls in a window.
    ///
    /// `ControlActiveState` and `EnvironmentValues.controlActiveState` are
    /// deprecated, use `EnvironmentValues.appearsActive` instead.
    ///
    /// Starting with macOS 15.0, the value of this environment property is
    /// strictly mapped to and from `EnvironmentValues.appearsActive` as follows:
    /// - `appearsActive == true`, `controlActiveState` returns `.key`
    /// - `appearsActive == false`, `controlActiveState` returns `.inactive`
    /// - `controlActiveState` is set to `.key` or `.active`, `appearsActive`
    ///   will be set to `true`.
    /// - `controlActiveState` is set to `.inactive`, `appearsActive` will be
    ///    set to `false`.
    @available(iOS, unavailable)
    @available(macOS, deprecated, message: "Use `EnvironmentValues.appearsActive` instead.")
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    public var controlActiveState: ControlActiveState {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }

    /// The horizontal size class of this environment.
    ///
    /// You receive a ``UserInterfaceSizeClass`` value when you read this
    /// environment value. The value tells you about the amount of horizontal
    /// space available to the view that reads it. You can read this
    /// size class like any other of the ``EnvironmentValues``, by creating a
    /// property with the ``Environment`` property wrapper:
    ///
    ///     @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    ///
    /// OpenSwiftUI sets this size class based on several factors, including:
    ///
    /// * The current device type.
    /// * The orientation of the device.
    /// * The appearance of Slide Over and Split View on iPad.
    ///
    /// Several built-in views change their behavior based on this size class.
    /// For example, a ``NavigationView`` presents a multicolumn view when
    /// the horizontal size class is ``UserInterfaceSizeClass/regular``,
    /// but a single column otherwise. You can also adjust the appearance of
    /// custom views by reading the size class and conditioning your views.
    /// If you do, be prepared to handle size class changes while
    /// your app runs, because factors like device orientation can change at
    /// runtime.
    ///
    /// In watchOS, the horizontal size class is always
    /// ``UserInterfaceSizeClass/compact``. In macOS, and tvOS, it's always
    /// ``UserInterfaceSizeClass/regular``.
    ///
    /// Writing to the horizontal size class in the environment
    /// before macOS 14.0, tvOS 17.0, and watchOS 10.0 is not supported.
    @available(OpenSwiftUI_v1_0, *)
    public var horizontalSizeClass: UserInterfaceSizeClass? {
        get { realHorizontalSizeClass }
        set { realHorizontalSizeClass = newValue }
    }

    @available(OpenSwiftUI_v1_0, *)
    @usableFromInline
    var realHorizontalSizeClass: UserInterfaceSizeClass? {
        get { self[HorizontalUserInterfaceSizeClassKey.self] }
        set { self[HorizontalUserInterfaceSizeClassKey.self] = newValue }
    }

    /// The vertical size class of this environment.
    ///
    /// You receive a ``UserInterfaceSizeClass`` value when you read this
    /// environment value. The value tells you about the amount of vertical
    /// space available to the view that reads it. You can read this
    /// size class like any other of the ``EnvironmentValues``, by creating a
    /// property with the ``Environment`` property wrapper:
    ///
    ///     @Environment(\.verticalSizeClass) private var verticalSizeClass
    ///
    /// SwiftUI sets this size class based on several factors, including:
    ///
    /// * The current device type.
    /// * The orientation of the device.
    ///
    /// You can adjust the appearance of custom views by reading this size
    /// class and conditioning your views. If you do, be prepared to
    /// handle size class changes while your app runs, because factors like
    /// device orientation can change at runtime.
    ///
    /// In watchOS, the vertical size class is always
    /// ``UserInterfaceSizeClass/compact``. In macOS, and tvOS, it's always
    /// ``UserInterfaceSizeClass/regular``.
    ///
    /// Writing to the vertical size class in the environment
    /// before macOS 14.0, tvOS 17.0, and watchOS 10.0 is not supported.
    @available(OpenSwiftUI_v1_0, *)
    public var verticalSizeClass: UserInterfaceSizeClass? {
        get { realVerticalSizeClass }
        set { realVerticalSizeClass = newValue }
    }

    @available(OpenSwiftUI_v1_0, *)
    @usableFromInline
    var realVerticalSizeClass: UserInterfaceSizeClass? {
        get { self[VerticalUserInterfaceSizeClassKey.self] }
        set { self[VerticalUserInterfaceSizeClassKey.self] = newValue }
    }
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
