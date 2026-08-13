//
//  UIKitEventBindingBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - UIKitEventBindingBridge

class UIKitEventBindingBridge: EventBindingBridge {
    var gestureRecognizer: UIKitGestureRecognizer?

    var hoverGestureRecognizer: UIKitHoverGestureRecognizer

    var keyPressResponder: UIKitKeyPressResponder?
    
    @available(*, unavailable)
    override init() {
        preconditionFailure("init() has not been implemented")
    }
    
    override init(eventBindingManager: EventBindingManager) {
        gestureRecognizer = GestureContainerFeature.isEnabled ? nil : UIKitGestureRecognizer()
        hoverGestureRecognizer = UIKitHoverGestureRecognizer()
        keyPressResponder = nil
        super.init(eventBindingManager: eventBindingManager)
        gestureRecognizer?.attach(to: self)
        hoverGestureRecognizer.attach(to: self)
    }

    override var eventSources: [any EventBindingSource] {
        var sources: [any EventBindingSource] = GestureContainerFeature.isEnabled
            ? []
            : [gestureRecognizer!]
        sources.append(hoverGestureRecognizer)
        return sources
    }

    func hostingView<Content>(
        _ view: _UIHostingView<Content>,
        didMoveToWindow window: UIWindow?
    ) where Content: View {
        if window != nil {
            let provider = view.as(FallbackResponderProvider.self)
            let responder = UIKitKeyPressResponder()
            responder.eventBindingManager = eventBindingManager
            responder.fallbackResponderProvider = provider
            keyPressResponder = responder
        } else {
            keyPressResponder = nil
        }
    }

    override func source(
        for sourceType: EventSourceType
    ) -> (any EventBindingSource)? {
        switch sourceType {
        case .platformGestureRecognizer:
            gestureRecognizer
        case .hoverGestureRecognizer:
            hoverGestureRecognizer
        default:
            preconditionFailure("Unreachable err")
        }
    }
}
#endif
