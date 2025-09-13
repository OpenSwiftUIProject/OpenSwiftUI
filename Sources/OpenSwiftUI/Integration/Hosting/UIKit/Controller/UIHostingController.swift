#if os(iOS) || os(visionOS)
public import UIKit

@available(macOS, unavailable)
@available(watchOS, unavailable)
@MainActor
@preconcurrency
open class UIHostingController<Content>: UIViewController where Content : View {
    var host: _UIHostingView<Content>
    
    override open dynamic var keyCommands: [UIKeyCommand]? {
        // TODO
        nil
    }
    
    public init(rootView: Content) {
        // TODO
        host = _UIHostingView(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
        _commonInit()
    }
    
    public init?(coder: NSCoder, rootView: Content) {
        // TODO
        host = _UIHostingView(rootView: rootView)
        super.init(coder: coder)
        _commonInit()
    }
    
    public required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) must be implemented in a subclass and call super.init(coder:, rootView:)")
    }
    
    func _commonInit() {
        host.viewController = self
        // toolbar
        // toolbar.addPreferences(to: ViewGraph)
        // ...
        // IsAppleInternalBuild
    }
    
    open override func loadView() {
        view = host
    }
    
    public var rootView: Content {
        get { host.rootView }
        set { host.rootView = newValue }
    }
    
    public var sizingOptions: UIHostingControllerSizingOptions = [] {
        didSet {
            sizingOptionsDidChange(from: oldValue)
        }
    }
    
    @_spi(Private)
    public func setRootView(_ newRootView: Content, transaction: Transaction) {
        // TODO
    }
    
    public func sizeThatFits(in size: CGSize) -> CGSize {
        host.sizeThatFits(size)
    }
    
    public func _render(seconds: Double) {
        host.render(interval: seconds, targetTimestamp: nil)
    }
    
    public func _forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {
        host.forEachIdentifiedView(body: body)
    }
    
    @available(*, deprecated, message: "Use UIHostingController/safeAreaRegions or _UIHostingView/safeAreaRegions")
    public var _disableSafeArea: Swift.Bool {
        get {
            host.explicitSafeAreaInsets == .zero
        }
        set {
            host.explicitSafeAreaInsets = newValue ? .zero : nil
        }
    }
    
    final public var _rendererConfiguration: _RendererConfiguration {
        get { host._rendererConfiguration }
        set { host._rendererConfiguration = newValue }
    }
    
    final public var _rendererObject: AnyObject? {
        host._rendererObject
    }
    
    func sizingOptionsDidChange(from oldSizingOptions: UIHostingControllerSizingOptions) {
        // TODO
    }
}

@available(macOS, unavailable)
extension UIHostingController {
    public var safeAreaRegions: SafeAreaRegions {
        get { host.safeAreaRegions }
        set { host.safeAreaRegions = newValue }
    }
}
#endif
