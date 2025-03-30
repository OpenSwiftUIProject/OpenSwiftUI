//
//  NSHostingController.swift
//  OpenSwiftUI
//
//  Audited for macOS 15.0
//  Status: WIP

#if os(macOS)

public import AppKit

@MainActor
@preconcurrency
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
open class NSHostingController<Content>: NSViewController where Content: View {
    var host: NSHostingView<Content>

    public init(rootView: Content) {
        // TODO:
        self.host = NSHostingView(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
        _commonInit()
    }

    public init?(coder: NSCoder, rootView: Content) {
        // TODO:
        self.host = NSHostingView(rootView: rootView)
        super.init(coder: coder)
        _commonInit()
    }

    func _commonInit() {
        host.viewController = self
    }

    public required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) must be implemented in a subclass and call super.init(coder:, rootView:)")
    }

    open override func loadView() {
        view = host
    }

    public var rootView: Content {
        get { host.rootView }
        set { host.rootView = newValue }
    }

    public final var _rendererConfiguration: _RendererConfiguration {
        get { host._rendererConfiguration }
        set { host._rendererConfiguration = newValue }
    }

    public final var _rendererObject: AnyObject? {
        host._rendererObject
    }

    public var sizingOptions: NSHostingSizingOptions {
        get { host.sizingOptions }
        set { host.sizingOptions = newValue }
    }

    public var safeAreaRegions: SafeAreaRegions {
        get { host.safeAreaRegions }
        set { host.safeAreaRegions = newValue }
    }
    
    public func sizeThatFits(in size: CGSize) -> CGSize {
        let hostView = host
        let proposedSize = _ProposedSize(size)
        let result = hostView.sizeThatFits(proposedSize)
        return result
    }
    
    
    public func _forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {
        host._forEachIdentifiedView(body: body)
    }
    
    
}

#endif
