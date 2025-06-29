//
//  GestureContainerFactory.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - GestureContainerFactory [6.5.4]

package protocol GestureContainerFactory {
    static func makeGestureContainer(responder: any AnyGestureContainingResponder) -> AnyObject
}

package struct GestureContainerFactoryInput: ViewInput {
    package static let defaultValue: (any GestureContainerFactory.Type)? = nil

    package typealias Value = (any GestureContainerFactory.Type)?
}

extension _ViewInputs {
    package func makeGestureContainer(responder: any AnyGestureContainingResponder) -> AnyObject {
        guard let factory = self[GestureContainerFactoryInput.self] else {
            preconditionFailure("Gesture container factory must be configured")
        }
        return factory.makeGestureContainer(responder: responder)
    }
}
