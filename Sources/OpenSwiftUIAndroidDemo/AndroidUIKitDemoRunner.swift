#if os(Android) && OPENSWIFTUI_ANDROID_UIKIT
import Bionic
import Foundation
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
        view = AndroidBreathingDemoRootView(frame: UIKit.CGRect(origin: .zero, size: AndroidBreathingDemoRootView.defaultSize))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (view as? AndroidBreathingDemoRootView)?.startAnimation()
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
private final class AndroidBreathingDemoRootView: UIView {
    static let defaultSize = UIKit.CGSize(width: 640.0, height: 480.0)
    private static let titleText = "Breathing Colors"
    private static let spacing: UIKit.CGFloat = 40.0
    private static let titleHeight: UIKit.CGFloat = 42.0
    private static let squareBaseSize: UIKit.CGFloat = 200.0
    private static let barSize = UIKit.CGSize(width: 200.0, height: 20.0)
    private static let barCornerRadius: UIKit.CGFloat = 10.0

    private let titleLabel = UILabel(frame: .zero)
    private let squareView = AndroidUIViewPlatformViewDefinition.makeView(kind: .color) as! UIView
    private let barView = AndroidUIViewPlatformViewDefinition.makeView(kind: .color) as! UIView
    private let displayLink = DisplayLink()

    override init(frame: UIKit.CGRect) {
        super.init(frame: frame)
        layer.anchorPoint = .zero
        backgroundColor = .black
        setupSubviews()
        layoutBreathingSubviews()
        updateAnimation()
    }

    deinit {
        displayLink.invalidate()
    }

    func startAnimation() {
        displayLink.callback = { [weak self] in
            MainActor.assumeIsolated {
                self?.updateAnimation()
            }
        }
        displayLink.isPaused = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutBreathingSubviews()
    }

    private func setupSubviews() {
        titleLabel.layer.anchorPoint = .zero
        titleLabel.text = Self.titleText
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 18.0)
        addSubview(titleLabel)

        squareView.backgroundColor = .blue
        addSubview(squareView)

        barView.backgroundColor = .blue
        barView.layer.cornerRadius = Self.barCornerRadius
        addSubview(barView)
    }

    private func layoutBreathingSubviews() {
        let size = bounds.size == .zero ? Self.defaultSize : bounds.size
        titleLabel.frame = UIKit.CGRect(
            x: 0.0,
            y: 0.0,
            width: size.width,
            height: Self.titleHeight
        )
        barView.frame = UIKit.CGRect(
            x: (size.width - Self.barSize.width) / 2.0,
            y: Self.titleHeight + Self.spacing + Self.squareBaseSize + Self.spacing,
            width: Self.barSize.width,
            height: Self.barSize.height
        )
        updateAnimation()
    }

    private func updateAnimation() {
        let time = Date().timeIntervalSince1970
        let breathe = (sin(time) + 1.0) / 2.0
        let opacity = UIKit.CGFloat(0.3 + breathe * 0.7)
        let scale = UIKit.CGFloat(0.8 + breathe * 0.4)
        let squareSize = Self.squareBaseSize * scale
        let size = bounds.size == .zero ? Self.defaultSize : bounds.size
        let squareCenterY = Self.titleHeight + Self.spacing + Self.squareBaseSize / 2.0

        squareView.frame = UIKit.CGRect(
            x: (size.width - squareSize) / 2.0,
            y: squareCenterY - squareSize / 2.0,
            width: squareSize,
            height: squareSize
        )
        squareView.alpha = opacity
        barView.alpha = opacity

        if Self.isPrintTreeEnabled() {
            print("View \(Unmanaged.passUnretained(self).toOpaque()) at Time(seconds: \(Self.format(time))):\n\(Self.displayListDescription(size: size, squareFrame: squareView.frame, barFrame: barView.frame, opacity: opacity))")
        }
    }

    private static func displayListDescription(
        size: UIKit.CGSize,
        squareFrame: UIKit.CGRect,
        barFrame: UIKit.CGRect,
        opacity: UIKit.CGFloat
    ) -> String {
        """
        (display-list
          (item #:identity 1 #:version 7
            (frame (0.0 0.0; \(format(size.width)) \(format(titleHeight))))
            (content-seed 3)
            (text "\(titleText)"))
          (item #:identity 2 #:version 8
            (frame (\(format(squareFrame.minX)) \(format(squareFrame.minY)); \(format(squareFrame.width)) \(format(squareFrame.height))))
            (content-seed 5)
            (opacity \(format(opacity)))
            (color #007AFFFF))
          (item #:identity 3 #:version 9
            (frame (\(format(barFrame.minX)) \(format(barFrame.minY)); \(format(barFrame.width)) \(format(barFrame.height))))
            (content-seed 7)
            (opacity \(format(opacity)))
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

    private static func format(_ value: Double) -> String {
        String((value * 10.0).rounded() / 10.0)
    }
}
#endif
