//
//  TypeConformance.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

struct TypeConformance<PD: ProtocolDescriptor> {
    var metadata: UnsafeRawPointer
    var conformance: UnsafeRawPointer
    
    init?(_ type: Any.Type) {
        guard let conformance = swiftConformsToProtocol(type, PD.descriptor) else {
            return nil
        }
        self.metadata = unsafeBitCast(type, to: UnsafeRawPointer.self)
        self.conformance = conformance
    }
}

func conformsToProtocol(_ type: Any.Type, _ protocolDescriptor: UnsafeRawPointer) -> Bool {
    swiftConformsToProtocol(type, protocolDescriptor) != nil
}

@_silgen_name("swift_conformsToProtocol")
@inline(__always)
private func swiftConformsToProtocol(
    _ type: Any.Type,
    _ protocolDescriptor: UnsafeRawPointer
) -> UnsafeRawPointer?
