//
//  DefaultToggleStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

@available(OpenSwiftUI_v1_0, *)
extension ToggleStyle where Self == DefaultToggleStyle {
    /// The default toggle style.
    ///
    /// Use this ``ToggleStyle`` to let OpenSwiftUI pick a suitable style for
    /// the current platform and context. Toggles use the `automatic` style
    /// by default, but you might need to set it explicitly using the
    /// ``View/toggleStyle(_:)`` modifier to override another style
    /// in the environment. For example, you can request automatic styling for
    /// a toggle in an ``HStack`` that's otherwise configured to use the
    /// ``ToggleStyle/button`` style:
    ///
    ///     HStack {
    ///         Toggle(isOn: $isShuffling) {
    ///             Label("Shuffle", systemImage: "shuffle")
    ///         }
    ///         Toggle(isOn: $isRepeating) {
    ///             Label("Repeat", systemImage: "repeat")
    ///         }
    ///
    ///         Divider()
    ///
    ///         Toggle("Enhance Sound", isOn: $isEnhanced)
    ///             .toggleStyle(.automatic) // Set the style automatically here.
    ///     }
    ///     .toggleStyle(.button) // Use button style for toggles in the stack.
    ///
    /// ### Platform defaults
    ///
    /// The `automatic` style produces an appearance that varies by platform,
    /// using the following styles in most contexts:
    ///
    /// | Platform    | Default style                            |
    /// |-------------|------------------------------------------|
    /// | iOS, iPadOS | ``ToggleStyle/switch``                   |
    /// | macOS       | ``ToggleStyle/checkbox``                 |
    /// | tvOS        | ``ToggleStyle/switch``                   |
    /// | watchOS     | ``ToggleStyle/switch``                   |
    ///
    /// The default style for tvOS behaves like a button. However,
    /// unlike the ``ToggleStyle/switch`` style that's on other platforms, the
    /// tvOS toggle takes as much horizontal space as its parent offers, and
    /// displays both the toggle's label and a text field that indicates the
    /// toggle's state. You typically collect tvOS toggles into a ``List``:
    ///
    ///     List {
    ///         Toggle("Show Lyrics", isOn: $isShowingLyrics)
    ///         Toggle("Shuffle", isOn: $isShuffling)
    ///         Toggle("Repeat", isOn: $isRepeating)
    ///     }
    ///
    /// ![A screenshot of three buttons labeled Show Lyrics, Shuffle, and
    /// Repeat, stacked vertically. The first is highlighted. The second is
    /// on, while the others are off.](ToggleStyle-automatic-2-tvOS)
    ///
    /// ### Contextual defaults
    ///
    /// A toggle's automatic appearance varies in certain contexts:
    ///
    /// * A toggle that appears as part of the content that you provide to one
    ///   of the toolbar modifiers, like ``View/toolbar(content:)``, uses
    ///   the ``ToggleStyle/button`` style by default.
    ///
    /// * A toggle in a ``Menu`` uses a style that you can't create explicitly:
    ///
    ///       Menu("Playback") {
    ///           Toggle("Show Lyrics", isOn: $isShowingLyrics)
    ///           Toggle("Shuffle", isOn: $isShuffling)
    ///           Toggle("Repeat", isOn: $isRepeating)
    ///       }
    ///
    ///   OpenSwiftUI shows the toggle's label with a checkmark that appears only
    ///   in the `on` state:
    ///
    ///   | Platform    | Appearance |
    ///   |-------------|------------|
    ///   | iOS, iPadOS | ![A screenshot of a Playback menu in iOS showing three menu items with the labels Repeat, Shuffle, and Show Lyrics. The shuffle item has a checkmark to its left, while the other two items have a blank space to their left.](ToggleStyle-automatic-1-iOS) |
    ///   | macOS       | ![A screenshot of a Playback menu in macOS showing three menu items with the labels Repeat, Shuffle, and Show Lyrics. The shuffle item has a checkmark to its left, while the other two items have a blank space to their left.](ToggleStyle-automatic-1-macOS) |
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var automatic: DefaultToggleStyle {
        .init()
    }
}

