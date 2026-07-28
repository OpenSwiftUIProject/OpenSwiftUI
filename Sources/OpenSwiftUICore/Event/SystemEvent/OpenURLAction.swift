//
//  OpenURLAction.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B30D3CE6A753616B2150C4E3EFDA1ED9 (SwiftUICore)

public import Foundation

/// An action that opens a URL.
///
/// Read the ``EnvironmentValues/openURL`` environment value to get an
/// instance of this structure for a given ``Environment``. Call the
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
@available(OpenSwiftUI_v2_0, *)
@preconcurrency
@MainActor
public struct OpenURLAction {
    package typealias SystemHandler = (URL, @escaping (Bool) -> Void) -> Void

    package typealias UserConfiguredHandler = (URL) -> OpenURLAction.Result

    package enum Handler {
        case system(SystemHandler)
        case custom(UserConfiguredHandler, fallback: SystemHandler? = nil)
    }

    /// The result of a custom open URL action.
    ///
    /// If you declare a custom ``OpenURLAction`` in the ``Environment``,
    /// return one of the result values from its handler.
    ///
    /// * Use ``handled`` to indicate that the handler opened the URL.
    /// * Use ``discarded`` to indicate that the handler discarded the URL.
    /// * Use ``systemAction`` without an argument to ask OpenSwiftUI
    ///   to open the URL with the system handler.
    /// * Use ``systemAction(_:)`` with a URL argument to ask OpenSwiftUI
    ///   to open the specified URL with the system handler.
    ///
    /// You can use the last option to transform URLs, while
    /// still relying on the system to open the URL. For example,
    /// you could append a path component to every URL:
    ///
    ///     .environment(\.openURL, OpenURLAction { url in
    ///         .systemAction(url.appendingPathComponent("edit"))
    ///     })
    ///
    @available(OpenSwiftUI_v3_0, *)
    public struct Result: Sendable {
        /// The handler opened the URL.
        ///
        /// The action invokes its completion handler with `true` when your
        /// handler returns this value.
        public static let handled = Result(actionResult: .handled)

        /// The handler discarded the URL.
        ///
        /// The action invokes its completion handler with `false` when your
        /// handler returns this value.
        public static let discarded = Result(actionResult: .discarded)

        /// The handler asks the system to open the original URL.
        ///
        /// The action invokes its completion handler with a value that
        /// depends on the outcome of the system's attempt to open the URL.
        public static let systemAction = Result(actionResult: .systemAction(url: nil))

        /// The handler asks the system to open the modified URL.
        ///
        /// The action invokes its completion handler with a value that
        /// depends on the outcome of the system's attempt to open the URL.
        ///
        /// - Parameter url: The URL that the handler asks the system to open.
        public static func systemAction(_ url: URL) -> Result {
            Result(actionResult: .systemAction(url: url))
        }

        enum ActionResult {
            case systemAction(url: URL?)
            case handled
            case discarded
        }

        var actionResult: ActionResult
    }

    let handler: Handler

    let isDefault: Bool

    /// Creates an action that opens a URL.
    ///
    /// Use this initializer to create a custom action for opening URLs.
    /// Provide a handler that takes a URL and returns an
    /// ``OpenURLAction/Result``. Place your handler in the environment
    /// using the ``View/environment(_:_:)`` view modifier:
    ///
    ///     Text("Visit [Example Company](https://www.example.com) for details.")
    ///         .environment(\.openURL, OpenURLAction { url in
    ///             handleURL(url) // Define this method to take appropriate action.
    ///             return .handled
    ///         })
    ///
    /// Any views that read the action from the environment, including the
    /// built-in ``Link`` view and ``Text`` views with markdown links, or
    /// links in attributed strings, use your action.
    ///
    /// OpenSwiftUI translates the value that your custom action's handler
    /// returns into an appropriate Boolean result for the action call.
    /// For example, a view that uses the action declared above
    /// receives `true` when calling the action, because the
    /// handler always returns ``OpenURLAction/Result/handled``.
    ///
    /// - Parameter handler: The closure to run for the given URL.
    ///   The closure takes a URL as input, and returns a ``Result``
    ///   that indicates the outcome of the action.
    @available(OpenSwiftUI_v3_0, *)
    public init(
        handler: @escaping (URL) -> OpenURLAction.Result
    ) {
        self.handler = .custom(handler)
        isDefault = false
    }

    package init(handler: Handler) {
        self.handler = handler
        isDefault = false
    }

    package init(
        isDefault: Bool = false,
        handler: @escaping (URL, @escaping (Bool) -> Void) -> Void
    ) {
        self.handler = .system(handler)
        self.isDefault = isDefault
    }

    @_spi(Private)
    public init(
        _handler handler: @escaping (URL, @escaping (Bool) -> Void) -> Void
    ) {
        self.handler = .system(handler)
        isDefault = false
    }

