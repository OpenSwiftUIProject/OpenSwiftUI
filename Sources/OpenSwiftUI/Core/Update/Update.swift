//
//  Update.swift
//  OpenSwiftUI
//
//  Status: WIP
//  ID: EA173074DA35FA471DC70643259B7E74

internal import COpenSwiftUI
internal import OpenGraphShims

extension MovableLock {
    @inline(__always)
    func withLock<R>(_ body: () -> R) -> R {
        lock()
        defer { unlock() }
        return body()
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
    
    static func enqueueAction(_ action: @escaping () -> Void) {
        begin()
        actions.append(action)
        end()
    }
    
    static func ensure<Value>(_ body: () -> Value) throws -> Value {
        lock.withLock {
            if depth == 0 {
                begin()
            }
            defer {
                if depth == 0 {
                    end()
                }
            }
            return body()
        }
    }
    
    @inline(__always)
    static func dispatchActions() {
        // FIXME
        for action in actions {
            action()
        }
    }
    
    @inline(__always)
    static func syncMain(_ body: () -> Void) {
        // TODO
        fatalError("TODO")
    }
}

extension Update {
    private class TraceHost {}
}
