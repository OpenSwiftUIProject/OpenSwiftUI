//
//  WebEventBindingBridge.swift
//  OpenSwiftUICore
//

#if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
public import Foundation

/// A browser pointer event in the Web renderer's logical surface coordinates.
@_spi(WebRenderer)
public struct _WebPointerEvent {
    public enum Phase {
        case began
        case moved
        case ended
        case cancelled
    }

    public enum Kind {
        case mouse
        case touch
        case pen
    }

    public var pointerID: Int
    public var phase: Phase
    public var kind: Kind
    public var location: CGPoint
    /// The DOM PointerEvent button number: 0 is primary, 1 is auxiliary,
    /// and 2 is secondary. Movement events reuse the button from pointer down.
    public var button: Int
    public var modifiers: EventModifiers

    public init(
        pointerID: Int,
        phase: Phase,
        kind: Kind,
        location: CGPoint,
        button: Int = 0,
        modifiers: EventModifiers = []
    ) {
        self.pointerID = pointerID
        self.phase = phase
        self.kind = kind
        self.location = location
        self.button = button
        self.modifiers = modifiers
    }
}

/// A browser keyboard event forwarded to the OpenSwiftUI key-press dispatcher.
@_spi(WebRenderer)
public struct _WebKeyEvent {
    public enum Phase {
        case down
        case `repeat`
        case up
    }

    public var phase: Phase
    public var key: String
    public var characters: String
    public var keyID: String
    public var modifiers: EventModifiers

    public init(
        phase: Phase,
        key: String,
        characters: String = "",
        keyID: String = "",
        modifiers: EventModifiers = []
    ) {
        self.phase = phase
        self.key = key
        self.characters = characters.isEmpty ? key : characters
        self.keyID = keyID.isEmpty ? key : keyID
        self.modifiers = modifiers
    }
}

/// Adapts browser pointer sequences to the shared responder and gesture graph.
///
/// The browser owns pointer capture. Gesture recognition, hit testing, tap
/// counts, and callbacks are handled by the same core used by native hosts.
@_spi(WebRenderer)
public final class _WebEventBridge {
    private struct Pointer {
        var serial: Int
        var kind: _WebPointerEvent.Kind
        var button: Int
        var suppressed = false
    }

    private var pointers: [Int: Pointer] = [:]
    private var nextSerial = 0
    private var bridge: WebEventBindingBridge?
    package var keyEventHandler: ((_WebKeyEvent) -> Bool)?
    package var surfaceResizeHandler: ((CGSize) -> Void)?
    private lazy var source = WebPointerEventSource { [weak self] in
        guard let self else { return }
        // A failed recognizer stays failed until the physical pointer ends.
        // Keep its capture lifetime without starting another graph midstream.
        for pointerID in pointers.keys {
            pointers[pointerID]?.suppressed = true
        }
    }

    public init() {}

    package func connect(to manager: EventBindingManager) {
        cancelAll()
        let bridge = WebEventBindingBridge(manager: manager, source: source)
        self.bridge = bridge
        manager.delegate = bridge
    }

