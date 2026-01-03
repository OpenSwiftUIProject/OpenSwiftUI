//
//  Update.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: EA173074DA35FA471DC70643259B7E74 (SwiftUI)
//  ID: 61534957AEEC2EDC447ABDC13B4D426F (SwiftUICore)

import OpenSwiftUI_SPI
import OpenAttributeGraphShims
import Foundation

package enum Update {
    private final class TraceHost {}
    static let trackHost: AnyObject = TraceHost()

    private static var depth = 0
    private static var dispatchDepth = 0
    private static let _lock = MovableLock.create()
    private static var actions: [() -> Void] = []
    private static let lockAssertionsAreEnabled = EnvironmentHelper.bool(for: "OPENSWIFTUI_ASSERT_LOCKS")
    
    @inlinable
    package static var isActive: Bool {
        depth != 0
    }

    // Audited [6.5.4]
    @inlinable
    package static var threadIsUpdating: Bool {
        depth > dispatchDepth ? isOwner : false
    }
    
    @inlinable
    package static func assertIsActive() {
        assert(isActive)
    }
    
    package static func lock() {
        _lock.lock()
    }
    package static func unlock() {
        _lock.unlock()
    }
    
    package static var isOwner: Bool {
        _lock.isOwner
    }
    
    package static func wait() {
        _lock.wait()
    }
    
    package static func broadcast() {
        _lock.broadcast()
    }
    
    package static func assertIsLocked() {
        guard lockAssertionsAreEnabled else {
            return
        }
        precondition(
            isOwner,
            "OpenSwiftUI is active without having taken its own lock - missing Update.ensure()?"
        )
    }
    
    package static func begin() {
        lock()
        depth += 1
        if depth == 1 {
            #if canImport(Darwin)
            Signpost.viewHost.traceEvent(
                type: .begin,
                object: trackHost,
                "ViewHost: (%p) update began PlatformHost [ %p ]",
                [
                    0,
                    UInt(bitPattern: Unmanaged.passUnretained(trackHost).toOpaque()),
                ]
            )
            #endif
        }
    }
    
    package static func end() {
        if depth == 1 {
            dispatchActions()
            #if canImport(Darwin)
            Signpost.viewHost.traceEvent(
                type: .end,
                object: trackHost,
                "ViewHost: (%p) update ended PlatformHost [ %p ]",
                [
                    0,
                    UInt(bitPattern: Unmanaged.passUnretained(trackHost).toOpaque()),
                ]
            )
            #endif
        }
        depth -= 1
        unlock()
    }

    @inlinable
    @inline(__always)
    package static func perform<T>(_ body: () throws -> T) rethrows -> T {
        begin()
        defer { end() }
        return try body()
    }

    package static func enqueueAction(_ action: @escaping () -> Void) {
        begin()
        actions.append(action)
        end()
    }

    @discardableResult
    package static func enqueueAction(
        reason: ()?, // FIXME
        _ action: @escaping () -> Void
    ) -> UInt32 {
        enqueueAction(action)
        return .zero
    }

    @inlinable
    @inline(__always)
    package static func locked<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }

    // 6.5.4
    package static func syncMain(_ body: () -> Void) {
        #if os(WASI)
        // FIXME: See #76
        body()
        #else
        if Thread.isMainThread {
            body()
        } else {
            withoutActuallyEscaping(body) { escapableBody in
                struct Context {
                    let body: () -> Void
                    let subgraph: Subgraph?
                    let context: AnyRuleContext
                }
                withUnsafePointer(
                    to: Context(
                        body: escapableBody,
                        subgraph: Subgraph.current,
                        context: AnyRuleContext(attribute: AnyOptionalAttribute.current.identifier)
                    )
                ) { context in
                    _lock.syncMain(.init(context)) { pointer in
                        let pointer = pointer.assumingMemoryBound(to: Context.self).self
                        let current = Subgraph.current
                        defer { Subgraph.current = current }
                        Subgraph.current = pointer.pointee.subgraph
                        pointer.pointee.context.update(body: pointer.pointee.body)
                    }
                }
            }
        }
        #endif
    }
    
    package static func ensure<T>(_ callback: () throws -> T) rethrows -> T {
        try locked {
            begin()
            defer { end() }
            return try callback()
        }
    }
    
    package static var canDispatch: Bool {
        assertIsLocked()
        guard depth == 1 else {
            return false
        }
        return !actions.isEmpty
    }
    
    package static func dispatchActions() {
        guard canDispatch else { return }
        repeat {
            let actions = Update.actions
            Update.actions = []
            onMainThread {
                Signpost.postUpdateActions.traceInterval(object: trackHost, nil) {
                    begin()
                    let oldDispatchDepth = dispatchDepth
                    let oldDepth = depth
                    dispatchDepth = oldDepth
                    defer {
                        dispatchDepth = oldDispatchDepth
                        end()
                    }
                    for action in actions {
                        action()
                        precondition(
                            depth == oldDepth,
                            "Action caused unbalanced updates."
                        )
                    }
                }
            }
        } while !Update.actions.isEmpty
    }
    
    package static func dispatchImmediately<T>(_ body: () -> T) -> T {
        begin()
        let oldDispatchDepth = dispatchDepth
        dispatchDepth = depth
        defer {
            dispatchDepth = oldDispatchDepth
            end()
        }
        return body()
    }
}
