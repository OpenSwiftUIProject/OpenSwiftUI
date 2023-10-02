import Foundation

func conformsToProtocol(_ type: Any.Type, _ protocolDescriptor: UnsafeRawPointer) -> Bool {
    swiftConformsToProtocol(type, protocolDescriptor) != nil
}


// witness_table* swift_conformsToProtocol(type*, protocol*);
@_silgen_name("swift_conformsToProtocol")
@inline(__always)
private func swiftConformsToProtocol(_ type: Any.Type,
                             _ protocolDescriptor: UnsafeRawPointer) -> UnsafeRawPointer?
