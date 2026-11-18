#if UIKIT_CROSS_PLATFORM
public import OpenSwiftUICore
public import UIKit

/// Hosts an OpenSwiftUI view in a UIKit-cross-platform application.
/// The application owns the SDL event loop and window lifecycle.
@MainActor
public final class UIKitCrossPlatformHostingController<Content: View>: UIViewController {
    private let rootView: Content

    public init(rootView: Content) {
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }

    public override func loadView() {
        Update.locked {
            PlatformTextSystems.current = UIKitCrossPlatformTextSystem()
        }
        view = UIKitCrossPlatformHostingView(rootView: rootView)
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
