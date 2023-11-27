//
//  EnvironmentValues+OpenURLActionKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/11/26.
//  Lastest Version: iOS 15.5
//  Status: WIP

#if canImport(Darwin)
#if os(iOS) || os(tvOS)
import UIKit
#if DEBUG
private import UIKitCore
private import CoreServices
#endif
#endif
#endif

extension EnvironmentValues {
    /// An action that opens a URL.
    ///
    /// Read this environment value to get an ``OpenURLAction``
    /// instance for a given ``Environment``. Call the
    /// instance to open a URL. You call the instance directly because it
    /// defines a ``OpenURLAction/callAsFunction(_:)`` method that Swift
    /// calls when you call the instance.
    ///
    /// For example, you can open a web site when the user taps a button:
    ///
    ///     struct OpenURLExample: View {
    ///         @Environment(\.openURL) private var openURL
    ///
    ///         var body: some View {
    ///             Button {
    ///                 if let url = URL(string: "https://www.example.com") {
    ///                     openURL(url)
    ///                 }
    ///             } label: {
    ///                 Label("Get Help", systemImage: "person.fill.questionmark")
    ///             }
    ///         }
    ///     }
    ///
    /// If you want to know whether the action succeeds, add a completion
    /// handler that takes a Boolean value. In this case, Swift implicitly
    /// calls the ``OpenURLAction/callAsFunction(_:completion:)`` method
    /// instead. That method calls your completion handler after it determines
    /// whether it can open the URL, but possibly before it finishes opening
    /// the URL. You can add a handler to the example above so that
    /// it prints the outcome to the console:
    ///
    ///     openURL(url) { accepted in
    ///         print(accepted ? "Success" : "Failure")
    ///     }
    ///
    /// The system provides a default open URL action with behavior
    /// that depends on the contents of the URL. For example, the default
    /// action opens a Universal Link in the associated app if possible,
    /// or in the user’s default web browser if not.
    ///
    /// You can also set a custom action using the ``View/environment(_:_:)``
    /// view modifier. Any views that read the action from the environment,
    /// including the built-in ``Link`` view and ``Text`` views with markdown
    /// links, or links in attributed strings, use your action. Initialize an
    /// action by calling the ``OpenURLAction/init(handler:)`` initializer with
    /// a handler that takes a URL and returns an ``OpenURLAction/Result``:
    ///
    ///     Text("Visit [Example Company](https://www.example.com) for details.")
    ///         .environment(\.openURL, OpenURLAction { url in
    ///             handleURL(url) // Define this method to take appropriate action.
    ///             return .handled
    ///         })
    ///
    /// OpenSwiftUI translates the value that your custom action's handler
    /// returns into an appropriate Boolean result for the action call.
    /// For example, a view that uses the action declared above
    /// receives `true` when calling the action, because the
    /// handler always returns ``OpenURLAction/Result/handled``.
    // MARK: - TODO
    public var openURL: OpenURLAction {
        get { _openURL }
        set { _openURL = newValue }
    }

    var _openURL: OpenURLAction {
        get { self[OpenURLActionKey.self] }
        set { self[OpenURLActionKey.self] = newValue }
    }
    // MARK: TODO -

    var _openSensitiveURL: OpenURLAction {
        get { self[OpenSensitiveURLActionKey.self] }
        set { self[OpenSensitiveURLActionKey.self] = newValue }
    }
}

struct OpenURLActionKey: EnvironmentKey {
    static let defaultValue = OpenURLAction(
        handler: .system { url, completion in
            #if os(iOS) || os(tvOS) || os(visionOS)
            UIApplication.shared.open(url, options: [:], completionHandler: completion)
            #elseif os(macOS)
            fatalError("Unimplemented")
            #else
            fatalError("Unimplemented")
            #endif
        },
        isDefault: false
    )
}

struct OpenSensitiveURLActionKey: EnvironmentKey {
    static let defaultValue = OpenURLAction(
        handler: .system { url, completion in
            #if DEBUG && os(iOS)
            let config = _LSOpenConfiguration()
            config.isSensitive = true
            let scene = UIApplication.shared.connectedScenes.first
            config.targetConnectionEndpoint = scene?._currentOpenApplicationEndpoint
            guard let workspace = LSApplicationWorkspace.default() else {
                return
            }
            workspace.open(url, configuration: config, completionHandler: completion)
            #else
            fatalError("Unimplemented")
            #endif
        },
        isDefault: false
    )
}

struct HostingViewOpenURLActionKey: EnvironmentKey {
    static let defaultValue = OpenURLAction(
        handler: .custom({ .systemAction($0)}, fallback: nil),
        isDefault: true
    )
}
