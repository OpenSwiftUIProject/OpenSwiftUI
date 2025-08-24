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
        await withKnownIssue(isIntermittent: true) {
            try await confirmation { confirmation in
                var callbackExecuted = false

                let startTime = Date()
                let delayInterval: TimeInterval = 2

                let timer = withDelay(delayInterval) {
                    callbackExecuted = true
                    confirmation()
                }
                #expect(timer.isValid == true)
                #expect(callbackExecuted == false)
                try await Task.sleep(for: .seconds(5))

                #expect(callbackExecuted == true)
                let elapsedTime = Date().timeIntervalSince(startTime)
                #expect(elapsedTime >= delayInterval)
            }
        }
    }
    
    @Test
    func withDelayCanBeCancelled() async throws {
        var callbackExecuted = false
        let timer = withDelay(2) {
            callbackExecuted = true
        }
        #expect(timer.isValid == true)

        timer.invalidate()
        try await Task.sleep(for: .seconds(5))

        #expect(timer.isValid == false)
        #expect(callbackExecuted == false)
    }
    
    @Test
    func withDelayRunsOnMainRunLoop() async throws {
        await withKnownIssue(isIntermittent: true) {
            try await confirmation { confirmation in
                let _ = withDelay(2) {
                    #expect(Thread.isMainThread)
                    confirmation()
                }
                try await Task.sleep(for: .seconds(5))
            }
        }
    }
}

import XCTest
final class TimerUtilsXCTests: XCTestCase {
    func testWithDelayExecutesAfterSpecifiedTime() async throws {
        let expectation = expectation(description: "withDelay body call")
        var callbackExecuted = false

        let startTime = Date()
        let delayInterval: TimeInterval = 2

        let timer = withDelay(delayInterval) {
            callbackExecuted = true
            expectation.fulfill()
        }
        XCTAssertTrue(timer.isValid)
        XCTAssertFalse(callbackExecuted)
        await fulfillment(of: [expectation], timeout: 5)

        XCTAssertTrue(callbackExecuted)
        let elapsedTime = Date().timeIntervalSince(startTime)
        #if !canImport(Darwin)
        // FIXME: The elapsed time is sometimes not correct on non-Darwin platform
        throw XCTSkip("The elapsed time is sometimes not correct on non-Darwin platform")
        #endif
        XCTAssertTrue(elapsedTime >= delayInterval)
    }

    func testWithDelayCanBeCancelled() async throws {
        var callbackExecuted = false
        let timer = withDelay(2) {
            callbackExecuted = true
        }
        XCTAssertTrue(timer.isValid)

        timer.invalidate()
        try await Task.sleep(for: .seconds(5))
        XCTAssertFalse(timer.isValid)
        #if !canImport(Darwin)
        // FIXME: callbackExecuted is sometimes not correct on non-Darwin platform
        throw XCTSkip("callbackExecuted is sometimes not correct on non-Darwin platform")
        #endif
        XCTAssertFalse(callbackExecuted)
    }

    func testWithDelayRunsOnMainRunLoop() async throws {
        let expectation = expectation(description: "withDelay body call")
        let _ = withDelay(2) {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 5)
    }
}
