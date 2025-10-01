//
//  MainActorUtils.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

extension MainActor {
    @_unavailableFromAsync(message: "await the call to the @MainActor closure directly")
    package static func assumeIsolatedIfLinkedOnOrAfterV6<T>(
        _ operation: @MainActor () throws -> T,
        file: StaticString = #fileID,
        line: UInt = #line
    ) rethrows -> T where T: Sendable {
        if isLinkedOnOrAfter(.v6) {
            return try assumeIsolated(operation, file: file, line: line)
        } else {
            typealias YesActor = @MainActor () throws -> T
            typealias NoActor = () throws -> T

            // To do the unsafe cast, we have to pretend it's @escaping.
            return try withoutActuallyEscaping(operation) { (_ fn: @escaping YesActor) throws -> T in
                let rawFn = unsafeBitCast(fn, to: NoActor.self)
                return try rawFn()
            }
        }
    }
}
