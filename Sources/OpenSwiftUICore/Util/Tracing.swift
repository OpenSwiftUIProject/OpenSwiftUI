//
//  Tracing.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
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
import OpenGraphShims
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
            #if canImport(Darwin)
            var info = Dl_info()
            guard dladdr(nominalDescriptor, &info) != 0 else {
                return unknown
            }
            let name = (String(cString: info.dli_fname) as NSString).lastPathComponent
            moduleLookupCache.value[nominalDescriptor] = name
            return name
            #else
            // TODO: [Easy] Add a C layer to import dladdr on non-Darwin Swift platform
            // See https://forums.swift.org/t/dladdr-and-the-clang-importer/26379/11
            return unknown
            #endif
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
        "", // TODO: For os_log use
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
            "", // TODO: For os_log use
            [
                current.rawValue,
                1,
                current.graph.counter(for: ._4) // FIXME: UInt
            ]
        )
        #endif
    }
    return Signpost.bodyInvoke.traceInterval(
        object: nil,
        "", // TODO: For os_log use
        [
            Metadata(v).description,
            Tracing.libraryName(defining: v)
        ],
        closure: body
    )
}
