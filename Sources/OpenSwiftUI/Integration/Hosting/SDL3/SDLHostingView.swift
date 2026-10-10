//
//  SDLHostingView.swift
//  OpenSwiftUI

#if OPENSWIFTUI_SDL3
import Foundation
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import SwiftSDL3
@_implementationOnly import OpenSwiftUISkia

final class SDLHostingView: ViewRendererHost, ViewGraphRenderHost, EventGraphHost {
    typealias RootView = ModifiedContent<AnyView, HitTestBindingModifier>

    let viewGraph: ViewGraph
    let eventBindingManager = EventBindingManager()
    private lazy var mouseEvents = SDLMouseEventSource(manager: eventBindingManager)
    var focusedResponder: ResponderNode? { nil }
    let rootView: AnyView
    let window: OpaquePointer
    let renderer: SDLViewUpdater
    let wakeEvent: UInt32
    var environment: EnvironmentValues
    var size: CGSize = .zero
    var scale: CGFloat = 1
    var currentTimestamp: Time = .zero
    var propertiesNeedingUpdate: ViewRendererHostProperties = .all
    var renderingPhase: ViewRenderingPhase = .none
    var externalUpdateCount: Int = 0
    private let deadlineLock = NSLock()
    private var deadline = Double.infinity
    private var lastRenderTime = Double(SDL_GetTicksNS()) / 1e9
    private var closed = false

    var windowID: SDL_WindowID { SDL_GetWindowID(window) }

    init(rootView: AnyView, environment: EnvironmentValues, wakeEvent: UInt32) {
        self.rootView = rootView
        self.environment = environment
        self.environment.scenePhase = .active
        self.environment.textLayoutBackend = SkiaTextLayoutBackend()
        self.wakeEvent = wakeEvent
        let properties = SDL_CreateProperties()
        defer { SDL_DestroyProperties(properties) }
        SDL_SetStringProperty(properties, SDL_PROP_WINDOW_CREATE_TITLE_STRING, "OpenSwiftUI SDL3")
        SDL_SetNumberProperty(properties, SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER, 640)
        SDL_SetNumberProperty(properties, SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER, 480)
        SDL_SetBooleanProperty(properties, SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN, true)
        SDL_SetBooleanProperty(properties, SDL_PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN, true)
        guard let window = SDL_CreateWindowWithProperties(properties) else {
            fatalError("SDL_CreateWindow: \(String(cString: SDL_GetError()))")
        }
        self.window = window
        renderer = SDLViewUpdater(window: window)
        viewGraph = ViewGraph(rootViewType: RootView.self, requestedOutputs: [.displayList, .layout, .viewResponders])
        initializeViewGraph()
        eventBindingManager.host = self
        eventBindingManager.delegate = mouseEvents
        updateWindowMetrics()
        requestUpdate(after: 0)
    }

    func close() {
        guard !closed else { return }
        closed = true
        mouseEvents.cancel()
        Update.ensure {
            invalidate()
            viewGraph.invalidate()
        }
        renderer.destroy()
        SDL_DestroyWindow(window)
    }

    func updateWindowMetrics() {
        var width: Int32 = 0
        var height: Int32 = 0
        SDL_GetWindowSizeInPixels(window, &width, &height)
        let displayScale = CGFloat(SDL_GetWindowDisplayScale(window))
        scale = displayScale > 0 ? displayScale : 1
        size = CGSize(width: CGFloat(width) / scale, height: CGFloat(height) / scale)
        environment.displayScale = scale
        Update.ensure { invalidateProperties([.size, .containerSize, .environment]) }
    }

    func handle(_ event: SDL_Event) {
        guard !closed else { return }
        switch SDL_EventType(event.type) {
        case SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED, SDL_EVENT_WINDOW_DISPLAY_SCALE_CHANGED:
            if event.window.windowID == windowID { updateWindowMetrics() }
        case SDL_EVENT_WINDOW_EXPOSED, SDL_EVENT_WINDOW_SHOWN:
            if event.window.windowID == windowID { requestUpdate(after: 0) }
        case SDL_EVENT_WINDOW_FOCUS_GAINED, SDL_EVENT_WINDOW_FOCUS_LOST:
            if event.window.windowID == windowID {
                if event.type == SDL_EVENT_WINDOW_FOCUS_LOST.rawValue { mouseEvents.cancel() }
                environment.scenePhase = event.type == SDL_EVENT_WINDOW_FOCUS_GAINED.rawValue ? .active : .inactive
                Update.ensure { invalidateProperties(.environment) }
            }
        case SDL_EVENT_WINDOW_HIDDEN, SDL_EVENT_WINDOW_MINIMIZED:
            if event.window.windowID == windowID { mouseEvents.cancel() }
        case SDL_EVENT_MOUSE_BUTTON_DOWN, SDL_EVENT_MOUSE_BUTTON_UP, SDL_EVENT_MOUSE_MOTION:
            renderIfNeeded()
            mouseEvents.handle(event, window: window, size: size)
        default: break
        }
    }

    func requestUpdate(after delay: Double) {
        deadlineLock.withLock {
            deadline = min(deadline, Double(SDL_GetTicksNS()) / 1e9 + max(delay, 0))
        }
        var event = SDL_Event()
        event.type = wakeEvent
        SDL_PushEvent(&event)
    }

    func renderIfNeeded() {
        let now = Double(SDL_GetTicksNS()) / 1e9
        let needsRender = deadlineLock.withLock {
            guard now >= deadline else { return false }
            deadline = .infinity
            return true
        }
        guard needsRender, !closed, size.width > 0, size.height > 0 else { return }
        render(interval: max(now - lastRenderTime, 0), targetTimestamp: nil)
        lastRenderTime = now
    }

    func updateRootView() { viewGraph.setRootView(Self.makeRootView(rootView)) }
    func updateEnvironment() { viewGraph.setEnvironment(environment) }
    func updateSize() { viewGraph.setProposedSize(size) }
    func updateSafeArea() { viewGraph.setSafeAreaInsets(.zero) }
    func updateContainerSize() { viewGraph.setContainerSize(.fixed(size)) }
    func updateFocusStore() {}
    func updateFocusedItem() {}
    func updateFocusedValues() {}
    func updateAccessibilityEnvironment() {}

    func `as`<T>(_ type: T.Type) -> T? {
        self as? T
    }

    func renderDisplayList(
        _ displayList: DisplayList,
        asynchronous: Bool,
        time: Time,
        nextTime: Time,
        targetTimestamp: Time?,
        version: DisplayList.Version,
        maxVersion: DisplayList.Version
    ) -> Time {
        precondition(!asynchronous, "SDL3 presentation is main-thread only")
        if ProcessInfo.processInfo.environment["OPENSWIFTUI_PRINT_TREE"] == "1" {
            print("View \(Unmanaged.passUnretained(self).toOpaque()) at \(time):\n\(displayList.description)")
        }
        renderer.render(displayList, scale: scale)
        return nextTime
    }
}
#endif
