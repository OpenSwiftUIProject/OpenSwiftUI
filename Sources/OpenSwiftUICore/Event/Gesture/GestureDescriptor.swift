//
//  GestureDescriptor.swift
//  OpenSwiftUICore
//
//  Status: Complete

import OpenSwiftUI_SPI

// MARK: - GestureDescriptor [6.5.4]

package struct GestureDescriptor: TupleDescriptor {
    package static var typeCache: [ObjectIdentifier: TupleTypeDescription<GestureDescriptor>] = [:]

    package static var descriptor: UnsafeRawPointer {
        _OpenSwiftUI_gestureProtocolDescriptor()
    }
}

// MARK: - GestureModifierDescriptor [6.5.4]

package struct GestureModifierDescriptor: TupleDescriptor {
    package static var typeCache: [ObjectIdentifier: TupleTypeDescription<GestureModifierDescriptor>] = [:]

    package static var descriptor: UnsafeRawPointer {
        _OpenSwiftUI_gestureModifierProtocolDescriptor()
    }
}
