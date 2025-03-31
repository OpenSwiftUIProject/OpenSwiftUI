//
// NSHostingMenu.swift
// OpenSwiftUI
//
// Audited for macOS 15.0
// Status: WIP

#if os(macOS)
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
public import OpenSwiftUICore
public import AppKit
import OpenSwiftUI_SPI

@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
open class NSHostingMenu<Content>: NSMenu where Content: View {
    /// Creates a hosting menu object that wraps the specified SwiftUI view.
    ///
    /// - Parameter rootView: The root view of the SwiftUI view hierarchy that
    ///   you want to present using this menu.
    public init(rootView: Content) {
        self._rootView = rootView

        Update.begin()

        // Initialize the view graph with the root view type and requested outputs
        self.viewGraph = ViewGraph(rootViewType: Content.self, requestedOutputs: .platformItemList)

        // Initialize the NSMenu with an empty title
        super.init(title: "")

        // Disable auto-enabling of menu items
        self.autoenablesItems = false

        // Set the root view in the view graph
        viewGraph.setRootView(rootView)

        // Initialize the view graph for the renderer host
        initializeViewGraph()

        // Request an immediate update
        requestUpdate(after: 0.0)

        // End the update cycle
        Update.end()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// The root view of the SwiftUI view hierarchy managed by this menu.
    ///
    /// Updating this property will immediately update the `items` array,
    /// even if the menu is currently visible to the user.
    public var rootView: Content {
        get { _rootView }
        set {
            _rootView = newValue
            invalidateProperties(.rootView)
        }
    }

    private var _rootView: Content
    package final let viewGraph: ViewGraph
    package var propertiesNeedingUpdate: ViewRendererHostProperties = []
    package var renderingPhase: ViewRenderingPhase = .none
    package var externalUpdateCount: Int = 0
    package var currentTimestamp: Time = .zero
}

@available(iOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
extension NSHostingMenu: ViewRendererHost {
//    package func `as`<T>(_ type: T.Type) -> T? {}

    package func modifyViewInputs(_ inputs: inout _ViewInputs) {}

    package func renderDisplayList(_ list: DisplayList, asynchronously: Bool, time: Time, nextTime: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time {
        .infinity
    }

    package func updateRootView() {}
    package func updateEnvironment() {}
    package func updateSize() {}
    package func updateSafeArea() {}
    package func updateScrollableContainerSize() {}
    package func requestUpdate(after delay: Swift.Double) {}
}

@available(*, unavailable)
extension NSHostingMenu: Swift.Sendable {}

#endif
