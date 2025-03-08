//
//  RunLoopUtils.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 904CE3B9A8258172D2E69C7BF94D1428 (SwiftUICore)

package import Foundation

#if !canImport(ObjectiveC)
package import CoreFoundation

/// A compactible implementation for the autoreleasepool API
@inlinable
package func autoreleasepool<Result>(invoking body: () throws -> Result) rethrows -> Result {
    try body()
}

extension CFRunLoopMode {
    package static let defaultMode: CFRunLoopMode! = kCFRunLoopDefaultMode
    package static let commonModes: CFRunLoopMode! = kCFRunLoopCommonModes
}
#endif

package func onNextMainRunLoop(do body: @escaping () -> Void) {
    RunLoop.main.perform(inModes: [.common], block: body)
}

private var observer: CFRunLoopObserver?
private var observerActions: [() -> Void] = []

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
        while(!observerActions.isEmpty) {
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
