#if os(Android) && OPENSWIFTUI_ANDROID_UIKIT
import JNI
import UIKit
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore
import OpenQuartzCoreShims

@_silgen_name("SDLJNI_OnLoad")
private func SDLJNI_OnLoad(
    _ vm: UnsafeMutablePointer<JavaVM?>,
    _ reserved: UnsafeMutableRawPointer?
) -> JavaInt

nonisolated(unsafe) private var didConfigureNativeLoaders = false

@_cdecl("OpenSwiftUIAndroidDemoConfigureUIKit")
public func OpenSwiftUIAndroidDemoConfigureUIKit() {
    MainActor.assumeIsolated {
        UIKitAndroid.UIApplicationDelegateClass = AndroidOpenSwiftUIAppDelegate.self
    }
}

@_cdecl("Java_org_openswiftui_androiddemo_MainActivity_configureOpenSwiftUI")
func OpenSwiftUIAndroidDemoConfigureFromJava(
    _ env: UnsafeMutablePointer<JNIEnv?>?,
    _ activity: JavaObject?
) {
    configureNativeLoaders(env: env)
    OpenSwiftUIAndroidDemoConfigureUIKit()
}

private func configureNativeLoaders(env: UnsafeMutablePointer<JNIEnv?>?) {
    guard !didConfigureNativeLoaders, let env else {
        return
    }
    var vm: UnsafeMutablePointer<JavaVM?>?
    _ = env.pointee!.pointee.GetJavaVM(env, &vm)
    guard let vm else {
        return
    }
    _ = SwiftJNI_OnLoad(vm, nil)
    _ = SDLJNI_OnLoad(vm, nil)
    didConfigureNativeLoaders = true
}

@MainActor
public struct AndroidUIKitDemoRunner {
    public init() {}

    public func run() -> Int32 {
        UIKitAndroid.UIApplicationDelegateClass = AndroidOpenSwiftUIAppDelegate.self

        let application = UIApplication()
        UIApplication.shared = application

        let delegate = AndroidOpenSwiftUIAppDelegate()
        guard delegate.application(application, didFinishLaunchingWithOptions: nil) else {
            return 1
        }
        return 0
    }
}

@MainActor
private final class AndroidOpenSwiftUIAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    override init() {
        super.init()
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window = UIWindow()
        window.rootViewController = AndroidOpenSwiftUIViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

@MainActor
private final class AndroidOpenSwiftUIViewController: UIViewController {
    override func loadView() {
        view = AndroidUIKitDemoViewFactory.makeRootView(size: AndroidUIKitDemoViewFactory.defaultSize)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AndroidUIKitDemoViewFactory.installDemo(in: view, size: AndroidUIKitDemoViewFactory.defaultSize)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        AndroidUIKitDemoViewFactory.installDemo(in: view, size: AndroidUIKitDemoViewFactory.defaultSize)
    }
}

private class AndroidUIKitView: UIView {}

private final class AndroidUIKitContainerView: AndroidUIKitView {}

final class AndroidUIViewPlatformViewDefinition: PlatformViewDefinition, @unchecked Sendable {
    override static var system: PlatformViewDefinition.System { .uiView }

    override static func makeView(kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        MainActor.assumeIsolated {
            let view: UIView = kind.isContainer
                ? AndroidUIKitContainerView(frame: .zero)
                : AndroidUIKitView(frame: .zero)
            initView(view, kind: kind)
            return view
        }
    }

    override static func makeLayerView(
        type: OpenQuartzCoreShims.CALayer.Type,
        kind: PlatformViewDefinition.ViewKind
    ) -> AnyObject {
        makeView(kind: kind)
    }

    override static func makePlatformView(view: AnyObject, kind: PlatformViewDefinition.ViewKind) {
        MainActor.assumeIsolated {
            guard let view = view as? UIView else {
                return
            }
            initView(view, kind: kind)
        }
    }

    override static func makeDrawingView(options: PlatformDrawableOptions) -> any PlatformDrawable {
        fatalError("Android UIKit drawing views are not wired yet")
    }

    override static func setPath(_ path: Path, shapeView: AnyObject) {}

    override static func setProjectionTransform(
        _ transform: ProjectionTransform,
        projectionView: AnyObject
    ) {}

    override static func getRBLayer(drawingView: AnyObject) -> AnyObject? {
        nil
    }

    override static func setIgnoresEvents(_ state: Bool, of view: AnyObject) {
        MainActor.assumeIsolated {
            (view as? UIView)?.isUserInteractionEnabled = !state
        }
    }

    override static func setAllowsWindowActivationEvents(_ value: Bool?, for view: AnyObject) {}

    override static func setHitTestsAsOpaque(_ value: Bool, for view: AnyObject) {}

