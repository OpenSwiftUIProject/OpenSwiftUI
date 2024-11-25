//
//  ColorScheme.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 387C753F3FFD2899BCB77252214CFCC6 (SwiftUI)
//  ID: 0E72AB1FBE33AED1E73FF06F3DA3A071 (SwiftUICore)

package import OpenGraphShims

// MARK: - ColorScheme

/// The possible color schemes, corresponding to the light and dark appearances.
///
/// You receive a color scheme value when you read the
/// ``EnvironmentValues/colorScheme`` environment value. The value tells you if
/// a light or dark appearance currently applies to the view. OpenSwiftUI updates
/// the value whenever the appearance changes, and redraws views that
/// depend on the value. For example, the following ``Text`` view automatically
/// updates when the user enables Dark Mode:
///
///     @Environment(\.colorScheme) private var colorScheme
///
///     var body: some View {
///         Text(colorScheme == .dark ? "Dark" : "Light")
///     }
///
/// Set a preferred appearance for a particular view hierarchy to override
/// the user's Dark Mode setting using the ``View/preferredColorScheme(_:)``
/// view modifier.
public enum ColorScheme: CaseIterable, Sendable {
    /// The color scheme that corresponds to a light appearance.
    case light
    
    /// The color scheme that corresponds to a dark appearance.
    case dark
}

// MARK: - ColorSchemeContrast

/// The contrast between the app's foreground and background colors.
///
/// You receive a contrast value when you read the
/// ``EnvironmentValues/colorSchemeContrast`` environment value. The value
/// tells you if a standard or increased contrast currently applies to the view.
/// OpenSwiftUI updates the value whenever the contrast changes, and redraws
/// views that depend on the value. For example, the following ``Text`` view
/// automatically updates when the user enables increased contrast:
///
///     @Environment(\.colorSchemeContrast) private var colorSchemeContrast
///
///     var body: some View {
///         Text(colorSchemeContrast == .standard ? "Standard" : "Increased")
///     }
///
/// The user sets the contrast by selecting the Increase Contrast option in
/// Accessibility > Display in System Preferences on macOS, or
/// Accessibility > Display & Text Size in the Settings app on iOS.
/// Your app can't override the user's choice. For
/// information about using color and contrast in your app, see
/// [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility#Color-and-effects).
/// in the Human Interface Guidelines.
public enum ColorSchemeContrast: CaseIterable, Sendable {
    
    /// OpenSwiftUI displays views with standard contrast between the app's
    /// foreground and background colors.
    case standard
    
    /// OpenSwiftUI displays views with increased contrast between the app's
    /// foreground and background colors.
    case increased
}

// MARK: - View + ColorScheme

extension View {
    /// Sets this view's color scheme.
    ///
    /// Use `colorScheme(_:)` to set the color scheme for the view to which you
    /// apply it and any subviews. If you want to set the color scheme for all
    /// views in the presentation, use ``View/preferredColorScheme(_:)``
    /// instead.
    ///
    /// - Parameter colorScheme: The color scheme for this view.
    ///
    /// - Returns: A view that sets this view's color scheme.
    @inlinable
    nonisolated public func colorScheme(_ colorScheme: ColorScheme) -> some View {
        environment(\.colorScheme, colorScheme)
    }
}

// MARK: - ColorScheme + EnvironmentValues

extension EnvironmentValues {
    /// The color scheme of this environment.
    ///
    /// Read this environment value from within a view to find out if OpenSwiftUI
    /// is currently displaying the view using the ``ColorScheme/light`` or
    /// ``ColorScheme/dark`` appearance. The value that you receive depends on
    /// whether the user has enabled Dark Mode, possibly superseded by
    /// the configuration of the current presentation's view hierarchy.
    ///
    ///     @Environment(\.colorScheme) private var colorScheme
    ///
    ///     var body: some View {
    ///         Text(colorScheme == .dark ? "Dark" : "Light")
    ///     }
    ///
    /// You can set the `colorScheme` environment value directly,
    /// but that usually isn't what you want. Doing so changes the color
    /// scheme of the given view and its child views but *not* the views
    /// above it in the view hierarchy. Instead, set a color scheme using the
    /// ``View/preferredColorScheme(_:)`` modifier, which also propagates the
    /// value up through the view hierarchy to the enclosing presentation, like
    /// a sheet or a window.
    ///
    /// When adjusting your app's user interface to match the color scheme,
    /// consider also checking the ``EnvironmentValues/colorSchemeContrast``
    /// property, which reflects a system-wide contrast setting that the user
    /// controls. For information, see
    /// [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility#Color-and-effects).
    /// in the Human Interface Guidelines.
    ///
    /// > Note: If you only need to provide different colors or
    /// images for different color scheme and contrast settings, do that in
    /// your app's Asset Catalog. See
    /// [Asset management](https://developer.apple.com/documentation/xcode/asset-management).
    public var colorScheme: ColorScheme {
        get { self[ColorSchemeKey.self] }
        set { self[ColorSchemeKey.self] = newValue }
    }
    
