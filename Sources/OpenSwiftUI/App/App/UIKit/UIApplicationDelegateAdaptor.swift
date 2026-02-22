//
//  UIApplicationDelegateAdaptor.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)
public import UIKit
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if OPENSWIFTUI_OPENCOMBINE
public import OpenCombine
#else
public import Combine
#endif
public import OpenObservation

/// A property wrapper type that you use to create a UIKit app delegate.
///
/// To handle app delegate callbacks in an app that uses the
/// OpenSwiftUI life cycle, define a type that conforms to the
/// [UIApplicationDelegate](https://developer.apple.com/documentation/uikit/uiapplicationdelegate)
/// protocol, and implement the delegate methods that you need. For example,
/// you can implement the
/// [application(_:didRegisterForRemoteNotificationsWithDeviceToken:)](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622958-application)
/// method to handle remote notification registration:
///
///     class MyAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
///         func application(
///             _ application: UIApplication,
///             didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
///         ) {
///             // Record the device token.
///         }
///     }
///
/// Then use the `UIApplicationDelegateAdaptor` property wrapper inside your
/// ``App`` declaration to tell OpenSwiftUI about the delegate type:
///
///     @main
///     struct MyApp: App {
///         @UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
///
///         var body: some Scene { ... }
///     }
///
/// OpenSwiftUI instantiates the delegate and calls the delegate's
/// methods in response to life cycle events. Define the delegate adaptor
/// only in your ``App`` declaration, and only once for a given app. If
/// you declare it more than once, OpenSwiftUI generates a runtime error.
///
/// If your app delegate conforms to the
/// [ObservableObject](https://swiftpackageindex.com/openswiftuiproject/opencombine/main/documentation/opencombine/observableobject)
/// protocol, as in the example above, then OpenSwiftUI puts the delegate it
/// creates into the ``Environment``. You can access the delegate from
/// any scene or view in your app using the ``EnvironmentObject`` property
/// wrapper:
///
///     @EnvironmentObject private var appDelegate: MyAppDelegate
///
/// This enables you to use the dollar sign (`$`) prefix to get a binding to
/// published properties that you declare in the delegate. For more information,
/// see ``projectedValue``.
///
/// > Important: Manage an app's life cycle events without using an app
/// delegate whenever possible. For example, prefer to handle changes
/// in ``ScenePhase`` instead of relying on delegate callbacks, like
/// [application(_:didFinishLaunchingWithOptions:)](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622921-application).
///
/// ### Scene delegates
///
/// Some iOS apps define a
/// [UIWindowSceneDelegate](https://developer.apple.com/documentation/uikit/uiwindowscenedelegate)
/// to handle scene-based events, like app shortcuts:
///
///     class MySceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
///         func windowScene(
///             _ windowScene: UIWindowScene,
///             performActionFor shortcutItem: UIApplicationShortcutItem
///         ) async -> Bool {
///             // Do something with the shortcut...
///
///             return true
///         }
///     }
///
/// You can provide this kind of delegate to a SwiftUI app by returning the
/// scene delegate's type from the
/// [application(_:configurationForConnecting:options:)](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/3197905-application)
/// method inside your app delegate:
///
///     extension MyAppDelegate {
///         func application(
///             _ application: UIApplication,
///             configurationForConnecting connectingSceneSession: UISceneSession,
///             options: UIScene.ConnectionOptions
///         ) -> UISceneConfiguration {
///
///             let configuration = UISceneConfiguration(
///                                     name: nil,
///                                     sessionRole: connectingSceneSession.role)
///             if connectingSceneSession.role == .windowApplication {
///                 configuration.delegateClass = MySceneDelegate.self
///             }
///             return configuration
///         }
///     }
///
/// When you configure the
/// [UISceneConfiguration](https://developer.apple.com/documentation/uikit/uisceneconfiguration)
/// instance, you only need to indicate the delegate class, and not a scene
/// class or storyboard. OpenSwiftUI creates and manages the delegate instance,
/// and sends it any relevant delegate callbacks.
///
/// As with the app delegate, if you make your scene delegate an observable
/// object, OpenSwiftUI automatically puts it in the ``Environment``, from where
/// you can access it with the ``EnvironmentObject`` property wrapper, and
/// create bindings to its published properties.
@available(OpenSwiftUI_v2_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@MainActor
@preconcurrency
@propertyWrapper
public struct UIApplicationDelegateAdaptor<DelegateType>: DynamicProperty where DelegateType: NSObject, DelegateType: UIApplicationDelegate {

    /// The underlying app delegate.
    public var wrappedValue: DelegateType {
        if AppGraph.delegateBox == nil {
            Log.runtimeIssues(
                "UIApplicationDelegateAdaptor was used outside of an App or Scene; this will not instantiate the delegate."
            )
        }
        return AppGraph.delegateBox!.delegate! as! DelegateType
    }

    /// Creates a UIKit app delegate adaptor.
    ///
    /// Call this initializer indirectly by creating a property with the
    /// ``UIApplicationDelegateAdaptor`` property wrapper from inside your
    /// ``App`` declaration:
    ///
    ///     @main
    ///     struct MyApp: App {
    ///         @UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
    ///
    ///         var body: some Scene { ... }
    ///     }
    ///
    /// OpenSwiftUI initializes the delegate and manages its lifetime, calling upon
    /// it to handle application delegate callbacks.
    ///
    /// If you want OpenSwiftUI to put the instantiated delegate in the
    /// ``Environment``, make sure the delegate class also conforms to the
    /// [ObservableObject](https://swiftpackageindex.com/openswiftuiproject/opencombine/main/documentation/opencombine/observableobject)
    /// protocol. That causes OpenSwiftUI to invoke the ``init(_:)-8bybh``
    /// initializer rather than this one.
    ///
    /// - Parameter delegateType: The type of application delegate that you
    ///   define in your app, which conforms to the
    ///   [UIApplicationDelegate](https://developer.apple.com/documentation/uikit/uiapplicationdelegate)
    ///   protocol.
    public init(_ delegateType: DelegateType.Type = DelegateType.self) {
        let box = FallbackDelegateBox<DelegateType>(nil)
        AppGraph.delegateBox = box
    }

    nonisolated public static func _makeProperty<Value>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<Value>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        guard GraphHost.currentHost is AppGraph else {
            Log.externalWarning(
                "UIApplicationDelegateAdaptor was used outside of an App or Scene; this will not instantiate the delegate."
            )
            return
        }
    }
}

