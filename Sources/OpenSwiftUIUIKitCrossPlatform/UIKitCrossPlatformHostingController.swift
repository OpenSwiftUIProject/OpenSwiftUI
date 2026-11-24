#if UIKIT_CROSS_PLATFORM
public import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly) public import OpenSwiftUICore
public import UIKit

/// Hosts an OpenSwiftUI view in a UIKit-cross-platform application.
/// The application owns the SDL event loop and window lifecycle.
@MainActor
public final class UIKitCrossPlatformHostingController<Content: View>: UIViewController {
    private let rootView: Content
    private let baseEnvironment: EnvironmentValues
    private let defaultBackgroundColor: UIColor

    public init(rootView: Content, environment: EnvironmentValues = EnvironmentValues()) {
        self.rootView = rootView
        self.baseEnvironment = environment
        self.defaultBackgroundColor = .black
        super.init(nibName: nil, bundle: nil)
    }

    public init<Application: App>(app: Application.Type) where Content == AnyView {
        Update.locked {
            PlatformTextSystems.current = UIKitCrossPlatformTextSystem()
        }
        let scene = AppGraph.makeCrossPlatformRootScene(for: app)
        self.rootView = scene.view
        self.baseEnvironment = scene.environment
        self.defaultBackgroundColor = scene.environment.colorScheme == .dark ? .black : .white
        super.init(nibName: nil, bundle: nil)
    }

    public override func loadView() {
        Update.locked {
            PlatformTextSystems.current = UIKitCrossPlatformTextSystem()
        }
        view = UIKitCrossPlatformHostingView(
            rootView: rootView,
            baseEnvironment: baseEnvironment,
            defaultBackgroundColor: defaultBackgroundColor
        )
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (view as? UIKitCrossPlatformHostingView<Content>)?.startRendering()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        (view as? UIKitCrossPlatformHostingView<Content>)?.stopRendering()
    }
}
#endif