    public func send(_ event: _WebPointerEvent) {
        guard let bridge,
              event.location.x.isFinite,
              event.location.y.isFinite else {
            return
        }
        let pointer: Pointer
        switch event.phase {
        case .began:
            guard pointers[event.pointerID] == nil else { return }
            nextSerial &+= 1
            pointer = Pointer(
                serial: nextSerial,
                kind: event.kind,
                button: event.button
            )
            pointers[event.pointerID] = pointer
        case .moved:
            guard let existing = pointers[event.pointerID] else { return }
            pointer = existing
        case .ended, .cancelled:
            guard let existing = pointers.removeValue(forKey: event.pointerID) else { return }
            pointer = existing
        }
        guard !pointer.suppressed else { return }

        let phase: EventPhase
        switch event.phase {
        case .began: phase = .began
        case .moved: phase = .active
        case .ended: phase = .ended
        case .cancelled: phase = .failed
        }
        let timestamp = Time.systemUptime
        let rawEvent: any EventType
        switch pointer.kind {
        case .mouse:
            let button: MouseEvent.Button
            switch pointer.button {
            case 0: button = .primary
            case 1: button = .other(1 << 2)
            case 2: button = .secondary
            default: button = .other(pointer.button)
            }
            rawEvent = MouseEvent(
                timestamp: timestamp,
                button: button,
                phase: phase,
                location: .zero,
                globalLocation: event.location,
                modifiers: event.modifiers
            )
        case .touch, .pen:
            rawEvent = WebTouchEvent(
                timestamp: timestamp,
                phase: phase,
                globalLocation: event.location,
                modifiers: event.modifiers,
                touchType: pointer.kind == .pen ? .pencil : .direct
            )
        }
        let id = EventID(type: type(of: rawEvent), serial: pointer.serial)
        bridge.send([id: rawEvent], source: source)
    }

    /// Cancels all captured pointers, for example when the page loses focus.
    public func cancelAll() {
        Update.ensure {
            pointers.removeAll()
            source.cancelPendingReset()
            bridge?.reset(eventSource: source)
        }
    }

    /// Dispatches a browser keyboard event and returns whether a handler consumed it.
    @discardableResult
    public func send(_ event: _WebKeyEvent) -> Bool {
        keyEventHandler?(event) ?? false
    }

    /// Updates the logical web rendering surface size after a viewport resize.
    public func resizeSurface(to size: CGSize) {
        guard size.width.isFinite, size.height.isFinite,
              size.width > 0, size.height > 0 else {
            return
        }
        surfaceResizeHandler?(size)
    }
}

@_spi(WebRenderer)
@available(*, unavailable)
extension _WebEventBridge: Sendable {}

private final class WebEventBindingBridge: EventBindingBridge {
    private let pointerSource: WebPointerEventSource

    init(manager: EventBindingManager, source: WebPointerEventSource) {
        pointerSource = source
        super.init(eventBindingManager: manager)
        source.attach(to: self)
    }

    override var eventSources: [any EventBindingSource] {
        [pointerSource]
    }

    override func source(for sourceType: EventSourceType) -> (any EventBindingSource)? {
        switch sourceType {
        case .platformGestureRecognizer, .platformHostingView: pointerSource
        default: nil
        }
    }
}

private final class WebPointerEventSource: EventBindingSource {
    private weak var bridge: EventBindingBridge?
    private var resetGeneration = 0
    private let didFinishGesture: () -> Void

    init(didFinishGesture: @escaping () -> Void) {
        self.didFinishGesture = didFinishGesture
    }

    func attach(to eventBridge: EventBindingBridge) {
        cancelPendingReset()
        bridge = eventBridge
    }

    func cancelPendingReset() {
        resetGeneration &+= 1
    }

    func didUpdate(phase: GesturePhase<Void>, in eventBridge: EventBindingBridge) {
        guard phase.isTerminal else { return }
        didFinishGesture()
        resetGeneration &+= 1
        let generation = resetGeneration
        // Wait for the graph's queued onEnded callbacks before tearing down
        // its event subgraph. A partial multi-tap sequence remains possible
        // and never enters this reset path when the first pointer is lifted.
        Update.enqueueAction(reason: nil) { [weak self, weak eventBridge] in
            guard let self,
                  let eventBridge,
                  generation == resetGeneration,
                  bridge === eventBridge else {
                return
            }
            eventBridge.reset(eventSource: self)
        }
    }
}

private struct WebTouchEvent: SpatialEventType, TappableEventType,
    HitTestableEventType, ModifiersEventType, TouchTypeProviding {
    var timestamp: Time
    var phase: EventPhase
    var binding: EventBinding?
    var globalLocation: CGPoint
    var location: CGPoint = .zero
    var modifiers: EventModifiers
    var touchType: TouchType

    var radius: CGFloat { .zero }
    var kind: SpatialEvent.Kind? { .touch }
}
#endif