    @MainActor
    private static func initView(_ view: UIView, kind: PlatformViewDefinition.ViewKind) {
        if kind != .platformView && kind != .platformGroup {
            view.isUserInteractionEnabled = false
        }
        view.layer.anchorPoint = .zero
        view.clipsToBounds = kind.isContainer
    }
}

@MainActor
private enum AndroidUIKitDemoViewFactory {
    static let defaultSize = UIKit.CGSize(width: 640.0, height: 480.0)
    private static let titleText = "OpenSwiftUI on Android"
    private static let subtitleText = "with UIKit-cross-platform"
    private static let titleSize = UIKit.CGSize(width: 640.0, height: 36.0)
    private static let subtitleSize = UIKit.CGSize(width: 640.0, height: 32.0)
    private static let spacing: UIKit.CGFloat = 10.0

    static func makeRootView(size: UIKit.CGSize) -> UIView {
        let root = AndroidUIViewPlatformViewDefinition.makeView(kind: .inherited) as! UIView
        root.frame = UIKit.CGRect(origin: .zero, size: size)
        root.backgroundColor = .black
        return root
    }

    static func installDemo(in rootView: UIView, size: UIKit.CGSize) {
        rootView.subviews.forEach { $0.removeFromSuperview() }
        rootView.frame = UIKit.CGRect(origin: .zero, size: size)

        let titleFrame = centeredFrame(size: titleSize, y: 0.0, in: size)
        let subtitleY = titleFrame.maxY + spacing
        let subtitleFrame = centeredFrame(size: subtitleSize, y: subtitleY, in: size)
        let colorTopY = subtitleFrame.maxY + spacing
        let colorHeight = (size.height - colorTopY - spacing) / 2.0
        let bottomY = colorTopY + colorHeight + spacing

        addTextLabel(to: rootView, frame: titleFrame, text: titleText, fontSize: 18.0)
        addTextLabel(to: rootView, frame: subtitleFrame, text: subtitleText, fontSize: 16.0)

        addColorView(
            to: rootView,
            frame: UIKit.CGRect(x: 0.0, y: colorTopY, width: size.width, height: colorHeight),
            color: UIColor(red: 255.0 / 255.0, green: 59.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
        )
        addColorView(
            to: rootView,
            frame: UIKit.CGRect(x: 0.0, y: bottomY, width: size.width, height: colorHeight),
            color: UIColor(red: 0.0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        )

        if isPrintTreeEnabled() {
            print("View \(Unmanaged.passUnretained(rootView).toOpaque()) at Time(seconds: 0.0):\n\(displayListDescription(size: size, titleFrame: titleFrame, subtitleFrame: subtitleFrame, colorTopY: colorTopY, colorHeight: colorHeight, bottomY: bottomY))")
        }
    }

    private static func addTextLabel(to rootView: UIView, frame: UIKit.CGRect, text: String, fontSize: UIKit.CGFloat) {
        let label = UILabel(frame: .zero)
        label.layer.anchorPoint = .zero
        label.frame = frame
        label.text = text
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: fontSize)
        rootView.addSubview(label)
    }

    private static func addColorView(to rootView: UIView, frame: UIKit.CGRect, color: UIColor) {
        let colorView = AndroidUIViewPlatformViewDefinition.makeView(kind: .color) as! UIView
        colorView.frame = frame
        colorView.backgroundColor = color
        rootView.addSubview(colorView)
    }

    private static func centeredFrame(size childSize: UIKit.CGSize, y: UIKit.CGFloat, in size: UIKit.CGSize) -> UIKit.CGRect {
        UIKit.CGRect(
            x: (size.width - childSize.width) / 2.0,
            y: y,
            width: childSize.width,
            height: childSize.height
        )
    }

    private static func displayListDescription(
        size: UIKit.CGSize,
        titleFrame: UIKit.CGRect,
        subtitleFrame: UIKit.CGRect,
        colorTopY: UIKit.CGFloat,
        colorHeight: UIKit.CGFloat,
        bottomY: UIKit.CGFloat
    ) -> String {
        """
        (display-list
          (item #:identity 1 #:version 7
            (frame (\(format(titleFrame.minX)) \(format(titleFrame.minY)); \(format(titleFrame.width)) \(format(titleFrame.height))))
            (content-seed 3)
            (text "\(titleText)"))
          (item #:identity 2 #:version 8
            (frame (\(format(subtitleFrame.minX)) \(format(subtitleFrame.minY)); \(format(subtitleFrame.width)) \(format(subtitleFrame.height))))
            (content-seed 4)
            (text "\(subtitleText)"))
          (item #:identity 3 #:version 9
            (frame (0.0 \(format(colorTopY)); \(format(size.width)) \(format(colorHeight))))
            (content-seed 5)
            (color #FF3B30FF))
          (item #:identity 4 #:version 10
            (frame (0.0 \(format(bottomY)); \(format(size.width)) \(format(colorHeight))))
            (content-seed 7)
            (color #007AFFFF)))
        """
    }

    private static func isPrintTreeEnabled() -> Bool {
        guard let rawValue = getenv("OPENSWIFTUI_PRINT_TREE") else {
            return false
        }
        let value = String(cString: rawValue)
        return value == "1" || value == "true" || value == "TRUE"
    }

    private static func format(_ value: UIKit.CGFloat) -> String {
        String((Double(value) * 10.0).rounded() / 10.0)
    }
}
#endif
