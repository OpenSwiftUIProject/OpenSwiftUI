#if os(Android) && OPENSWIFTUI_ANDROID_UIKIT
import Android
import Foundation
import JNI
import UIKit
import OpenSwiftUIDemoContent
public import OpenSwiftUICore

nonisolated(unsafe) private var didConfigureNativeLoaders = false
@MainActor private var makeRootViewController: () -> UIViewController = {
    AndroidOpenSwiftUIViewController(rootView: ContentView())
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
        makeRootViewController = { AndroidOpenSwiftUIViewController(rootView: rootView) }
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
        PlatformTextSystems.current = AndroidTextSystem()
        let window = UIWindow()
        window.rootViewController = makeRootViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

@MainActor
private final class AndroidOpenSwiftUIViewController<Content: View>: UIViewController {
    private let rootView: Content

    init(rootView: Content) {
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        view = AndroidHostingView(rootView: rootView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (view as? AndroidHostingView<Content>)?.startRendering()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        (view as? AndroidHostingView<Content>)?.stopRendering()
    }
}
#endif
