//
//  MainActorUtils.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation

extension MainActor {
    @_unavailableFromAsync(message: "await the call to the @MainActor closure directly")
    package static func assumeIsolatedIfLinkedOnOrAfter<T>(
        _ semantics: Semantics,
        context: String? = nil,
        _ operation: @MainActor () throws -> T,
        file: StaticString = #fileID,
        line: UInt = #line
    ) rethrows -> T where T: Sendable {
        if isLinkedOnOrAfter(semantics) {
            return try assumeIsolated(operation, file: file, line: line)
        } else {
            let context = context.map { "\($0) " } ?? ""
            if !Thread.isMainThread {
                Log.runtimeIssues(
                    "%s This warning will become a runtime crash in a future version of OpenSwiftUI.",
                    [context]
                )
            }
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
