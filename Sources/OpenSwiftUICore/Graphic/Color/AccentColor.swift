//
//  AccentColor.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: AA5C9AAB6528C7C6B599DF55246DE53A (SwiftUICore)

// MARK: - Color + accentColor

@available(OpenSwiftUI_v1_0, *)
extension Color {

    /// A color that reflects the accent color of the system or app.
    ///
    /// The accent color is a broad theme color applied to
    /// views and controls. You can set it at the application level by specifying
    /// an accent color in your app's asset catalog.
    ///
    /// > Note: In macOS, OpenSwiftUI applies customization of the accent color
    /// only if the user chooses Multicolor under General > Accent color
    /// in System Preferences.
    ///
    /// The following code renders a ``Text`` view using the app's accent color:
    ///
    ///     Text("Accent Color")
    ///         .foregroundStyle(Color.accentColor)
    ///
    public static var accentColor: Color {
        Color(provider: AccentColorProvider())
    }

    private struct AccentColorProvider: ColorProvider {
        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            let accent = environment.accentColor ?? environment.defaultAccentColor
            if let accent {
                #if os(macOS)
                return accent
                    .resolve(in: environment)
                #else
                return accent
                    .tintAdjustmentMode(environment.effectiveTintAdjustmentMode)
                    .resolve(in: environment)
                #endif
            } else {
                return Color.blue.resolve(in: environment)
            }
        }
    }
}

// MARK: - View + accentColor

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Sets the accent color for this view and the views it contains.
    ///
    /// Use `accentColor(_:)` when you want to apply a broad theme color to
    /// your app's user interface. Some styles of controls use the accent color
    /// as a default tint color.
    ///
    /// > Note: In macOS, OpenSwiftUI applies customization of the accent color
    /// only if the user chooses Multicolor under General > Accent color
    /// in System Preferences.
    ///
    /// In the example below, the outer ``VStack`` contains two child views. The
    /// first is a button with the default accent color. The second is a ``VStack``
    /// that contains a button and a slider, both of which adopt the purple
    /// accent color of their containing view. Note that the ``Text`` element
    /// used as a label alongside the `Slider` retains its default color.
    ///
    ///     VStack(spacing: 20) {
    ///         Button(action: {}) {
    ///             Text("Regular Button")
    ///         }
    ///         VStack {
    ///             Button(action: {}) {
    ///                 Text("Accented Button")
    ///             }
    ///             HStack {
    ///                 Text("Accented Slider")
    ///                 Slider(value: $sliderValue, in: -100...100, step: 0.1)
    ///             }
    ///         }
    ///         .accentColor(.purple)
    ///     }
    ///
    /// ![A VStack showing two child views: one VStack containing a default
    /// accented button, and a second VStack where the VStack has a purple
    /// accent color applied. The accent color modifies the enclosed button and
    /// slider, but not the color of a Text item used as a label for the
    /// slider.](View-accentColor-1)
    ///
    /// - Parameter accentColor: The color to use as an accent color. Set the
    ///   value to `nil` to use the inherited accent color.
    @available(*, deprecated, message: "Use the asset catalog's accent color or View.tint(_:) instead.")
    @inlinable
    nonisolated public func accentColor(_ accentColor: Color?) -> some View {
        environment(\.accentColor, accentColor)
    }
}

// MARK: - EnvironmentValues + accentColor

@available(OpenSwiftUI_v1_0, *)
extension EnvironmentValues {
    @usableFromInline
    package var accentColor: Color? {
        get { self[AccentColorKey.self] }
        set { self[AccentColorKey.self] = newValue }
    }
}

private struct AccentColorKey: EnvironmentKey {
    static var defaultValue: Color? { nil }
}

// MARK: - DefaultAccentColorProvider

extension EnvironmentValues {
    package var defaultAccentColor: Color? {
        defaultAccentColorProvider?.accentColor(in: self)
    }

    package var defaultAccentColorProvider: (any DefaultAccentColorProvider.Type)? {
        get { self[DefaultAccentColorProviderKey.self] }
        set { self[DefaultAccentColorProviderKey.self] = newValue }
    }

    private struct DefaultAccentColorProviderKey: EnvironmentKey {
        static var defaultValue: (any DefaultAccentColorProvider.Type)? { nil }
    }
}

package protocol DefaultAccentColorProvider {
    static func accentColor(in env: EnvironmentValues) -> Color
}

// MARK: - SystemAccentColor

extension EnvironmentValues {
    package var systemAccentColor: Color {
        #if os(macOS)
        guard let systemAccentValueProvider else {
            return .blue
        }
        let colorName = systemAccentValueProvider.accentColorName(value: systemAccentValue)
        guard let color = appearance(allowsVibrantBlending: nil)
            .asset(for: colorName)?
            .0
        else {
            return .blue
        }
        return Color(color)
        #else
        return .blue
        #endif
    }

    package var systemAccentValue: SystemAccentValue {
        get {
            self[SystemAccentValueKey.self]
                ?? systemAccentValueProvider?.defaultValue
                ?? .multicolor
        }
        set {
            self[SystemAccentValueKey.self] = newValue
        }
    }

    package var systemAccentValueProvider: (any SystemAccentValueProvider.Type)? {
        get { self[SystemAccentValueProviderKey.self] }
        set { self[SystemAccentValueProviderKey.self] = newValue }
    }

    private struct SystemAccentValueProviderKey: EnvironmentKey {
        static var defaultValue: (any SystemAccentValueProvider.Type)? { nil }
    }
}

package enum SystemAccentValue: Int, Equatable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case pink
    case graphite
    case multicolor
    case hardware
}

private struct SystemAccentValueKey: EnvironmentKey {
    static var defaultValue: SystemAccentValue? { nil }
}

package protocol SystemAccentValueProvider {
    static var defaultValue: SystemAccentValue { get }

    #if os(macOS)
    static func accentColorName(value: SystemAccentValue) -> CoreUISystemCatalogColorName
    #endif
}

// FIXME: TintAdjustmentMode
package extension EnvironmentValues {
    var effectiveTintAdjustmentMode: TintAdjustmentMode {
        .normal
    }
}

package enum TintAdjustmentMode {
    case normal
    case desaturated
}

extension Color {
    package func tintAdjustmentMode(_ mode: TintAdjustmentMode) -> Color {
        self
    }

    package var tintAdjusted: Color {
        self
    }
}
