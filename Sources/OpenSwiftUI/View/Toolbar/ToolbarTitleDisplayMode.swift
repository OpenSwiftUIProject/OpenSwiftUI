//
//  ToolbarTitleDisplayMode.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - ToolbarTitleDisplayMode

/// A type that defines the behavior of title of a toolbar.
///
/// Use the ``View/toolbarTitleDisplayMode(_:)`` modifier to configure
/// the title display behavior of your toolbar:
///
///     NavigationStack {
///         ContentView()
///             .toolbarTitleDisplayMode(.inlineLarge)
///     }
///
@available(OpenSwiftUI_v5_0, *)
public struct ToolbarTitleDisplayMode {
    package enum Role {
        case automatic
        case large
        case inlineLarge
        case inline
        case settings
    }

    package var role: ToolbarTitleDisplayMode.Role

    package init(role: ToolbarTitleDisplayMode.Role) {
        self.role = role
    }

    /// The automatic mode.
    ///
    /// For root content in a navigation stack in iOS, iPadOS, or tvOS
    /// this behavior will:
    ///   - Default to ``ToolbarTitleDisplayMode/large``
    ///     when a navigation title is configured.
    ///   - Default to ``ToolbarTitleDisplayMode/inline``
    ///     when no navigation title is provided.
    ///
    /// In all platforms, content pushed onto a navigation stack will use the
    /// behavior of the content already on the navigation stack. This
    /// has no effect in macOS.
    public static var automatic: ToolbarTitleDisplayMode { .init(role: .automatic) }

    /// The large mode.
    ///
    /// In iOS, and watchOS, this displays the toolbar title below the
    /// content of the navigation bar when scrollable content is scrolled
    /// to the top and transitions to the center of the toolbar as
    /// content is scrolled.
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    public static var large: ToolbarTitleDisplayMode{ .init(role: .large) }

    /// The inline large mode.
    ///
    /// In iOS, this behavior displays the title as large inside the toolbar
    /// and moves any leading or centered toolbar items into the overflow menu
    /// of the toolbar. This has no effect in macOS.
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public static var inlineLarge: ToolbarTitleDisplayMode { .init(role: .inlineLarge) }

    /// The inline mode.
    ///
    /// In iOS, tvOS, and watchOS this mode displays the title with a
    /// smaller size in the middle of the toolbar. This has no effect
    /// in macOS.
    public static var inline: ToolbarTitleDisplayMode { .init(role: .inline) }
}

@available(*, unavailable)
extension ToolbarTitleDisplayMode: Sendable {}

@_spi(Private)
extension ToolbarTitleDisplayMode: Equatable {}

extension View {

    /// Configures the toolbar title display mode for this view.
    ///
    /// Use this modifier to override the default toolbar title display
    /// mode.
    ///
    ///     NavigationStack {
    ///         ContentView()
    ///             .toolbarTitleDisplayMode(.inlineLarge)
    ///     }
    ///
    /// See ``ToolbarTitleDisplayMode`` for more information on the
    /// different kinds of display modes. This modifier has no effect
    /// on macOS.
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func toolbarTitleDisplayMode(_ mode: ToolbarTitleDisplayMode) -> some View {
        transformPreference(NavigationTitleKey.self) { value in
            NavigationTitleKey.reduce(value: &value) {
                NavigationTitleStorage(titleMode: mode)
            }
        }
    }
}
