//
//  GraphHostTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUI
import Testing

struct GraphHostTests {
    @Test
    func setTimeTest() {
        #if canImport(Darwin)
        let graphHost = GraphHost(data: .init())
        #expect(graphHost.data.time.seconds == 0.0)

        graphHost.setTime(Time.zero)
        #expect(graphHost.data.time.seconds == 0.0)

        graphHost.setTime(Time.infinity)
        #expect(graphHost.data.time.seconds == Time.infinity.seconds)
        
        let timeNow = Time.now
        graphHost.setTime(timeNow)
        #expect(graphHost.data.time.seconds == timeNow.seconds)
        #endif
    }
}

