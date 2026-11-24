//
//  RunLoopUtils.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: 904CE3B9A8258172D2E69C7BF94D1428 (SwiftUICore)

package import Foundation

#if !canImport(ObjectiveC) && !os(WASI)
package import CoreFoundation
#endif

#if !canImport(ObjectiveC)
/// A compactible implementation for the autoreleasepool API
@inlinable
package func autoreleasepool<Result>(invoking body: () throws -> Result) rethrows -> Result {
    try body()
}

#if !os(WASI)
extension CFRunLoopMode {
    package static let defaultMode: CFRunLoopMode! = kCFRunLoopDefaultMode
    package static let commonModes: CFRunLoopMode! = kCFRunLoopCommonModes
}
#endif
#endif

package func onNextMainRunLoop(do body: @escaping () -> Void) {
    #if os(WASI)
    body()
    #else
    RunLoop.main.perform(inModes: [.common], block: body)
    #endif
}

private var observerActions: [() -> Void] = []

#if os(WASI)
extension RunLoop {
    package static func addObserver(_ action: @escaping () -> Void) {
        observerActions.append(action)
    }

    package static func flushObservers() {
        while !observerActions.isEmpty {
            let actions = observerActions
            observerActions = []
            Update.begin()
            for action in actions {
                action()
            }
            Update.end()
        }
    }

    package static func runAllowingEarlyExit(until deadline: Date, stopCondition: () -> Bool) {
        // A browser event loop cannot be synchronously pumped. Callers may
        // still observe an already-satisfied stop condition.
        _ = deadline
        _ = stopCondition()
    }

    package static func runAllowingEarlyExit(until deadline: Date) {
        runAllowingEarlyExit(until: deadline) { false }
    }
}
#else
private var observer: CFRunLoopObserver?

extension RunLoop {
    package static func addObserver(_ action: @escaping () -> Void) {
        let currentRunloop = CFRunLoopGetCurrent()
        if observer == nil {
            observer = CFRunLoopObserverCreate(
                kCFAllocatorDefault,
                CFRunLoopActivity([.beforeWaiting, .exit]).rawValue,
                true,
                0,
                { _, _, _ in
                    autoreleasepool {
                        RunLoop.flushObservers()
                    }
                },
                nil
            )
            CFRunLoopAddObserver(currentRunloop, observer, .commonModes)
        }
        let currentMode = CFRunLoopCopyCurrentMode(currentRunloop)
        if let currentMode {
            if !CFRunLoopContainsObserver(currentRunloop, observer, currentMode) {
                CFRunLoopAddObserver(currentRunloop, observer, currentMode)
            }
        }
        observerActions.append(action)
    }

    package static func flushObservers() {
        while !observerActions.isEmpty {
            let actions = observerActions
            observerActions = []
            Update.begin()
            for action in actions {
                action()
            }
            Update.end()
        }
    }

    package static func runAllowingEarlyExit(until deadline: Date, stopCondition: () -> Bool) {
        repeat {
            let diff = deadline.timeIntervalSinceReferenceDate - CFAbsoluteTimeGetCurrent()
            guard diff > 0 else {
                return
            }
            let result = autoreleasepool {
                CFRunLoopRunInMode(.defaultMode, diff, true)
            }
            guard result == .handledSource, !stopCondition() else {
                return
            }
        } while true
    }

    package static func runAllowingEarlyExit(until deadline: Date) {
        runAllowingEarlyExit(until: deadline) { false }
    }
}
#endif
