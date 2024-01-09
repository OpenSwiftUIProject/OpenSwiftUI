#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("Unsupported Platform")
#endif

enum EnvironmentHelper {
    @_transparent
    @inline(__always)
    static func value(for key: String) -> Bool {
        key.withCString { string in
            guard let env = getenv(string) else {
                return false
            }
            return atoi(env) != 0
        }        
    }
}
