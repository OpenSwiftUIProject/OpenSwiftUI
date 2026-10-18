//
//  FirstResponderObserver.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C46338C7764E4E02DFE8CA9F275E0662 (SwiftUI)

#if os(macOS)
import AppKit
import OpenSwiftUICore

private var observerKey: UInt8 = 0
private var observerContext: UInt8 = 0

// MARK: - FirstResponderObserver

private class FirstResponderObserver: NSObject {
    weak var window: NSWindow?
    var queue: [WeakBox<NSResponder>] = []

    init(window: NSWindow) {
        self.window = window
        super.init()
        window.addObserver(
            self,
            forKeyPath: "firstResponder",
            options: [.old, .new],
            context: &observerContext
        )
    }

    deinit {
        window?.removeObserver(
            self,
            forKeyPath: "firstResponder",
            context: &observerContext
        )
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        let isObserverContext = withUnsafeMutablePointer(to: &observerContext) {
            context == UnsafeMutableRawPointer($0)
        }
        guard isObserverContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == "firstResponder", let change {
            notifyAffectedRenderers(change)
        }
    }

    func notifyAffectedRenderers(_ change: [NSKeyValueChangeKey: Any]) {
        var notified: Set<ObjectIdentifier> = []
        for responder in queue {
            if let responder = responder.base {
                notifyResponderChain(responder, notified: &notified)
            }
        }
        queue = []
        if let responder = change[.oldKey] as? NSResponder {
            notifyResponderChain(responder, notified: &notified)
        }
        if let responder = change[.newKey] as? NSResponder {
            notifyResponderChain(responder, notified: &notified)
        }
    }

    private func notifyResponderChain(_ responder: NSResponder, notified: inout Set<ObjectIdentifier>) {
        var next: NSResponder? = responder
        while let responder = next {
            if let renderer = responder as? any ViewRendererHost {
                let identity = ObjectIdentifier(responder)
                guard !notified.contains(identity) else { return }
                Update.enqueueAction {
                    renderer.as((any FocusHost).self)?.focusDidChange()
                }
                notified.insert(identity)
            }
            next = responder.nextResponder
        }
    }
}

// MARK: - NSWindow + FirstResponderObserver

extension NSWindow {
    fileprivate var firstResponderObserver: FirstResponderObserver? {
        objc_getAssociatedObject(self, &observerKey) as? FirstResponderObserver
    }

    @inline(__always)
    func observeFirstResponderChanges() {
        guard firstResponderObserver == nil else { return }
        let observer = FirstResponderObserver(window: self)
        objc_setAssociatedObject(self, &observerKey, observer, .OBJC_ASSOCIATION_RETAIN)
    }

    @inline(__always)
    func queueFirstResponderChange(for responder: NSResponder) {
        firstResponderObserver?.queue.append(WeakBox(responder))
    }
}
#endif