    /// Opens a URL, following system conventions.
    ///
    /// Don't call this method directly. OpenSwiftUI calls it when you
    /// call the ``OpenURLAction`` structure that you get from the
    /// ``Environment``, using a URL as an argument:
    ///
    ///     struct OpenURLExample: View {
    ///         @Environment(\.openURL) private var openURL
    ///
    ///         var body: some View {
    ///             Button {
    ///                 if let url = URL(string: "https://www.example.com") {
    ///                     openURL(url) // Implicitly calls openURL.callAsFunction(url)
    ///                 }
    ///             } label: {
    ///                 Label("Get Help", systemImage: "person.fill.questionmark")
    ///             }
    ///         }
    ///     }
    ///
    /// For information about how Swift uses the `callAsFunction()` method to
    /// simplify call site syntax, see
    /// [Methods with Special Names](https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID622)
    /// in *The Swift Programming Language*.
    ///
    /// - Parameter url: The URL to open.
    public func callAsFunction(_ url: URL) {
        _open(url) { _ in }
    }

    /// Asynchronously opens a URL, following system conventions.
    ///
    /// Don't call this method directly. OpenSwiftUI calls it when you
    /// call the ``OpenURLAction`` structure that you get from the
    /// ``Environment``, using a URL and a completion handler as arguments:
    ///
    ///     struct OpenURLExample: View {
    ///         @Environment(\.openURL) private var openURL
    ///
    ///         var body: some View {
    ///             Button {
    ///                 if let url = URL(string: "https://www.example.com") {
    ///                     // Implicitly calls openURL.callAsFunction(url) { ... }
    ///                     openURL(url) { accepted in
    ///                         print(accepted ? "Success" : "Failure")
    ///                     }
    ///                 }
    ///             } label: {
    ///                 Label("Get Help", systemImage: "person.fill.questionmark")
    ///             }
    ///         }
    ///     }
    ///
    /// For information about how Swift uses the `callAsFunction()` method to
    /// simplify call site syntax, see
    /// [Methods with Special Names](https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID622)
    /// in *The Swift Programming Language*.
    ///
    /// - Parameters:
    ///   - url: The URL to open.
    ///   - completion: A closure the method calls after determining if
    ///     it can open the URL, but possibly before fully opening the URL.
    ///     The closure takes a Boolean value that indicates whether the
    ///     method can open the URL.
    @available(watchOS, unavailable)
    public func callAsFunction(
        _ url: URL,
        completion: @escaping (_ accepted: Bool) -> Void
    ) {
        _open(url, completion: completion)
    }

    private func _open(
        _ url: URL,
        completion: @escaping (Bool) -> Void
    ) {
        switch handler {
        case let .system(systemHandler):
            if url.isFileURL {
                completion(false)
            } else {
                systemHandler(url, completion)
            }
        case let .custom(userConfiguredHandler, fallback):
            switch userConfiguredHandler(url).actionResult {
            case let .systemAction(urlOverride):
                guard let fallback else {
                    Log.internalWarning("OpenURLAction configured without a fallback")
                    return
                }
                fallback(urlOverride ?? url, completion)
            case .handled:
                completion(true)
            case .discarded:
                completion(false)
            }
        }
    }
}

extension OpenURLAction {
    package static var invalidAction: OpenURLAction {
        OpenURLAction(
            handler: .custom { _ in .discarded }
        )
    }
}

package struct OpenURLActionKey: EnvironmentKey {
    package static let defaultValue: OpenURLAction? = nil
}

private struct HasSystemOpenURLActionKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    package var hasSystemOpenURLAction: Bool {
        get { self[HasSystemOpenURLActionKey.self] }
        set { self[HasSystemOpenURLActionKey.self] = newValue }
    }
}

package struct OpenSensitiveURLActionKey: EnvironmentKey {
    package static let defaultValue: OpenURLAction? = nil
}

@available(OpenSwiftUI_v2_0, *)
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
    public var openURL: OpenURLAction {
        get { _openURL }
        @available(OpenSwiftUI_v3_0, *)
        set { _openURL = newValue }
    }

    public var _openURL: OpenURLAction {
        get {
            guard let action = self[OpenURLActionKey.self],
                  !action.isDefault
            else {
                return hasSystemOpenURLAction
                    ? CoreGlue.shared.defaultOpenURLAction(env: self)
                    : .invalidAction
            }
            switch action.handler {
            case .system:
                return action
            case let .custom(userConfiguredHandler, _):
                let fallback: OpenURLAction.SystemHandler?
                if hasSystemOpenURLAction {
                    switch CoreGlue.shared.defaultOpenURLAction(env: self).handler {
                    case let .system(systemHandler):
                        fallback = systemHandler
                    case let .custom(_, systemHandler):
                        fallback = systemHandler
                    }
                } else {
                    fallback = nil
                }
                return OpenURLAction(
                    handler: .custom(
                        userConfiguredHandler,
                        fallback: fallback
                    )
                )
            }
        }
        set { self[OpenURLActionKey.self] = newValue }
    }
}

@available(OpenSwiftUI_v2_0, *)
extension EnvironmentValues {
    public var _openSensitiveURL: OpenURLAction {
        get {
            guard let action = self[OpenSensitiveURLActionKey.self] else {
                return hasSystemOpenURLAction
                    ? CoreGlue.shared.defaultOpenSensitiveURLAction()
                    : .invalidAction
            }
            return action
        }
        set { self[OpenSensitiveURLActionKey.self] = newValue }
    }
}

@available(OpenSwiftUI_v2_0, *)
extension OpenURLAction: Sendable {}
