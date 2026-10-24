//
//  Link.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation
@_spi(Private) public import OpenSwiftUICore

/// A control for navigating to a URL.
///
/// Create a link by providing a destination URL and a title. The title
/// tells the user the purpose of the link, and can be a string, a title
/// key that produces a localized string, or a view that acts as a label.
/// The example below creates a link to `example.com` and displays the
/// title string as a link-styled view:
///
///     Link("View Our Terms of Service",
///           destination: URL(string: "https://www.example.com/TOS.html")!)
///
/// When a user taps or clicks a `Link`, the default behavior depends on the
/// contents of the URL. For example, OpenSwiftUI opens a Universal Link in the
/// associated app if possible, or in the user's default web browser if not.
/// Alternatively, you can override the default behavior by setting the
/// ``EnvironmentValues/openURL`` environment value with a custom
/// ``OpenURLAction``:
///
///     Link("Visit Our Site", destination: URL(string: "https://www.example.com")!)
///         .environment(\.openURL, OpenURLAction { url in
///             print("Open \(url)")
///             return .handled
///         })
///
/// As with other views, you can style links using standard view modifiers
/// depending on the view type of the link's label. For example, a ``Text``
/// label could be modified with a custom ``View/font(_:)`` or
/// ``View/foregroundStyle(_:)`` to customize the appearance of the link in
/// your app's UI.
@available(OpenSwiftUI_v2_0, *)
public struct Link<Label>: View where Label: View {
    var label: Label

    var destination: LinkDestination

    nonisolated init(configuration: LinkDestination.Configuration, label: Label) {
        self.label = label
        self.destination = LinkDestination(configuration: configuration)
    }

    /// Creates a control, consisting of a URL and a label, used to navigate
    /// to the given URL.
    ///
    /// - Parameters:
    ///     - destination: The URL for the link.
    ///     - label: A view that describes the destination of URL.
    nonisolated public init(destination: URL, @ViewBuilder label: () -> Label) {
        self.init(configuration: .init(url: destination), label: label())
    }

    public var body: some View {
        Button(action: destination.open) {
            label
        }
        .accessibilityConfiguration(AccessibilityLinkModifier(destination, isArchive: false))
    }
}

@available(*, unavailable)
extension Link: Sendable {}

// MARK: - Link + Text

@available(OpenSwiftUI_v2_0, *)
extension Link where Label == Text {
    /// Creates a control, consisting of a URL and a title key, used to
    /// navigate to a URL.
    ///
    /// Use ``Link`` to create a control that your app uses to navigate to a
    /// URL that you provide. The example below creates a link to
    /// `example.com` and uses `Visit Example Co` as the title key to
    /// generate a link-styled view in your app:
    ///
    ///     Link("Visit Example Co",
    ///           destination: URL(string: "https://www.example.com/")!)
    ///
    /// - Parameters:
    ///     - titleKey: The key for the localized title that describes the
    ///       purpose of this link.
    ///     - destination: The URL for the link.
    nonisolated public init(_ titleKey: LocalizedStringKey, destination: URL) {
        self.init(destination: destination) {
            Text(titleKey)
        }
    }

    /// Creates a control, consisting of a URL and a title string, used to
    /// navigate to a URL.
    ///
    /// Use ``Link`` to create a control that your app uses to navigate to a
    /// URL that you provide. The example below creates a link to
    /// `example.com` and displays the title string you provide as a
    /// link-styled view in your app:
    ///
    ///     func marketingLink(_ callToAction: String) -> Link<Text> {
    ///         Link(callToAction,
    ///             destination: URL(string: "https://www.example.com/")!)
    ///     }
    ///
    /// - Parameters:
    ///     - title: A text string used as the title for describing the
    ///       underlying `destination` URL.
    ///     - destination: The URL for the link.
    @_disfavoredOverload
    nonisolated public init<S>(_ title: S, destination: URL) where S: StringProtocol {
        self.init(destination: destination) {
            Text(title)
        }
    }
}

// MARK: - Link + ConditionallyArchivableView

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
extension Link: ConditionallyArchivableView {
    public var archivedBody: some View {
        StaticIf(Semantics.ArchivedLinkIsButton.self) {
            Button(destination: destination) {
                label
            }
            .modifier(
                ButtonStyleModifier(style: WidgetLinkButtonStyle())
                    .requiring(ButtonStylePredicate<DefaultButtonStyle>.self)
            )
        } else: {
            label
                .modifier(ArchivableLinkModifier(configuration: destination.configuration))
                .modifier(HandGestureShortcutInteractiveControl())
        }
        .accessibilityConfiguration(AccessibilityLinkModifier(destination, isArchive: true))
    }
}

// MARK: - Link + Sensitive URL

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
extension Link {
    nonisolated public init(sensitiveUrl url: URL, @ViewBuilder label: () -> Label) {
        self.init(configuration: .init(url: url, isSensitive: true), label: label())
    }
}

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
extension Link where Label == Text {
    nonisolated public init(_ titleKey: LocalizedStringKey, sensitiveUrl url: URL) {
        self.init(sensitiveUrl: url) {
            Text(titleKey)
        }
    }

    @_disfavoredOverload
    nonisolated public init<S>(_ title: S, sensitiveUrl url: URL) where S: StringProtocol {
        self.init(sensitiveUrl: url) {
            Text(title)
        }
    }
}
