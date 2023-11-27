//
//  Link.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/28.
//  Lastest Version: iOS 15.0
//  Status: Blocked by Text

import Foundation

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
/// ``View/foregroundColor(_:)`` to customize the appearance of the link in
/// your app's UI.
public struct Link<Label>: View where Label: View {
    /// Creates a control, consisting of a URL and a label, used to navigate
    /// to the given URL.
    ///
    /// - Parameters:
    ///     - destination: The URL for the link.
    ///     - label: A view that describes the destination of URL.
    public init(destination: URL, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.destination = LinkDestination(configuration: .init(url: destination, isSensitive: false))
    }

    init(sensitiveUrl: URL, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.destination = LinkDestination(configuration: .init(url: sensitiveUrl, isSensitive: true))
    }

    init(configuration: LinkDestination.Configuration, label: Label) {
        self.label = label
        self.destination = LinkDestination(configuration: configuration)
    }

    public var body: some View {
        Button {
            destination.open()
        } label: {
            label
        }
    }

    var label: Label
    var destination: LinkDestination
}

// extension Link where Label == Text {
//    public init(_ titleKey: LocalizedStringKey, destination: URL) {
//
//    }
//
//    @_disfavoredOverload
//    public init<S>(_ title: S, destination: URL) where S : StringProtocol {
//
//    }
// }
