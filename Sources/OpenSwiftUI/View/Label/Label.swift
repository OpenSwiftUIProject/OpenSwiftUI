//
//  Label.swift
//  OpenSwiftUI
//  ID: BA61BB07629D532149CADBB7B4434E7E (SwiftUI)
//
//  Audited for 6.5.4
//  Status: WIP

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - Accessibility label inputs

struct AccessibilityHidesLabelIcon: ViewInputPredicate {
    static func evaluate(inputs _: _GraphInputs) -> Bool {
        false
    }
}

struct AccessibilityShowsLabelIcon: ViewInputBoolFlag {}

// MARK: - Label

/// A standard label for user interface items, consisting of an icon with a
/// title.
///
/// One of the most common and recognizable user interface components is the
/// combination of an icon and a label. This idiom appears across many kinds of
/// apps and shows up in collections, lists, menus of action items, and
/// disclosable lists, just to name a few.
///
/// You create a label, in its simplest form, by providing a title and the name
/// of an image, such as an icon from the
/// <doc://com.apple.documentation/design/human-interface-guidelines/sf-symbols>
/// collection:
///
///     Label("Lightning", systemImage: "bolt.fill")
///
/// You can also apply styles to labels in several ways. In the case of dynamic
/// changes to the view after device rotation or change to a window size you
/// might want to show only the text portion of the label using the
/// ``LabelStyle/titleOnly`` label style:
///
///     Label("Lightning", systemImage: "bolt.fill")
///         .labelStyle(.titleOnly)
///
/// Conversely, there's also an icon-only label style:
///
///     Label("Lightning", systemImage: "bolt.fill")
///         .labelStyle(.iconOnly)
///
/// Some containers might apply a different default label style, such as only
/// showing icons within toolbars on macOS and iOS. To opt in to showing both
/// the title and the icon, you can apply the ``LabelStyle/titleAndIcon`` label
/// style:
///
///     Label("Lightning", systemImage: "bolt.fill")
///         .labelStyle(.titleAndIcon)
///
/// You can also create a customized label style by modifying an existing
/// style; this example adds a red border to the default label style:
///
///     struct RedBorderedLabelStyle: LabelStyle {
///         func makeBody(configuration: Configuration) -> some View {
///             Label(configuration)
///                 .border(Color.red)
///         }
///     }
///
/// For more extensive customization or to create a completely new label style,
/// you'll need to adopt the ``LabelStyle`` protocol and implement a
/// ``LabelStyleConfiguration`` for the new style.
///
/// To apply a common label style to a group of labels, apply the style
/// to the view hierarchy that contains the labels:
///
///     VStack {
///         Label("Rain", systemImage: "cloud.rain")
///         Label("Snow", systemImage: "snow")
///         Label("Sun", systemImage: "sun.max")
///     }
///     .labelStyle(.iconOnly)
///
/// It's also possible to make labels using views to compose the label's icon
/// programmatically, rather than using a pre-made image. In this example, the
/// icon portion of the label uses a filled ``Circle`` overlaid
/// with the user's initials:
///
///     Label {
///         Text(person.fullName)
///             .font(.body)
///             .foregroundColor(.primary)
///         Text(person.title)
///             .font(.subheadline)
///             .foregroundColor(.secondary)
///     } icon: {
///         Circle()
///             .fill(person.profileColor)
///             .frame(width: 44, height: 44, alignment: .center)
///             .overlay(Text(person.initials))
///     }
@available(OpenSwiftUI_v2_0, *)
public struct Label<Title, Icon>: View where Title: View, Icon: View {
    var title: Title

    var icon: Icon

    /// Creates a label with a custom title and icon.
    public init(
        @ViewBuilder title: () -> Title,
        @ViewBuilder icon: () -> Icon
    ) {
        self.title = title()
        self.icon = icon()
    }

    public var body: some View {
        ResolvedLabelStyle(configuration: .init())
            .viewAlias(LabelStyleConfiguration.Icon.self) {
                icon
            }
            .viewAlias(LabelStyleConfiguration.Title.self) {
                title
            }
    }
}

@available(*, unavailable)
extension Label: Sendable {}

// MARK: - Label + Text and Image

