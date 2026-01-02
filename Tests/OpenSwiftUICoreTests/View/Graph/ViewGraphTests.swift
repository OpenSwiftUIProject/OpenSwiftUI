//
//  ViewGraphTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import OpenSwiftUI_SPI
import Testing

struct ViewGraphTests {
    struct NextUpdateTests {
        typealias Update = ViewGraph.NextUpdate

        @Test(arguments: [
            (0.0, Double.zero, Set<UInt32>()),
            (159.0, Double.zero, Set<UInt32>()),
            (160.0, 1 / 80.0, [0x27_0000]),
            (319.0, 1 / 80.0, [0x27_0000]),
            (320.0, 1 / 120.0, [0x27_0000]),
            (1000.0, 1 / 120.0, [0x27_0000]),
        ] as [(Double, Double, Set<UInt32>)])
        func maxVelocity(velocity: Double, expectedInterval: Double, expectedReasons: Set<UInt32>) {
            var update = Update()
            update.maxVelocity(velocity)
            #expect(update.interval == expectedInterval)
            #expect(update.reasons == expectedReasons)
        }

        @Test(arguments: [
            (0.05, nil, 0.05, Set<UInt32>()),
            (0.025, nil, 0.025, Set<UInt32>()),
            (0.025, 1 as UInt32?, 0.025, [1] as Set<UInt32>),
            (0.0, nil, Double.zero, Set<UInt32>()),
        ] as [(Double, UInt32?, Double, Set<UInt32>)])
        func intervalWithReason(interval: Double, reason: UInt32?, expectedInterval: Double, expectedReasons: Set<UInt32>) {
            var update = Update()
            update.interval(interval, reason: reason)
            #expect(update.interval == expectedInterval)
            #expect(update.reasons == expectedReasons)
        }
    }
}
