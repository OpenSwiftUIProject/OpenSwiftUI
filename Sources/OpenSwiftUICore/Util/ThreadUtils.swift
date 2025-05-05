//
//  ThreadUtils.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 82B2D47816BC992595021D60C278AFF0 (SwiftUICore)

import Foundation

// MARK: - ThreadSpecific

final package class ThreadSpecific<T> {
    private var key: pthread_key_t
    let defaultValue: T
    
    package init(_ defaultValue: T) {
        key = 0
        self.defaultValue = defaultValue
        pthread_key_create(&key) { pointer in
            #if !canImport(Darwin)
            guard let pointer else { return }
            #endif
            pointer.withMemoryRebound(to: Any.self, capacity: 1) { ptr in
                ptr.deinitialize(count: 1)
                ptr.deallocate()
            }
        }
    }

    deinit {
        preconditionFailure("\(Self.self).deinit is unsafe and would leak", file: #file, line: #line)
    }
    
    private final var box: UnsafeMutablePointer<Any> {
        let pointer = pthread_getspecific(key)
        if let pointer {
            return pointer.assumingMemoryBound(to: Any.self)
        } else {
            let box = UnsafeMutablePointer<Any>.allocate(capacity: 1)
            pthread_setspecific(key, box)
            box.initialize(to: defaultValue)
            return box
        }
    }
    
    final package var value: T {
        get {
            box.pointee as! T
        }
        set {
            box.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee = newValue }
        }
    }
}

// MARK: - Thread + Global helper function

package func onMainThread(do body: @escaping () -> Void) {
    #if os(WASI)
    // See #76: Thread and RunLoopMode.common is not available on WASI currently
    body()
    #else
    if Thread.isMainThread {
        body()
    } else {
        RunLoop.main.perform(inModes: [.common]) {
            // Workaround the @Senable warning
            body()
        }
    }
    #endif
}

package func mainThreadPrecondition() {
    #if !os(WASI)
    precondition(Thread.isMainThread, "calling into OpenSwiftUI on a non-main thread is not supported")
    #endif
}

// MARK: - AtomicBuffer

// FIXME:
// Replace with Swift's Mutex and Atomic to simplify cross-platform maintain cost
// https://github.com/swiftlang/swift-evolution/blob/main/proposals/0433-mutex.md
// https://github.com/swiftlang/swift-evolution/blob/main/proposals/0410-atomics.md
#if canImport(Darwin)
private final class AtomicBuffer<Value>: ManagedBuffer<os_unfair_lock_s, Value> {
    static func allocate(value: Value) -> AtomicBuffer<Value> {
        let buffer = AtomicBuffer.create(minimumCapacity: 1) { buffer in
            os_unfair_lock_s()
        }
        buffer.withUnsafeMutablePointerToElements { pointer in
            pointer.initialize(to: value)
        }
        return unsafeDowncast(buffer, to: AtomicBuffer<Value>.self)
    }

    deinit {
        withUnsafeMutablePointerToElements { pointer in
            _ = pointer.deinitialize(count: 1)
        }
    }
}
#else
private final class AtomicBuffer<Value>: ManagedBuffer<NSLock, Value> {
    static func allocate(value: Value) -> AtomicBuffer<Value> {
        let buffer = AtomicBuffer.create(minimumCapacity: 1) { buffer in
            NSLock()
        }
        buffer.withUnsafeMutablePointerToElements { pointer in
            pointer.initialize(to: value)
        }
        return unsafeDowncast(buffer, to: AtomicBuffer<Value>.self)
    }

    deinit {
        withUnsafeMutablePointerToElements { pointer in
            _ = pointer.deinitialize(count: 1)
        }
    }
}
#endif

// MARK: - AtomicBox

@propertyWrapper
package struct AtomicBox<Value> {
    private let buffer: AtomicBuffer<Value>
    
    package init(wrappedValue: Value) {
        buffer = AtomicBuffer.allocate(value: wrappedValue)
    }
    
    @inline(__always)
    package var wrappedValue: Value {
        get {
            #if canImport(Darwin)
            buffer.withUnsafeMutablePointerToHeader { os_unfair_lock_lock($0) }
            defer { buffer.withUnsafeMutablePointerToHeader { os_unfair_lock_unlock($0) } }
            #else
            buffer.withUnsafeMutablePointerToHeader { $0.pointee.lock() }
            defer { buffer.withUnsafeMutablePointerToHeader { $0.pointee.unlock() } }
            #endif
            return buffer.withUnsafeMutablePointerToElements { $0.pointee }
        }
        nonmutating _modify {
            #if canImport(Darwin)
            buffer.withUnsafeMutablePointerToHeader { os_unfair_lock_lock($0) }
            defer { buffer.withUnsafeMutablePointerToHeader { os_unfair_lock_unlock($0) } }
            #else
            buffer.withUnsafeMutablePointerToHeader { $0.pointee.lock() }
            defer { buffer.withUnsafeMutablePointerToHeader { $0.pointee.unlock() } }
            #endif
            yield &buffer.withUnsafeMutablePointerToElements { $0 }.pointee
        }
    }

    @inline(__always)
    package func access<T>(_ body: (inout Value) throws -> T) rethrows -> T {
        try body(&wrappedValue)
    }
    
    package var projectedValue: AtomicBox<Value> { self }
}

extension AtomicBox: @unchecked Sendable where Value: Sendable {}

extension AtomicBox where Value: ExpressibleByNilLiteral {
    package init() {
        self.init(wrappedValue: nil)
    }
}
