//
//  AppearsActive.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - AppearsActiveKey

/// Whether views and styles in this environment should prefer an active
/// appearance over an inactive appearance.
@available(OpenSwiftUI_v6_0, *)
@usableFromInline
package struct AppearsActiveKey: EnvironmentKey {
    @usableFromInline
    package static var defaultValue: Bool { true }
}

@available(*, unavailable)
extension AppearsActiveKey: Sendable {}

@available(OpenSwiftUI_v6_0, *)
extension EnvironmentValues {

    /// Whether views and styles in this environment should prefer an active
    /// appearance over an inactive appearance.
    ///
    /// On macOS, views in the focused window (also referred to as the "key"
    /// window) should appear active. Some contexts also appear active in other
    /// circumstances, such as the contents of a window toolbar appearing active
    /// when the window is not focused but is the main window.
    ///
    /// Typical adjustments made when a view does not appear active include:
    /// - Uses of `Color.accentColor` should generally be removed or replaced
    ///   with a desaturated style.
    /// - Text and image content in sidebars should appear dimmer.
    /// - Buttons with destructive actions should appear disabled.
    /// - `ShapeStyle.selection` and selection in list and tables will
    ///   automatically become a grey color
    ///
    /// Custom views, styles, and shape styles can use this to adjust their
    /// own appearance:
    ///
    ///     struct ProminentPillButtonStyle: ButtonStyle {
    ///         @Environment(\.appearsActive) private var appearsActive
    ///
    ///         func makeBody(configuration: Configuration) -> some View {
    ///             configuration.label
    ///                 .lineLimit(1)
    ///                 .padding(.horizontal, 8)
    ///                 .padding(.vertical, 2)
    ///                 .frame(minHeight: 20)
    ///                 .overlay(Capsule().strokeBorder(.tertiary))
    ///                 .background(appearsActive ? Color.accentColor : .clear, in: .capsule)
    ///                 .contentShape(.capsule)
    ///         }
    ///     }
    ///
    /// On all other platforms, this value is always `true`.
    ///
    /// This is bridged with `UITraitCollection.activeAppearance` for UIKit
    /// hosted content.
    public var appearsActive: Bool {
        get { self[AppearsActiveKey.self] }
        set { self[AppearsActiveKey.self] = newValue }
    }
}
