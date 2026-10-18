//
//  KeyViewProxy.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS)
import AppKit
import COpenSwiftUI
import OpenSwiftUICore

// MARK: - KeyViewProxy

class KeyViewProxy: NSView, FocusBridgeProvider {
    unowned var focusBridge: FocusBridge
    weak var focusResponder: (any FocusResponder)?

    var host: NSView & ViewRendererHost {
        focusBridge.host!
    }

    override var acceptsFirstResponder: Bool {
        guard let window = host.window,
              let item = focusResponder?.focusItem,
              item.isFocusable else {
            return false
        }
        guard window.keyViewSelectionDirection == .directSelection else {
            return item.isNavigable
        }
        guard case let .view(view) = item.base else {
            return false
        }
        return view.options.contains(
            focusBridge.isKeyViewRedirectionDisabled ? .fromClientUpdate : .fromMouse
        )
    }

    override var nextResponder: NSResponder? {
        get { host }
        set { _openSwiftUIEmptyStub() }
    }

    override var isFlipped: Bool {
        true
    }

    override func setFlipped(_ flipped: Bool) {
        _openSwiftUIEmptyStub()
    }

    @objc func selectNextKeyView(_ sender: Any?) {
        focusBridge.selectKeyView(sender: sender, receiver: self, direction: .next)
    }

    @objc func selectPreviousKeyView(_ sender: Any?) {
        focusBridge.selectKeyView(sender: sender, receiver: self, direction: .previous)
    }

    override func designatedFocusRing() -> NSView? {
        focusBridge.designatedFocusRingView
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    init(_ bridge: FocusBridge) {
        focusBridge = bridge
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
}

// MARK: - KeyViewProxyCache

class KeyViewProxyCache {
    unowned var bridge: FocusBridge
    var free: [KeyViewProxy] = []
    var used: [KeyViewProxy] = []

    init(bridge: FocusBridge) {
        self.bridge = bridge
    }

    deinit {
        recycle()
    }

    func recycle() {
        free = used
        used = []
        for view in free {
            view.removeFromSuperview()
            view.focusResponder = nil
        }
    }

    func dequeue() -> KeyViewProxy {
        let view = free.popLast() ?? KeyViewProxy(bridge)
        used.append(view)
        view.frame = .zero
        if view.superview !== bridge.host {
            bridge.host?.addSubview(view)
        }
        return view
    }
}
#endif
