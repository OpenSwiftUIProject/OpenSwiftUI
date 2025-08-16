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
import OpenGraphShims

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

package enum ProcessEnvironment {
    package static func bool(forKey key: String, defaultValue: Bool = false) -> Bool {
        guard let env = getenv(key) else {
            return defaultValue
        }
        return atoi(env) != 0
    }

    static func uint32(forKey key: String, defaultValue: UInt32 = 0) -> UInt32 {
        guard let env = getenv(key) else {
            return defaultValue
        }
        return UInt32(atoi(env))
    }

    static let tracingOptions: Graph.TraceOptions = .init(rawValue: uint32(forKey: "OPENSWIFTUI_TRACE"))
}