@available(OpenSwiftUI_v2_0, *)
extension UIApplicationDelegateAdaptor where DelegateType: ObservableObject {

    /// Creates a UIKit app delegate adaptor using a delegate that's
    /// an observable object.
    ///
    /// Call this initializer indirectly by creating a property with the
    /// ``UIApplicationDelegateAdaptor`` property wrapper from inside your
    /// ``App`` declaration:
    ///
    ///     @main
    ///     struct MyApp: App {
    ///         @UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
    ///
    ///         var body: some Scene { ... }
    ///     }
    ///
    /// OpenSwiftUI initializes the delegate and manages its lifetime, calling it
    /// as needed to handle application delegate callbacks.
    ///
    /// OpenSwiftUI invokes this method when your app delegate conforms to the
    /// [ObservableObject](https://swiftpackageindex.com/openswiftuiproject/opencombine/main/documentation/opencombine/observableobject)
    /// protocol. In this case, OpenSwiftUI automatically places the delegate in the
    /// ``Environment``. You can access such a delegate from any scene or
    /// view in your app using the ``EnvironmentObject`` property wrapper:
    ///
    ///     @EnvironmentObject private var appDelegate: MyAppDelegate
    ///
    /// If your delegate isn't an observable object, OpenSwiftUI invokes the
    /// ``init(_:)-9462f`` initializer rather than this one, and doesn't
    /// put the delegate instance in the environment.
    ///
    /// - Parameter delegateType: The type of application delegate that you
    ///   define in your app, which conforms to the
    ///   [UIApplicationDelegate](https://developer.apple.com/documentation/uikit/uiapplicationdelegate)
    ///   and
    ///   [ObservableObject](https://swiftpackageindex.com/openswiftuiproject/opencombine/main/documentation/opencombine/observableobject)
    ///   protocols.
    ///
    public init(_ delegateType: DelegateType.Type = DelegateType.self) {
        let box = ObservableObjectFallbackDelegateBox<DelegateType>()
        AppGraph.delegateBox = box
    }

