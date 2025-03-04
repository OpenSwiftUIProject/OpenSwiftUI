//
//  TimerUtils.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation

@discardableResult
package func withDelay(_ timeInterval: TimeInterval, do body: @escaping () -> Void) -> Timer {
    let timer = Timer(timeInterval: timeInterval, repeats: false) { _ in
        body()
    }
    RunLoop.main.add(timer, forMode: .common)
    return timer
}
