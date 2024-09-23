//
//  Update.swift
//  OpenSwiftUI
//
//  Status: WIP
//  ID: EA173074DA35FA471DC70643259B7E74

internal import COpenSwiftUI
internal import OpenGraphShims
import Foundation

extension MovableLock {
    @inline(__always)
    func withLock<R>(_ body: () throws -> R) rethrows -> R {
        lock()
        defer { unlock() }
        return try body()
    }
}

enum Update {
    static let trackHost: AnyObject = TraceHost()
    static let lock = MovableLock.create()
    private static var depth = 0
    private static var actions: [() -> Void] = []
    
    static func begin() {
        lock.lock()
        depth += 1
        if depth == 1 {
            guard Signpost.viewHost.isEnabled else {
                return
            }
            // TODO: Signpost
        }
    }
    
    static func end() {
        if depth == 1 {
            dispatchActions()
            // TODO: Signpost
        }
        depth -= 1
        lock.unlock()
    }
    
    @inline(__always)
    static func perform<Value>(_ body: () -> Value) -> Value {
        begin()
        defer { end() }
        return body()
    }
    
    static func enqueueAction(_ action: @escaping () -> Void) {
        begin()
        actions.append(action)
        end()
    }
    
    static func ensure<Value>(_ body: () throws -> Value) rethrows -> Value {
        try lock.withLock {
            if depth == 0 {
                begin()
                defer { end() }
                return try body()
            } else {
                return try body()
            }
        }
    }
    
    @inline(__always)
    static func dispatchActions() {
        guard !actions.isEmpty else {
            return
        }

        let actions = Update.actions
        Update.actions = []
        onMainThread {
            // TODO: Signpost.postUpdateActions
            begin()
            for action in actions {
                let oldDepth = depth
                action()
                let newDepth = depth
                if newDepth != oldDepth {
                    fatalError("Action caused unbalanced updates.")
                }
            }
            end()
        }
    }
    
    @inline(__always)
    static func syncMain(_ body: () -> Void) {
        #if os(WASI)
        // FIXME: See #76
        body()
        #else
        if Thread.isMainThread {
            body()
        } else {
            withoutActuallyEscaping(body) { escapableBody in
                MovableLock.syncMain(lock: lock) {
                    #if canImport(Darwin)
                    AnyRuleContext(attribute: AnyOptionalAttribute.current.identifier).update(body: escapableBody)
                    #else
                    fatalError("See #39")
                    #endif
                }
            }
        }
        #endif
    }
}

extension Update {
    private class TraceHost {}
}

// FIXME: migrate to use @_extern(c, "xx") in Swift 6
extension MovableLock {
    @_silgen_name("_MovableLockSyncMain")
    static func syncMain(lock: MovableLock, body: @escaping () -> Void)
}