    /// A projection of the observed object that provides bindings to its
    /// properties.
    ///
    /// Use the projected value to get a binding to a value that the delegate
    /// publishes. Access the projected value by prefixing the name of the
    /// delegate instance with a dollar sign (`$`). For example, you might
    /// publish a Boolean value in your application delegate:
    ///
    ///     class MyAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    ///         @Published var isEnabled = false
    ///
    ///         // ...
    ///     }
    ///
    /// If you declare the delegate in your ``App`` using the
    /// ``UIApplicationDelegateAdaptor`` property wrapper, you can get
    /// the delegate that SwiftUI instantiates from the environment and
    /// access a binding to its published values from any view in your app:
    ///
    ///     struct MyView: View {
    ///         @EnvironmentObject private var appDelegate: MyAppDelegate
    ///
    ///         var body: some View {
    ///             Toggle("Enabled", isOn: $appDelegate.isEnabled)
    ///         }
    ///     }
    ///
    public var projectedValue: ObservedObject<DelegateType>.Wrapper {
        if AppGraph.delegateBox == nil {
            Log.runtimeIssues(
                "UIApplicationDelegateAdaptor was used outside of an App or Scene; this will not instantiate the delegate."
            )
        }
        return ObservedObject<DelegateType>.Wrapper(root: wrappedValue)
    }
}

@available(OpenSwiftUI_v5_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension UIApplicationDelegateAdaptor where DelegateType: Observable {

    /// Creates a UIKit app delegate adaptor using an observable delegate.
    ///
    /// Call this initializer indirectly by creating a property with the
    /// ``UIApplicationDelegateAdaptor`` property wrapper from inside your
    /// ``App`` declaration:
    ///
    ///     @main
    ///     struct MyApp: App {
    ///         @UIApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
    ///
    ///         var body: some Scene { ... }
    ///     }
    ///
    /// OpenSwiftUI initializes the delegate and manages its lifetime, calling it
    /// as needed to handle application delegate callbacks.
    ///
    /// OpenSwiftUI invokes this method when your app delegate conforms to the
    /// [Observable](https://swiftpackageindex.com/openswiftuiproject/openobservation/main/documentation/openobservation/observable)
    /// protocol. In this case, OpenSwiftUI automatically places the delegate in the
    /// ``Environment``. You can access such a delegate from any scene or
    /// view in your app using the ``Environment`` property wrapper:
    ///
    ///     @Environment(MyAppDelegate.self) private var appDelegate
    ///
    /// If your delegate isn't observable, SwiftUI invokes the
    /// ``init(_:)-9462f`` initializer rather than this one, and doesn't
    /// put the delegate instance in the environment.
    ///
    /// - Parameter delegateType: The type of application delegate that you
    ///   define in your app, which conforms to the
    ///   [UIApplicationDelegate](https://developer.apple.com/documentation/uikit/uiapplicationdelegate)
    ///   and
    ///   [Observable](https://swiftpackageindex.com/openswiftuiproject/openobservation/main/documentation/openobservation/observable)
    ///   protocols.
    public init(_ delegateType: DelegateType.Type = DelegateType.self) {
        let box = ObservableFallbackDelegateBox<DelegateType>()
        AppGraph.delegateBox = box
    }
}

@available(OpenSwiftUI_v2_0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension UIApplicationDelegateAdaptor: Sendable {}
#endif
