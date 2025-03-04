//
//  TimerUtilsTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing
import Foundation

// MARK: - TimerUtilsTests

struct TimerUtilsTests {
    @Test
    func withDelayExecutesAfterSpecifiedTime() async throws {
        try await confirmation { confirmation in
            var callbackExecuted = false

            let startTime = Date()
            let delayInterval: TimeInterval = 0.2

            let timer = withDelay(delayInterval) {
                callbackExecuted = true
                confirmation()
            }
            #expect(timer.isValid == true)
            #expect(callbackExecuted == false)
            try await Task.sleep(for: .seconds(0.3))

            #expect(callbackExecuted == true)
            let elapsedTime = Date().timeIntervalSince(startTime)
            #expect(elapsedTime >= delayInterval)
        }
    }
    
    @Test
    func withDelayCanBeCancelled() async throws {
        var callbackExecuted = false
        let timer = withDelay(0.2) {
            callbackExecuted = true
        }
        #expect(timer.isValid == true)

        timer.invalidate()
        try await Task.sleep(for: .seconds(0.3))

        #expect(timer.isValid == false)
        #expect(callbackExecuted == false)
    }
    
    @Test
    func withDelayRunsOnMainRunLoop() async throws {
        try await confirmation { confirmation in
            let _ = withDelay(0.2) {
                #expect(Thread.isMainThread)
                confirmation()
            }
            try await Task.sleep(for: .seconds(0.3))
        }
    }
}

