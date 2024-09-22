//
//  Tracing.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP
//  ID: D59B7A281FFF29619A43A3D8F551CCE1 (RELEASE_2021)
//  ID: 56D4CED87D5B226E2B40FB60C47D6F49 (RELEASE_2024)

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif os(WASI)
import WASILibc
#endif
internal import OpenGraphShims
import Foundation

enum Tracing {
    // RELEASE_2021 ID: D59B7A281FFF29619A43A3D8F551CCE1
    // RELEASE_2024 ID: 56D4CED87D5B226E2B40FB60C47D6F49
    private static var moduleLookupCache = ThreadSpecific<[UnsafeRawPointer : String]>([:])
    
    static func libraryName(defining type: Any.Type) -> String {
        let unknown = "ModuleUnknown"
        guard let nominalDescriptor = OGTypeID(type).nominalDescriptor else {
            return unknown
        }
        if let cachedName = moduleLookupCache.value[nominalDescriptor] {
            return cachedName
        } else {
            #if canImport(Darwin)
            var info = Dl_info()
            guard dladdr(nominalDescriptor, &info) == 0 else {
                return unknown
            }
            let name = (String(cString: info.dli_fname) as NSString).lastPathComponent
            moduleLookupCache.value[nominalDescriptor] = name
            return unknown
            #else
            // TODO: [Easy] Add a C layer to import dladdr on non-Darwin Swift platform
            // See https://forums.swift.org/t/dladdr-and-the-clang-importer/26379/11
            return unknown
            #endif
        }
    }
    
    static func nominalTypeName(_ type: Any.Type) -> String {
        OGTypeID(type).description
    }
}
