//
//  App.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 20E520D074F8AF54E6253E3E22B86490 (SwiftUI)

import OpenSwiftUICore

// MARK: - App

/// A type that represents the structure and behavior of an app.
///
/// Create an app by declaring a structure that conforms to the `App` protocol.
/// Implement the required ``OpenSwiftUI/App/body-swift.property`` computed property
/// to define the app's content:
///
///     @main
///     struct MyApp: App {
///         var body: some Scene {
///             WindowGroup {
///                 Text("Hello, world!")
///             }
///         }
///     }
///
/// Precede the structure's declaration with the
/// [@main](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html#ID626)
/// attribute to indicate that your custom `App` protocol conformer provides the
/// entry point into your app. The protocol provides a default implementation of
/// the ``OpenSwiftUI/App/main()`` method that the system calls to launch your app.
/// You can have exactly one entry point among all of your app's files.
///
/// Compose the app's body from instances that conform to the ``OpenSwiftUI/Scene``
/// protocol. Each scene contains the root view of a view hierarchy and has a
/// life cycle managed by the system. OpenSwiftUI provides some concrete scene types
/// to handle common scenarios, like for displaying documents or settings. You
/// can also create custom scenes.
///
///     @main
///     struct Mail: App {
///         var body: some Scene {
///             WindowGroup {
///                 MailViewer()
///             }
///             Settings {
///                 SettingsView()
///             }
///         }
///     }
///
/// You can declare state in your app to share across all of its scenes. For
/// example, you can use the ``OpenSwiftUI/StateObject`` attribute to initialize a
/// data model, and then provide that model on a view input as an
/// ``OpenSwiftUI/ObservedObject`` or through the environment as an
/// ``OpenSwiftUI/EnvironmentObject`` to scenes in the app:
///
///     @main
///     struct Mail: App {
///         @StateObject private var model = MailModel()
///
///         var body: some Scene {
///             WindowGroup {
///                 MailViewer()
///                     .environmentObject(model) // Passed through the environment.
///             }
///             Settings {
///                 SettingsView(model: model) // Passed as an observed object.
///             }
///         }
///     }
///
/// A type conforming to this protocol inherits `@preconcurrency @MainActor`
/// isolation from the protocol if the conformance is included in the type's
/// base declaration:
///
///     struct MyCustomType: Transition {
///         // `@preconcurrency @MainActor` isolation by default
///     }
///
/// Isolation to the main actor is the default, but it's not required. Declare
/// the conformance in an extension to opt out of main actor isolation:
///
///     extension MyCustomType: Transition {
///         // `nonisolated` by default
///     }
///
@available(OpenSwiftUI_v2_0, *)
@MainActor
@preconcurrency
public protocol App {

    /// The type of scene representing the content of the app.
    ///
    /// When you create a custom app, Swift infers this type from your
    /// implementation of the required ``OpenSwiftUI/App/body-swift.property``
    /// property.
    associatedtype Body: Scene

    /// The content and behavior of the app.
    ///
    /// For any app that you create, provide a computed `body` property that
    /// defines your app's scenes, which are instances that conform to the
    /// ``OpenSwiftUI/Scene`` protocol. For example, you can create a simple app
    /// with a single scene containing a single view:
    ///
    ///     @main
    ///     struct MyApp: App {
    ///         var body: some Scene {
    ///             WindowGroup {
    ///                 Text("Hello, world!")
    ///             }
    ///         }
    ///     }
    ///
    /// Swift infers the app's ``OpenSwiftUI/App/Body-swift.associatedtype``
    /// associated type based on the scene provided by the `body` property.
    @SceneBuilder
    var body: Body { get }

    /// Creates an instance of the app using the body that you define for its
    /// content.
    ///
    /// Swift synthesizes a default initializer for structures that don't
    /// provide one. You typically rely on the default initializer for
    /// your app.
    init()
}

extension App {

    /// Initializes and runs the app.
    ///
    /// If you precede your ``OpenSwiftUI/App`` conformer's declaration with the
    /// [@main](https://docs.swift.org/swift-book/ReferenceManual/Attributes.html#ID626)
    /// attribute, the system calls the conformer's `main()` method to launch
    /// the app. OpenSwiftUI provides a
    /// default implementation of the method that manages the launch process in
    /// a platform-appropriate way.
    public static func main() {
        let app = Self()
        runApp(app)
    }
}

// MARK: - AppRootModifier

private var appRootViewWrappers: [(AnyView) -> AnyView] = []

@_spi(Private)
public func registerAppRootModifier<M>(_ modifier: M) where M: ViewModifier {
    appRootViewWrappers.append({ AnyView($0.modifier(modifier)) })
}

func applyAppRootModifier(_ view: AnyView) -> AnyView {
    var result = view
    for modifier in appRootViewWrappers {
        result = modifier(result)
    }
    return result
}

// MARK: - Platform implementation

#if os(iOS) || os(visionOS)
import UIKit
typealias DelegateBaseClass = UIResponder
typealias PlatformApplication = UIApplication
typealias PlatformApplicationDelegate = UIApplicationDelegate
#elseif os(macOS)
import AppKit
typealias DelegateBaseClass = NSResponder
typealias PlatformApplication = NSApplication
typealias PlatformApplicationDelegate = NSApplicationDelegate
#else
import Foundation
// FIXME: Temporarily use NSObject as a placeholder
typealias DelegateBaseClass = NSObject
typealias PlatformApplication = NSObject
typealias PlatformApplicationDelegate = AnyObject

func runApp(_ app: some App) -> Never {
    _openSwiftUIPlatformUnimplementedFailure()
}

func runTestingApp<V1, V2>(rootView: V1, comparisonView: V2, didLaunch: @escaping (any TestHost, any TestHost) -> ()) -> Never where V1: View, V2: View {
    _openSwiftUIPlatformUnimplementedFailure()
}
#endif
