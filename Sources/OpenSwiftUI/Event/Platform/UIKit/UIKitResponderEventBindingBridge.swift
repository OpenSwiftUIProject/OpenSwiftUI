//
//  UIKitResponderEventBindingBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: ED70A33AE6FB27E683E05B683F821173 (SwiftUI)

#if os(iOS) || os(visionOS)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - UIKitResponderEventBindingBridge

final class UIKitResponderEventBindingBridge: EventBindingBridge {
    private var gestureRecognizer: UIKitResponderGestureRecognizer

    private var actions: [() -> Void] = []

    init(
        eventBindingManager: EventBindingManager,
        responder: any AnyGestureResponder
    ) {
        let gestureRecognizer = UIKitResponderGestureRecognizer()
        self.gestureRecognizer = gestureRecognizer
        gestureRecognizer.responder = responder
        super.init(eventBindingManager: eventBindingManager)
        gestureRecognizer.attach(to: self)
    }

    override var eventSources: [any EventBindingSource] {
        [gestureRecognizer]
    }

    override func reset(
        eventSource: any EventBindingSource,
        resetForwardedEventDispatchers: Bool
    ) {
        super.reset(
            eventSource: eventSource,
            resetForwardedEventDispatchers: resetForwardedEventDispatchers
        )
        actions = []
    }

    @objc
    func flushActions() {
        guard !actions.isEmpty else {
            if gestureRecognizer.state == .cancelled {
                gestureRecognizer.reset()
            }
            return
        }
        let actions = actions
        self.actions = []
        let relatedAttribute = gestureRecognizer.responder?.relatedAttribute
        let actionID = Update.enqueueAction(reason: .gesture) {
            for action in actions {
                action()
            }
        }
        CustomEventTrace.additionalInfo(actionID, info: relatedAttribute)
    }
}

// MARK: - UIKitResponderEventBindingBridge + GestureGraphDelegate

extension UIKitResponderEventBindingBridge: GestureGraphDelegate {
    func enqueueAction(_ action: @escaping () -> Void) {
        actions.append(action)
    }
}

// MARK: - UIKitResponderEventBindingBridge.Factory

extension UIKitResponderEventBindingBridge {
    struct Factory: EventBindingBridgeFactory {
        static func makeEventBindingBridge(
            bindingManager: EventBindingManager,
            responder: any AnyGestureResponder
        ) -> any EventBindingBridge & GestureGraphDelegate {
            let bridge = UIKitResponderEventBindingBridge(
                eventBindingManager: bindingManager,
                responder: responder
            )
            bindingManager.delegate = bridge
            return bridge
        }
    }
}

#endif
