//
//  Tracing.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: WIP
//  ID: D59B7A281FFF29619A43A3D8F551CCE1 (SwiftUI)
//  ID: 56D4CED87D5B226E2B40FB60C47D6F49 (SwiftUICore)

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif os(WASI)
import WASILibc
#endif
import OpenAttributeGraphShims
import Foundation
import OpenSwiftUI_SPI
#if canImport(Darwin)
import os.log
#endif

package struct Tracing {
    private static var moduleLookupCache = ThreadSpecific<[UnsafeRawPointer: String]>([:])
    
    static func libraryName(defining type: Any.Type) -> String {
        let unknown = "ModuleUnknown"
        guard let nominalDescriptor = Metadata(type).nominalDescriptor else {
            return unknown
        }
        if let cachedName = moduleLookupCache.value[nominalDescriptor] {
            return cachedName
        } else {
            // Use C Shims layer to import dladdr since we can't call it on non-Darwin Swift platform
            // See https://forums.swift.org/t/dladdr-and-the-clang-importer/26379/11
            //
            //      var info = Dl_info()
            //      guard dladdr(nominalDescriptor, &info) != 0 else {
            //          return unknown
            //      }
            //      let pathName = info.dli_fname

            guard let pathName = getSymbolPathName(nominalDescriptor) else {
                return unknown
            }
            let path = String(cString: pathName)
            #if canImport(Darwin)
            let libraryName = (path as NSString).lastPathComponent
            #else
            let libraryName = URL(filePath: path).lastPathComponent
            #endif
            moduleLookupCache.value[nominalDescriptor] = libraryName
            return libraryName
        }
    }
    
    static func nominalTypeName(_ type: Any.Type) -> String {
        Metadata(type).description
    }
}

@_transparent
package func traceBody<Body>(_ v: any Any.Type, body: () -> Body) -> Body {
    Signpost.bodyInvoke.traceInterval(
        object: nil,
        "%{public}@.body [in %{public}@]",
        [
            Metadata(v).description,
            Tracing.libraryName(defining: v)
        ],
        closure: body
    )
}

@_transparent
package func traceRuleBody<Body>(_ v: any Any.Type, body: () -> Body) -> Body {
    defer {
        #if canImport(Darwin)
        let current = AnyAttribute.current!
        Signpost.bodyInvoke.traceEvent(
            type: .end,
            object: nil,
            "-> [%d] (%p)",
            [
                current.rawValue,
                1,
                current.graph.graphIdentity()
            ]
        )
        #endif
    }
    return Signpost.bodyInvoke.traceInterval(
        object: nil,
        "%{public}@.body [in %{public}@]",
        [
            Metadata(v).description,
            Tracing.libraryName(defining: v)
        ],
        closure: body
    )
}

extension Graph {
    package func graphIdentity() -> UInt {
        // FIXME: remove numericCast
        numericCast(counter(for: .contextID))
    }
}

extension ViewGraph {
    package var graphIdentity: UInt {
        graph.graphIdentity()
    }
}

// MARK: - DescriptiveDynamicProperty [6.5.4]

package protocol DescriptiveDynamicProperty {
    var _linkValue: Any { get }
}

extension DescriptiveDynamicProperty {
    fileprivate var linkValueDescription: String {
        if let descriptiveDynamicProperty = _linkValue as? DescriptiveDynamicProperty {
            descriptiveDynamicProperty.linkValueDescription
        } else {
            String(describing: _linkValue)
        }
    }
}

extension DynamicProperty {
    fileprivate var linkValueDescription: String {
        if let descriptiveDynamicProperty = self as? DescriptiveDynamicProperty {
            descriptiveDynamicProperty.linkValueDescription
        } else {
            String(describing: self)
        }
    }
}

extension State: DescriptiveDynamicProperty {
    package var _linkValue: Any { _value }
}

extension Environment: DescriptiveDynamicProperty {
    package var _linkValue: Any { wrappedValue }
}

extension Binding: DescriptiveDynamicProperty {
    package var _linkValue: Any { _value }
}

// MARK: - Trace + Link [6.5.4]

@inline(__always)
func traceLinkCreate(
    field: DynamicPropertyCache.Field,
    address: UnsafeRawPointer,
    type: String,
    typeLibrary: String,
    identifier: UInt32,
    identity: UInt
) {
    Signpost.linkCreate.traceEvent(
        type: .event,
        object: nil,
        "Attached: %{public}@ [ %p ] to %{public}@ (in %{public}@) at offset +%d [%d] (%p)",
        [
            "\(field.type)",                    // %{public}@
            UInt(bitPattern: address),          // %p
            type,                               // %{public}@
            typeLibrary,                        // %{public}@
            field.offset,                       // %d
            identifier,                         // %d
            identity                            // %p
        ]
    )
}

@inline(__always)
func traceLinkUpdate(property: some DynamicProperty, address: UnsafeRawPointer) {
    Signpost.linkUpdate.traceEvent(
        type: .event,
        object: nil,
        "Updated: %{public}@ [ %p ] - %@",
        [
            String(describing: type(of: property)), // %{public}@
            UInt(bitPattern: address),              // %p
            property.linkValueDescription,          // %@
        ]
    )
}

@inline(__always)
func traceLinkDestroy(address: UnsafeRawPointer) {
    Signpost.linkDestroy.traceEvent(
        type: .event,
        object: nil,
        "Detached: [ %p ]",
        [UInt(bitPattern: address)]
    )
}
