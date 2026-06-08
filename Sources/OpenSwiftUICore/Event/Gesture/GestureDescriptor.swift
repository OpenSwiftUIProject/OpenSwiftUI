//
//  GestureDescriptor.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUI_SPI

// MARK: - GestureDescriptor

package struct GestureDescriptor: TupleDescriptor {
    package static var typeCache: [ObjectIdentifier: TupleTypeDescription<GestureDescriptor>] = [:]

    package static var descriptor: UnsafeRawPointer {
        _gestureProtocolDescriptor()
    }
}

// MARK: - GestureModifierDescriptor

package struct GestureModifierDescriptor: TupleDescriptor {
    package static var typeCache: [ObjectIdentifier: TupleTypeDescription<GestureModifierDescriptor>] = [:]

    package static var descriptor: UnsafeRawPointer {
        _gestureModifierProtocolDescriptor()
    }
}
