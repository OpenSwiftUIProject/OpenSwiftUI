//
//  GestureContainerFactory.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - GestureContainerFactory

package protocol GestureContainerFactory {
    static func makeGestureContainer(responder: any AnyGestureContainingResponder) -> AnyObject
}

package struct GestureContainerFactoryInput: ViewInput {
    package static let defaultValue: (any GestureContainerFactory.Type)? = nil

    package typealias Value = (any GestureContainerFactory.Type)?
}

extension _ViewInputs {
    @inline(__always)
    package var gestureContainerFactory: (any GestureContainerFactory.Type)? {
        get { self[GestureContainerFactoryInput.self] }
        set { self[GestureContainerFactoryInput.self] = newValue }
    }

    package func makeGestureContainer(responder: any AnyGestureContainingResponder) -> AnyObject {
        guard let factory = gestureContainerFactory else {
            preconditionFailure("Gesture container factory must be configured")
        }
        return factory.makeGestureContainer(responder: responder)
    }
}
