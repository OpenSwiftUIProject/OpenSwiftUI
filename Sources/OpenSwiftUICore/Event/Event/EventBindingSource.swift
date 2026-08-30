//
//  EventBindingSource.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - EventBindingSource

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public protocol EventBindingSource: AnyObject {
    func attach(to eventBridge: EventBindingBridge)

    func `as`<T>(_ type: T.Type) -> T?

    func didUpdate(
        phase: GesturePhase<Void>,
        in eventBridge: EventBindingBridge
    )

    func didUpdate(
        gestureCategory: GestureCategory,
        in eventBridge: EventBindingBridge
    )

    func didBind(
        to newBinding: EventBinding,
        id: EventID,
        in eventBridge: EventBindingBridge
    )

    #if os(macOS)
    func didRequestHoverUpdate(
        in eventBridge: EventBindingBridge
    )
    #endif
}

@_spi(ForOpenSwiftUIOnly)
extension EventBindingSource {
    public func `as`<T>(_ type: T.Type) -> T? { nil }

    public func didUpdate(
        phase: GesturePhase<Void>,
        in eventBridge: EventBindingBridge
    ) {
        _openSwiftUIEmptyStub()
    }

    public func didUpdate(
        gestureCategory: GestureCategory,
        in eventBridge: EventBindingBridge
    ) {
        _openSwiftUIEmptyStub()
    }

    public func didBind(
        to newBinding: EventBinding,
        id: EventID,
        in eventBridge: EventBindingBridge
    ) {
        _openSwiftUIEmptyStub()
    }

    #if os(macOS)
    public func didRequestHoverUpdate(
        in eventBridge: EventBindingBridge
    ) {
        _openSwiftUIEmptyStub()
    }
    #endif
}

// MARK: - EventBindingBridgeFactory

package protocol EventBindingBridgeFactory {
    static func makeEventBindingBridge(
        bindingManager: EventBindingManager,
        responder: any AnyGestureResponder
    ) -> any EventBindingBridge & GestureGraphDelegate
}

package struct EventBindingBridgeFactoryInput: ViewInput {
    package static let defaultValue: (any EventBindingBridgeFactory.Type)? = nil
}

extension _ViewInputs {
    @inline(__always)
    package var eventBindingBridgeFactory: (any EventBindingBridgeFactory.Type)? {
        get { self[EventBindingBridgeFactoryInput.self] }
        set { self[EventBindingBridgeFactoryInput.self] = newValue }
    }

    package func makeEventBindingBridge(
        bindingManager: EventBindingManager,
        responder: any AnyGestureResponder
    ) -> any EventBindingBridge & GestureGraphDelegate {
        guard let factory = eventBindingBridgeFactory else {
            preconditionFailure("Event binding factory must be configured")
        }
        return factory.makeEventBindingBridge(
            bindingManager: bindingManager,
            responder: responder
        )
    }
}
