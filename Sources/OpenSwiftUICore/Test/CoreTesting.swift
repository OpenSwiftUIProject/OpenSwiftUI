//
//  CoreTesting.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - CoreTesting [6.4.41]

package enum CoreTesting {
    package static var isRunning: Bool = false

    package static var needRender: Bool = false

    package static var neeedsRunLoopTurn: Bool {
        false
    }

    package static func pushNeedsRunLoopTurn() {}

    package static func popNeedsRunLoopTurn() {}
}
