//
//  TypeConformance.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by ExistentialMetatype

import OpenSwiftUI_SPI
import OpenGraphShims

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

    package var type: any Any.Type { storage.type }

    package var conformance: UnsafeRawPointer { storage.conformance }

    package var metadata: UnsafeRawPointer { unsafeBitCast(storage.type, to: UnsafeRawPointer.self) }

    package func unsafeExistentialMetatype<ExistentialMetatype>(_ type: ExistentialMetatype.Type) -> ExistentialMetatype {
        preconditionFailure("TODO")
    }
}

package func conformsToProtocol(_ type: any Any.Type, _ desc: UnsafeRawPointer) -> Bool {
    swiftConformsToProtocol(type, desc) != nil
}

@_silgen_name("swift_conformsToProtocol")
private func swiftConformsToProtocol(
    _ type: Any.Type,
    _ protocolDescriptor: UnsafeRawPointer
) -> UnsafeRawPointer?
