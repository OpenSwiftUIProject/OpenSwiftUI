func conformsToProtocol(_ type: Any.Type, _ protocolDescriptor: UnsafeRawPointer) -> Bool {
    swiftConformsToProtocol(type, protocolDescriptor) != nil
}

// FIXME: This kind usage of @_silgen_name is discouraged. But I'm not finding a way to declare or pass Any.Type to C
@_silgen_name("swift_conformsToProtocol")
@inline(__always)
private func swiftConformsToProtocol(_ type: Any.Type,
                             _ protocolDescriptor: UnsafeRawPointer) -> UnsafeRawPointer?
