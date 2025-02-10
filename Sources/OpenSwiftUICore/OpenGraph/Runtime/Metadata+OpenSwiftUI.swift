//
//  Metadata+OpenSwiftUI.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

public import OpenGraphShims

extension Metadata {
    package var isValueType: Bool {
        switch kind {
            case .struct, .enum, .optional, .tuple: true
            default: false
        }
    }

    public func genericType(at index: Int) -> any Any.Type {
        UnsafeRawPointer(rawValue)
            .advanced(by: index &* 8)
            .advanced(by: 16)
            .assumingMemoryBound(to: Any.Type.self)
            .pointee
    }

    #if OPENSWIFTUI_SUPPORT_2024_API
    @inline(__always)
    package func projectEnum(
        at ptr: UnsafeRawPointer,
        tag: Int,
        _ body: (UnsafeRawPointer) -> Void
    ) {
        projectEnumData(UnsafeMutableRawPointer(mutating: ptr))
        body(ptr)
        injectEnumTag(tag: UInt32(tag), UnsafeMutableRawPointer(mutating: ptr))
    }
    #endif
}
