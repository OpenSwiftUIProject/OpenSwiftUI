#if os(Android) && UIKIT_CROSS_PLATFORM
import JNI
import UIKit
import OpenSwiftUIDemoContent
import OpenSwiftUIUIKitCrossPlatform
public import OpenSwiftUI
public import OpenSwiftUICore

nonisolated(unsafe) private var didConfigureNativeLoaders = false
@MainActor private var makeRootViewController: () -> UIViewController = {
    UIKitCrossPlatformHostingController(rootView: ContentView())
}

@_cdecl("OpenSwiftUIAndroidDemoConfigureUIKit")
public func OpenSwiftUIAndroidDemoConfigureUIKit() {
    MainActor.assumeIsolated {
        UIKitAndroid.UIApplicationDelegateClass = AndroidOpenSwiftUIAppDelegate.self
    }
}

@_cdecl("Java_org_openswiftui_androiddemo_MainActivity_configureOpenSwiftUI")
func OpenSwiftUIAndroidDemoConfigureFromJava(
    _ env: UnsafeMutablePointer<JNIEnv>?,
    _ activity: JavaObject?
) {
    configureNativeLoaders(env: env)
    OpenSwiftUIAndroidDemoConfigureUIKit()
}

private func configureNativeLoaders(env: UnsafeMutablePointer<JNIEnv>?) {
    guard !didConfigureNativeLoaders, let env else { return }
    var vm: UnsafeMutablePointer<JavaVM>?
    guard env.pointee.GetJavaVM(&vm) == JNI_OK, let vm else { return }
    _ = SwiftJNI_OnLoad(vm, nil)
    _ = SDLJNI_OnLoad(vm, nil)
    didConfigureNativeLoaders = true
}

@MainActor
public struct AndroidUIKitDemoRunner {
    public init() {}

    public static func configure<Content: View>(
        rootView: Content,
        javaEnvironment: UnsafeMutableRawPointer?
    ) {
        configureNativeLoaders(env: javaEnvironment?.assumingMemoryBound(to: JNIEnv.self))
        makeRootViewController = { UIKitCrossPlatformHostingController(rootView: rootView) }
        OpenSwiftUIAndroidDemoConfigureUIKit()
    }

    nonisolated public static func configure<Application: App>(
        app: Application.Type,
        javaEnvironment: UnsafeMutableRawPointer?
    ) {
        configureNativeLoaders(env: javaEnvironment?.assumingMemoryBound(to: JNIEnv.self))
        MainActor.assumeIsolated {
            makeRootViewController = { UIKitCrossPlatformHostingController(app: app) }
        }
        OpenSwiftUIAndroidDemoConfigureUIKit()
    }

    public func run() -> Int32 {
        UIKitAndroid.UIApplicationDelegateClass = AndroidOpenSwiftUIAppDelegate.self
        let application = UIApplication()
        UIApplication.shared = application
        let delegate = AndroidOpenSwiftUIAppDelegate()
        return delegate.application(application, didFinishLaunchingWithOptions: nil) ? 0 : 1
    }
}

@MainActor
private final class AndroidOpenSwiftUIAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow()
        window.rootViewController = makeRootViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
#endif
