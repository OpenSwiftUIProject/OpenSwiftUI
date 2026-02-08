//
//  NSHostingController.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: WIP

#if os(macOS)

public import AppKit

/// An AppKit view controller that hosts SwiftUI view hierarchy.
///
/// Create an `NSHostingController` object when you want to integrate SwiftUI
/// views into an AppKit view hierarchy. At creation time, specify the SwiftUI
/// view you want to use as the root view for this view controller; you can
/// change that view later using the ``NSHostingController/rootView`` property.
/// Use the hosting controller like you would any other view controller, by
/// presenting it or embedding it as a child view controller in your interface.
@MainActor
@preconcurrency
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
open class NSHostingController<Content>: NSViewController where Content: View {
    var host: NSHostingView<Content>

    /// Creates a hosting controller object that wraps the specified SwiftUI
    /// view.
    ///
    /// - Parameter rootView: The root view of the SwiftUI view hierarchy that
    ///   you want to manage using the hosting view controller.
    public init(rootView: Content) {
        // TODO
        self.host = NSHostingView(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
        _commonInit()
    }

    /// Creates a hosting controller object from an archive and the specified
    /// SwiftUI view.
    ///
    /// - Parameters:
    ///   - coder: The decoder to use during initialization.
    ///   - rootView: The root view of the SwiftUI view hierarchy that you want
    ///     to manage using this view controller.
    public init?(coder: NSCoder, rootView: Content) {
        // TODO
        self.host = NSHostingView(rootView: rootView)
        super.init(coder: coder)
        _commonInit()
    }

    func _commonInit() {
        host.viewController = self
        self.view = host
    }

    /// Creates a hosting controller object from the contents of the specified
    /// archive.
    ///
    /// The default implementation of this method throws an exception. To create
    /// your view controller from an archive, override this method and
    /// initialize the superclass using the
    /// ``NSHostingController/init(coder:rootView:)`` method instead.
    ///
    /// - Parameter coder: The decoder to use during initialization.
    public required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) must be implemented in a subclass and call super.init(coder:, rootView:)")
    }
    
    /// The root view of the SwiftUI view hierarchy managed by this view
    /// controller.
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

    /// The options for how the hosting controller's view creates and updates
    /// constraints based on the size of its SwiftUI content.
    ///
    /// NSHostingController can create minimum, maximum, and ideal (content
    /// size) constraints that are derived from its SwiftUI view content. These
    /// constraints are only created when Auto Layout constraints are otherwise
    /// being used in the containing window.
    ///
    /// If the NSHostingController is set as the `contentViewController` of an
    /// `NSWindow`, it will also update the window's `contentMinSize` and
    /// `contentMaxSize` based on the minimum and maximum size of its SwiftUI
    /// content.
    ///
    /// `sizingOptions` defaults to `.standardBounds` (which includes
    /// `minSize`, `intrinsicContentSize`, and `maxSize`), but can be set to an
    /// explicit value to control this behavior. For instance, setting a value
    /// of `.minSize` will only create the constraints necessary to maintain the
    /// minimum size of the SwiftUI content, or setting a value of `[]` will
    /// create no constraints at all.
    ///
    /// If a use case can make assumptions about the size of the
    /// `NSHostingController` relative to its displayed content, such as the
    /// always being displayed in a fixed frame, setting this to a value with
    /// fewer options can improve performance as it reduces the amount of layout
    /// measurements that need to be performed. If an `NSHostingController` has
    /// a `frame` that is smaller or larger than that required to display its
    /// SwiftUI content, the content will be centered within that frame.
    public var sizingOptions: NSHostingSizingOptions {
        get { host.sizingOptions }
        set { host.sizingOptions = newValue }
    }

    /// The safe area regions that this view controller adds to its view.
    ///
    /// The default value is ``SafeAreaRegions.all``.
    public var safeAreaRegions: SafeAreaRegions {
        get { host.safeAreaRegions }
        set { host.safeAreaRegions = newValue }
    }

    /// The options for which aspects of the window will be managed by this
    /// controller's hosting view.
    ///
    /// `NSHostingController` will populate certain aspects of its associated
    /// window, depending on which options are specified.
    ///
    /// For example, a hosting controller can manage its window's toolbar by
    /// including the `.toolbars` option:
    ///
    ///     struct RootView: View {
    ///         var body: some View {
    ///             ContentView()
    ///                 .toolbar {
    ///                     MyToolbarContent()
    ///                 }
    ///         }
    ///     }
    ///
    ///     let controller = NSHostingController(rootView: RootView())
    ///     controller.sceneBridgingOptions = [.toolbars]
    ///
    /// When this hosting controller is set as the `contentViewController` for a
    /// window, the default value for this property will be `.all`, which
    /// includes the options for `.toolbars` and `.title`. Otherwise, the
    /// default value is `[]`.
    public var sceneBridgingOptions: NSHostingSceneBridgingOptions {
        get { host.sceneBridgingOptions }
        set { host.sceneBridgingOptions = newValue }
    }

    open override var preferredContentSize: NSSize {
        get {
            if sizingOptions.contains(.preferredContentSize) {
                return host.idealSize()
            } else {
                return super.preferredContentSize
            }
        }
        set {
            super.preferredContentSize = newValue
        }
    }

    open override var identifier: NSUserInterfaceItemIdentifier? {
        didSet {
            host.identifier = identifier
        }
    }

    /// Calculates and returns the most appropriate size for the current view.
    ///
    /// - Parameter size: The proposed new size for the view.
    ///
    /// - Returns: The size that offers the best fit for the root view and its
    ///   contents.
    public func sizeThatFits(in size: CGSize) -> CGSize {
        let hostView = host
        let proposedSize = _ProposedSize(size)
        let result = hostView.sizeThatFits(proposedSize)
        return result
    }
    
    public func _render(seconds: Double) {
        host.render(interval: seconds, targetTimestamp: nil)
    }

    public func _forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {
        host.forEachIdentifiedView(body: body)
    }
}

#endif