    package var explicitPreferredColorScheme: ColorScheme? {
        get { self[ExplicitPreferredColorSchemeKey.self] }
        set { self[ExplicitPreferredColorSchemeKey.self] = newValue }
    }
    
    package var systemColorScheme: ColorScheme {
        get { self[SystemColorSchemeKey.self] }
        set { self[SystemColorSchemeKey.self] = newValue }
    }
    
    /// The contrast associated with the color scheme of this environment.
    ///
    /// Read this environment value from within a view to find out if OpenSwiftUI
    /// is currently displaying the view using ``ColorSchemeContrast/standard``
    /// or ``ColorSchemeContrast/increased`` contrast. The value that you read
    /// depends entirely on user settings, and you can't change it.
    ///
    ///     @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    ///
    ///     var body: some View {
    ///         Text(colorSchemeContrast == .standard ? "Standard" : "Increased")
    ///     }
    ///
    /// When adjusting your app's user interface to match the contrast,
    /// consider also checking the ``EnvironmentValues/colorScheme`` property
    /// to find out if OpenSwiftUI is displaying the view with a light or dark
    /// appearance. For information, see
    /// [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility#Color-and-effects).
    /// in the Human Interface Guidelines.
    ///
    /// > Note: If you only need to provide different colors or
    /// images for different color scheme and contrast settings, do that in
    /// your app's Asset Catalog. See
    /// [Asset management](https://developer.apple.com/documentation/xcode/asset-management).
    public var colorSchemeContrast: ColorSchemeContrast {
        self[ColorSchemeContrastKey.self]
    }
    
    public var _colorSchemeContrast: ColorSchemeContrast {
        get { self[ColorSchemeContrastKey.self] }
        set { self[ColorSchemeContrastKey.self] = newValue }
    }
}

private struct ColorSchemeKey: EnvironmentKey {
    static let defaultValue: ColorScheme = .light
}

private struct SystemColorSchemeKey: EnvironmentKey {
    static let defaultValue: ColorScheme = .light
}

private struct ExplicitPreferredColorSchemeKey: EnvironmentKey {
    static let defaultValue: ColorScheme? = nil
}

private struct ColorSchemeContrastKey: EnvironmentKey {
    static var defaultValue: ColorSchemeContrast = .standard
}

// MARK: - SystemColorSchemeModifier

@MainActor
@preconcurrency
package struct SystemColorSchemeModifier: ViewModifier, PrimitiveViewModifier, EnvironmentModifier {
    package var isEnabled: Bool
    
    package init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    nonisolated package static func makeEnvironment(modifier: Attribute<SystemColorSchemeModifier>, environment: inout EnvironmentValues) {
        guard modifier.value.isEnabled else { return }
        environment.colorScheme = environment.systemColorScheme
    }

    package typealias Body = Never
}

// MARK: - ColorScheme + ProtobufEnum

extension ColorScheme: ProtobufEnum {
    package var protobufValue: UInt {
        switch self {
            case .light: return 0
            case .dark: return 1
        }
    }
    
    package init?(protobufValue: UInt) {
        switch protobufValue {
            case 0: self = .light
            case 1: self = .dark
            default: return nil
        }
    }
}

// MARK: - ColorSchemeContrast + ProtobufEnum

extension ColorSchemeContrast: ProtobufEnum {
    package var protobufValue: UInt {
        switch self {
            case .standard: return 0
            case .increased: return 1
        }
    }
    
    package init?(protobufValue: UInt) {
        switch protobufValue {
            case 0: self = .standard
            case 1: self = .increased
            default: return nil
        }
    }
}