/// The default toggle style.
///
/// Use the ``ToggleStyle/automatic`` static variable to create this style:
///
///     Toggle("Enhance Sound", isOn: $isEnhanced)
///         .toggleStyle(.automatic)
///
@available(OpenSwiftUI_v1_0, *)
public struct DefaultToggleStyle: ToggleStyle {
    /// Creates a default toggle style.
    ///
    /// Don't call this initializer directly. Instead, use the
    /// ``ToggleStyle/automatic`` static variable to create this style:
    ///
    ///     Toggle("Enhance Sound", isOn: $isEnhanced)
    ///         .toggleStyle(.automatic)
    ///
    public init() {
        _openSwiftUIEmptyStub()
    }

    /// Creates a view that represents the body of a toggle.
    ///
    /// OpenSwiftUI implements this required method of the ``ToggleStyle``
    /// protocol to define the behavior and appearance of the
    /// ``ToggleStyle/automatic`` toggle style. Don't call this method
    /// directly. Rather, the system calls this method for each
    /// ``Toggle`` instance in a view hierarchy that needs the default
    /// style.
    ///
    /// - Parameter configuration: The properties of the toggle, including a
    ///   label and a binding to the toggle's state.
    /// - Returns: A view that acts as a toggle.
    public func makeBody(configuration: Configuration) -> some View {
        #if canImport(Darwin)
        Toggle(configuration)
            .modifier(
                ToggleStyleModifier(style: ButtonToggleStyle())
                    .requiring(InterfaceIdiomPredicate<WidgetInterfaceIdiom>.self)
            )
            .modifier(
                ToggleStyleModifier(style: DefaultListToggleStyle())
                    .requiring(AnyListStyleContext.self)
            )
            #if os(iOS) || os(visionOS)
            .modifier(
                ToggleStyleModifier(style: DefaultListToggleStyle())
                    .requiring(GroupedFormStyleContext.self)
            )
            #endif
            .modifier(
                ToggleStyleModifier(style: CheckmarkToggleStyle())
                    .requiring(MenuStyleContext.self)
            )
            #if os(macOS)
            .modifier(
                ToggleStyleModifier(style: ButtonToggleStyle())
                    .requiring(ToolbarStyleContext.self)
            )
            .modifier(
                ToggleStyleModifier(style: CheckboxToggleStyle())
                    .requiring(GroupedFormValueStyleContext.self)
            )
            .modifier(
                ToggleStyleModifier(style: SwitchToggleStyle())
                    .requiring(GroupedFormStyleContext.self)
            )
            .modifier(
                ToggleStyleModifier(style: ButtonToggleStyle())
                    .requiring(SidebarSectionActionStyleContext.self)
            )
            #else
            .modifier(
                ToggleStyleModifier(style: ToolbarToggleStyle())
                    .requiring(ToolbarStyleContext.self)
            )
            #endif
            .modifier(
                ToggleStyleModifier(style: AccessibilityToggleStyle())
                    .requiring(AccessibilityRepresentableStyleContext.self)
            )
            .toggleStyle(PlatformFallbackToggleStyle())
            #if os(macOS)
            .modifier(ToolbarStyleContextModifier().requiring(ToolbarStyleContext.self))
            #endif
        #else
        Toggle(configuration)
            .toggleStyle(PlatformFallbackToggleStyle())
        #endif
    }
}

@available(*, unavailable)
extension DefaultToggleStyle: Sendable {}

struct PlatformFallbackToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        #if os(macOS)
        Toggle(configuration).toggleStyle(.checkbox)
        #elseif os(iOS) || os(visionOS)
        Toggle(configuration).toggleStyle(.switch)
        #else
        Toggle(configuration).toggleStyle(.switch)
        #endif
    }
}
