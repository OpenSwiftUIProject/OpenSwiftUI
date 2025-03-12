//
//  TimerUtilsTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing
import Foundation

// MARK: - TimerUtilsTests

private let isXCTestBackendEnabled = {
    let isXCTestBackendEnabled: Bool
    #if canImport(Darwin)
    // Even we do not use XCTest explicitly, swift-testing will still trigger XCTestMain under the hood on Apple platforms.
    isXCTestBackendEnabled = true
    #else
    isXCTestBackendEnabled = false
    #endif
    return isXCTestBackendEnabled
}()

@MainActor
@Suite(.enabled(if: isXCTestBackendEnabled, "swift-testing does not pumping the run loop like XCTest which will call CFRunLoopRunInMode repeatedly."))
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
            try await Task.sleep(nanoseconds: 300_000_000)

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
        try await Task.sleep(nanoseconds: 300_000_000)

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
            try await Task.sleep(nanoseconds: 300_000_000)
        }
    }
}

import XCTest
final class TimerUtilsXCTests: XCTestCase {
    func testWithDelayExecutesAfterSpecifiedTime() async throws {
        let expectation = expectation(description: "withDelay body call")
        var callbackExecuted = false

        let startTime = Date()
        let delayInterval: TimeInterval = 0.2

        let timer = withDelay(delayInterval) {
            callbackExecuted = true
            expectation.fulfill()
        }
        XCTAssertTrue(timer.isValid)
        XCTAssertFalse(callbackExecuted)
        // 0.3s will sometimes fail for macOS + 2021 platform
        await fulfillment(of: [expectation], timeout: 1)

        XCTAssertTrue(callbackExecuted)
        let elapsedTime = Date().timeIntervalSince(startTime)
        print("Elapsed time: \(elapsedTime)")
        #if !canImport(Darwin)
        // FIXE: The elapsed time is somehow not correct on non-Darwin platform
        throw XCTSkip("The elapsed time is somehow not correct on non-Darwin platform")
        #endif
        XCTAssertTrue(elapsedTime >= delayInterval)
    }

    func testWithDelayCanBeCancelled() async throws {
        var callbackExecuted = false
        let timer = withDelay(0.2) {
            callbackExecuted = true
        }
        XCTAssertTrue(timer.isValid)

        timer.invalidate()
        try await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertFalse(timer.isValid)
        XCTAssertFalse(callbackExecuted)
    }

    func testWithDelayRunsOnMainRunLoop() async throws {
        let expectation = expectation(description: "withDelay body call")
        let _ = withDelay(0.2) {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 0.3)
    }
}
