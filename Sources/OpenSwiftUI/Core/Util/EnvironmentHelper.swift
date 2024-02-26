#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(WASI)
import WASILibc
#else
#error("Unsupported Platform")
#endif

enum EnvironmentHelper {
    @_transparent
    @inline(__always)
    static func value(for key: String) -> Int32 {
        key.withCString { string in
            guard let env = getenv(string) else {
                return 0
            }
            return atoi(env)
        }        
    }
}
