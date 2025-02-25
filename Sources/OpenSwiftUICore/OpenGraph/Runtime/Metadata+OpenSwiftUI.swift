//
//  Metadata+OpenSwiftUI.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import OpenGraphShims

extension Metadata {
    package var isValueType: Bool {
        switch kind {
            case .struct, .enum, .optional, .tuple: true
            default: false
        }
    }

    package func genericType(at index: Int) -> any Any.Type {
        UnsafeRawPointer(rawValue)
            .advanced(by: index &* 8)
            .advanced(by: 16)
            .assumingMemoryBound(to: Any.Type.self)
            .pointee
    }

    @inline(__always)
    package func projectEnum(
        at ptr: UnsafeRawPointer,
        tag: Int,
        _ body: (UnsafeRawPointer) -> Void
    ) {
        #if OPENSWIFTUI_SUPPORT_2024_API
        projectEnumData(UnsafeMutableRawPointer(mutating: ptr))
        body(ptr)
        injectEnumTag(tag: UInt32(tag), UnsafeMutableRawPointer(mutating: ptr))
        #endif
    }
}

@inline(__always)
package func compareEnumTags<T>(_ v1: T, _ v2: T) -> Bool {
    func tag(of value: T) -> Int {
        withUnsafePointer(to: value) {
            Int(Metadata(T.self).enumTag($0))
        }
    }
    let tag1 = tag(of: v1)
    let tag2 = tag(of: v2)
    return tag1 == tag2
}
