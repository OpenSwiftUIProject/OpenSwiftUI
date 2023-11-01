func conformsToProtocol(_ type: Any.Type, _ protocolDescriptor: UnsafeRawPointer) -> Bool {
    swiftConformsToProtocol(type, protocolDescriptor) != nil
}

@_silgen_name("swift_conformsToProtocol")
@inline(__always)
private func swiftConformsToProtocol(_ type: Any.Type,
                             _ protocolDescriptor: UnsafeRawPointer) -> UnsafeRawPointer?