@available(OpenSwiftUI_v2_0, *)
extension Label where Title == Text, Icon == Image {
    /// Creates a label with an icon image and a title generated from a
    /// localized string.
    ///
    /// - Parameters:
    ///    - titleKey: A title generated from a localized string.
    ///    - image: The name of the image resource to lookup.
    nonisolated public init(_ titleKey: LocalizedStringKey, image name: String) {
        self.init {
            Text(titleKey)
        } icon: {
            Image(name)
        }
    }

    /// Creates a label with a system icon image and a title generated from a
    /// localized string.
    ///
    /// - Parameters:
    ///    - titleKey: A title generated from a localized string.
    ///    - systemImage: The name of the image resource to lookup.
    nonisolated public init(_ titleKey: LocalizedStringKey, systemImage name: String) {
        self.init {
            Text(titleKey)
        } icon: {
            Image(systemName: name)
        }
    }

    /// Creates a label with an icon image and a title generated from a string.
    ///
    /// - Parameters:
    ///    - title: A string used as the label's title.
    ///    - image: The name of the image resource to lookup.
    @_disfavoredOverload
    nonisolated public init<S>(_ title: S, image name: String) where S: StringProtocol {
        self.init {
            Text(title)
        } icon: {
            Image(name)
        }
    }

    /// Creates a label with a system icon image and a title generated from a
    /// string.
    ///
    /// - Parameters:
    ///    - title: A string used as the label's title.
    ///    - systemImage: The name of the image resource to lookup.
    @_disfavoredOverload
    nonisolated public init<S>(_ title: S, systemImage name: String) where S: StringProtocol {
        self.init {
            Text(title)
        } icon: {
            Image(systemName: name)
        }
    }
}

#if canImport(Darwin) && canImport(DeveloperToolsSupport)
// MARK: - Label + ImageResource

@available(OpenSwiftUI_v5_0, *)
extension Label where Title == Text, Icon == Image {
    /// Creates a label with an icon image and a title generated from a
    /// localized string.
    ///
    /// - Parameters:
    ///    - titleKey: A title generated from a localized string.
    ///    - image: The image resource to lookup.
    nonisolated public init(_ titleKey: LocalizedStringKey, image resource: ImageResource) {
        self.init {
            Text(titleKey)
        } icon: {
            Image(resource)
        }
    }

    /// Creates a label with an icon image and a title generated from a string.
    ///
    /// - Parameters:
    ///    - title: A string used as the label's title.
    ///    - image: The image resource to lookup.
    @_disfavoredOverload
    nonisolated public init<S>(_ title: S, image resource: ImageResource) where S: StringProtocol {
        self.init {
            Text(title)
        } icon: {
            Image(resource)
        }
    }
}
#endif

// MARK: - Label + LabelStyleConfiguration

@available(OpenSwiftUI_v2_0, *)
extension Label where Title == LabelStyleConfiguration.Title, Icon == LabelStyleConfiguration.Icon {
    /// Creates a label representing the configuration of a style.
    ///
    /// You can use this initializer within the ``LabelStyle/makeBody(configuration:)``
    /// method of a ``LabelStyle`` instance to create an instance of the label
    /// that's being styled. This is useful for custom label styles that only
    /// wish to modify the current style, as opposed to implementing a brand new
    /// style.
    ///
    /// For example, the following style adds a red border around the label,
    /// but otherwise preserves the current style:
    ///
    ///     struct RedBorderedLabelStyle: LabelStyle {
    ///         func makeBody(configuration: Configuration) -> some View {
    ///             Label(configuration)
    ///                 .border(Color.red)
    ///         }
    ///     }
    ///
    /// - Parameter configuration: The label style to use.
    nonisolated public init(_ configuration: LabelStyleConfiguration) {
        title = configuration.title
        icon = configuration.icon
    }
}

// MARK: - ResolvedLabelStyle

private struct ResolvedLabelStyle: StyleableView {
    var configuration: LabelStyleConfiguration

    static var defaultStyleModifier: LabelStyleModifier<DefaultLabelStyle> {
        LabelStyleModifier(style: DefaultLabelStyle())
    }

    var body: some View {
        Label(configuration)
    }
}
