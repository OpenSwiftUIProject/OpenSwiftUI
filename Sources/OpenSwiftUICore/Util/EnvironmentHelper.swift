//
//  EnvironmentHelper.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(WASI)
import WASILibc
#else
#error("Unsupported Platform")
#endif

package enum EnvironmentHelper {
    @_transparent
    package static func int32(for key: String) -> Int32? {
        key.withCString { string in
            guard let env = getenv(string) else {
                return nil
            }
            return atoi(env)
        }
    }
    
    @_transparent
    package static func bool(for key: String) -> Bool {
        guard let value = int32(for: key) else {
            return false
        }
        return value != 0
    }
}
