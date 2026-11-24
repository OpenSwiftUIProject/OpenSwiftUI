//
//  WebApp.swift
//  OpenSwiftUI
//

#if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
@_spi(ForOpenSwiftUIOnly)
@_spi(WebRenderer)
import OpenSwiftUICore

// MARK: - runWebApp

// The browser app is single-threaded today. Keep the headless host alive after
// the initial frame so Web gesture and keyboard callbacks can update its graph.
nonisolated(unsafe) private var activeWebRendererHost: AnyObject?

func runWebApp(
    _ app: some App,
    options: _RendererConfiguration.WebOptions
) {
    let host = renderHeadlessApp(
        app,
        surface: options.surface,
        configuration: .web(options)
    )
    if let webHost = host as? any WebHeadlessHostProtocol {
        configureWebKeyDispatch(on: webHost, eventBridge: options.eventBridge)
    }
    activeWebRendererHost = host
}

private func configureWebKeyDispatch(
    on webHost: any WebHeadlessHostProtocol,
    eventBridge: _WebEventBridge
) {
    webHost.focusedResponderProvider = { rootResponder in
        findFocusedResponder(in: rootResponder)
    }
    webHost.eventBindingManager.addForwardedEventDispatcher(KeyEventDispatcher())
    var tracker = KeyEvent.Tracker()
    eventBridge.keyEventHandler = { [weak manager = webHost.eventBindingManager] webEvent in
        guard let manager, !webEvent.key.isEmpty else {
            return false
        }
        let phase: EventPhase = switch webEvent.phase {
        case .down: .began
        case .repeat: .active
        case .up: .ended
        }
        let keyEvent = KeyEvent(
            phase: phase,
            timestamp: .systemUptime,
            modifiers: webEvent.modifiers,
            keys: webEvent.key,
            stringValue: webEvent.characters,
            keyID: webEvent.keyID
        )
        let serial = tracker.serial(for: keyEvent)
        let id = EventID(type: KeyEvent.self, serial: serial)
        return !manager.send([id: keyEvent]).isEmpty
    }
}

private func findFocusedResponder(in rootResponder: ResponderNode?) -> ResponderNode? {
    guard let rootResponder else { return nil }
    var candidateWithHandlers: ResponderNode?
    var fallbackCandidate: ResponderNode?
    rootResponder.visitFocusResponders { responder in
        guard responder.focusItem?.isFocusable == true,
              let node = responder as? ResponderNode else {
            return .next
        }
        fallbackCandidate = node
        if !responder.keyPressHandlers.isEmpty {
            candidateWithHandlers = node
        }
        return .next
    }
    return candidateWithHandlers ?? fallbackCandidate
}
#endif
