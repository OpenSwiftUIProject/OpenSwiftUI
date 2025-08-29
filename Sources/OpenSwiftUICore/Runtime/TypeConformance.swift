//
//  TypeConformance.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

import OpenSwiftUI_SPI
import OpenAttributeGraphShims

// MARK: - ProtocolDescriptor

package protocol ProtocolDescriptor {
    static var descriptor: UnsafeRawPointer { get }
}

extension ProtocolDescriptor {
    package static func conformance(of type: any Any.Type) -> TypeConformance<Self>? {
        guard let conformance = swiftConformsToProtocol(type, descriptor) else {
            return nil
        }
        return TypeConformance(storage: (type, conformance))
    }
}

// MARK: - TypeConformance

package struct TypeConformance<P> where P: ProtocolDescriptor {
    package let storage: (type: any Any.Type, conformance: UnsafeRawPointer)

    package init(storage: (type: any Any.Type, conformance: UnsafeRawPointer)) {
        self.storage = storage
    }

    package var type: any Any.Type {
        storage.type
    }

    package var conformance: UnsafeRawPointer {
        storage.conformance
    }

    package var metadata: UnsafeRawPointer {
        unsafeBitCast(storage.type, to: UnsafeRawPointer.self)
    }

    package func unsafeExistentialMetatype<ExistentialMetatype>(_ type: ExistentialMetatype.Type) -> ExistentialMetatype {
        unsafeBitCast(storage, to: type)
    }
}

@_silgen_name("swift_conformsToProtocol")
func swiftConformsToProtocol(
    _ type: Any.Type,
    _ protocolDescriptor: UnsafeRawPointer
) -> UnsafeRawPointer?
