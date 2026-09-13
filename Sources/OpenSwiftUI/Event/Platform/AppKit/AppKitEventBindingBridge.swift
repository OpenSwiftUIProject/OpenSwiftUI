//
//  AppKitEventBindingBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: DAB40C198C0B1A2746A7C71FDA62A608 (SwiftUI)

#if os(macOS)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - AppKitEventBindingBridge

class AppKitEventBindingBridge: EventBindingBridge {
    private(set) lazy var recognizer = AppKitGestureRecognizer(eventBridge: self)

    private weak var hostingView: (any EventBindingSource)?

    init(
        hostingViewBindingSource: any EventBindingSource,
        eventBindingManager: EventBindingManager
    ) {
        hostingView = hostingViewBindingSource
        super.init(eventBindingManager: eventBindingManager)
    }

    override var eventSources: [any EventBindingSource] {
        if let hostingView {
            [recognizer, hostingView]
        } else {
            [recognizer]
        }
    }

    override func source(for sourceType: EventSourceType) -> (any EventBindingSource)? {
        switch sourceType {
        case .platformGestureRecognizer:
            recognizer
        case .platformHostingView:
            hostingView
        }
    }
}
#endif
