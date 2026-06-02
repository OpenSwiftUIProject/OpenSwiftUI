#if os(Android) && OPENSWIFTUI_ANDROID_UIKIT
import Android
import UIKit
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore
import OpenQuartzCoreShims

@_cdecl("OpenSwiftUIAndroidDemoConfigureUIKit")
public func OpenSwiftUIAndroidDemoConfigureUIKit() {
    MainActor.assumeIsolated {
        UIKitAndroid.UIApplicationDelegateClass = AndroidOpenSwiftUIAppDelegate.self
    }
}

@MainActor
struct AndroidUIKitDemoRunner {
    func run() -> Int32 {
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

    static func makeRootView(size: UIKit.CGSize) -> UIView {
        let root = AndroidUIViewPlatformViewDefinition.makeView(kind: .inherited) as! UIView
        root.frame = UIKit.CGRect(origin: .zero, size: size)
        root.backgroundColor = .clear
        return root
    }

    static func installDemo(in rootView: UIView, size: UIKit.CGSize) {
        rootView.subviews.forEach { $0.removeFromSuperview() }
        rootView.frame = UIKit.CGRect(origin: .zero, size: size)

        let topHeight = (size.height - 10.0) / 2.0
        let bottomY = topHeight + 10.0

        addColorView(
            to: rootView,
            frame: UIKit.CGRect(x: 0.0, y: 0.0, width: size.width, height: topHeight),
            color: UIColor(red: 255.0 / 255.0, green: 59.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
        )
        addColorView(
            to: rootView,
            frame: UIKit.CGRect(x: 0.0, y: bottomY, width: size.width, height: topHeight),
            color: UIColor(red: 0.0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        )

        if isPrintTreeEnabled() {
            print("View \(Unmanaged.passUnretained(rootView).toOpaque()) at Time(seconds: 0.0):\n\(displayListDescription(size: size, topHeight: topHeight, bottomY: bottomY))")
        }
    }

    private static func addColorView(to rootView: UIView, frame: UIKit.CGRect, color: UIColor) {
        let colorView = AndroidUIViewPlatformViewDefinition.makeView(kind: .color) as! UIView
        colorView.frame = frame
        colorView.backgroundColor = color
        rootView.addSubview(colorView)
    }

    private static func displayListDescription(size: UIKit.CGSize, topHeight: UIKit.CGFloat, bottomY: UIKit.CGFloat) -> String {
        """
        (display-list
          (item #:identity 1 #:version 7
            (frame (0.0 0.0; \(format(size.width)) \(format(topHeight))))
            (content-seed 5)
            (color #FF3B30FF))
          (item #:identity 2 #:version 8
            (frame (0.0 \(format(bottomY)); \(format(size.width)) \(format(topHeight))))
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
