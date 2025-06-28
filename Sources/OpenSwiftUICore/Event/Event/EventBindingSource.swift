//
//  EventBindingSource.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - EventBindingSource [6.5.4]

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
}

@_spi(ForOpenSwiftUIOnly)
extension EventBindingSource {
    public func `as`<T>(_ type: T.Type) -> T? { nil }

    public func didUpdate(
        phase: GesturePhase<Void>,
        in eventBridge: EventBindingBridge
    ) {}

    public func didUpdate(
        gestureCategory: GestureCategory,
        in eventBridge: EventBindingBridge
    ) {}

    public func didBind(
        to newBinding: EventBinding,
        id: EventID,
        in eventBridge: EventBindingBridge
    ) {}
}

// MARK: - EventBindingBridgeFactory [6.5.4]

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
    package func makeEventBindingBridge(
        bindingManager: EventBindingManager,
        responder: any AnyGestureResponder
    ) -> any EventBindingBridge & GestureGraphDelegate {
        guard let factory = self[EventBindingBridgeFactoryInput.self] else {
            preconditionFailure("Event binding factory must be configured")
        }
        return factory.makeEventBindingBridge(
            bindingManager: bindingManager,
            responder: responder
        )
    }
}
