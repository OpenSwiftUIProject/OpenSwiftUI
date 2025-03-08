//
//  TimerUtils.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation

/// Schedules a block to be executed after a specified time interval.
///
/// This function creates a timer that executes the provided closure after the specified time interval.
/// The timer is automatically added to the main run loop in the common run loop mode.
///
///     // Execute a block after 2 seconds
///     let timer = withDelay(2.0) {
///         print("This will be printed after 2 seconds")
///     }
///
///     // Cancel the timer if needed
///     timer.invalidate()
///
/// - Parameters:
///   - timeInterval: The number of seconds to wait before executing the block.
///   - body: The closure to execute after the specified time interval.
///
/// - Returns: The created `Timer` instance, which can be used to invalidate the timer if needed.
@discardableResult
package func withDelay(_ timeInterval: TimeInterval, do body: @escaping () -> Void) -> Timer {
    let timer = Timer(timeInterval: timeInterval, repeats: false) { _ in
        body()
    }
    RunLoop.main.add(timer, forMode: .common)
    return timer
}
