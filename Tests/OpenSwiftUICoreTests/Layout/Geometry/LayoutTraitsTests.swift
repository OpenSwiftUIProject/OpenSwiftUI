//
//  LayoutTraitsTests.swift
//  OpenSwiftUICoreTests

import Numerics
import Testing
@testable
import OpenSwiftUICore
import Foundation

struct LayoutTraitsTests {
    struct FlexibilityEstimateTests {
        typealias FlexibilityEstimate = _LayoutTraits.FlexibilityEstimate

        @Test
        func initialize() {
            let estimate = FlexibilityEstimate(minLength: 10, maxLength: 20)
            #expect(estimate.minLength.isApproximatelyEqual(to: 10))
            #expect(estimate.maxLength.isApproximatelyEqual(to: 20))
        }

        @Test(arguments: [
            // Test regular cases
            (
                FlexibilityEstimate(minLength: 10, maxLength: 20),
                FlexibilityEstimate(minLength: 10, maxLength: 30),
                true, false, false
            ),
            // Test equal differences but different minimums
            (
                FlexibilityEstimate(minLength: 20, maxLength: 40),
                FlexibilityEstimate(minLength: 30, maxLength: 50),
                false, false, false
            ),
            // Test infinity cases
            (
                FlexibilityEstimate(minLength: 10, maxLength: .infinity),
                FlexibilityEstimate(minLength: 20, maxLength: .infinity),
                false, false, true
            ),
            // Test finite vs infinite
            (
                FlexibilityEstimate(minLength: 10, maxLength: 20),
                FlexibilityEstimate(minLength: 10, maxLength: .infinity),
                true, false, false
            )
        ])
        func comparison(
            _ estimate1: FlexibilityEstimate, _ estimate2: FlexibilityEstimate,
            expectedLessThan: Bool, expectedEqual: Bool, expectedGreatThan: Bool
        ) {
            #expect((estimate1 < estimate2) == expectedLessThan)
            #expect((estimate1 == estimate2) == expectedEqual)
            #expect((estimate1 > estimate2) == expectedGreatThan)
        }

        @Test
        func equality() {
            let estimate1 = FlexibilityEstimate(minLength: 10, maxLength: 20)
            let estimate2 = FlexibilityEstimate(minLength: 10, maxLength: 20)
            let estimate3 = FlexibilityEstimate(minLength: 10, maxLength: 30)

            #expect(estimate1 == estimate2)
            #expect(estimate1 != estimate3)

            // Test equality with infinity
            let infiniteEstimate1 = FlexibilityEstimate(minLength: 10, maxLength: .infinity)
            let infiniteEstimate2 = FlexibilityEstimate(minLength: 10, maxLength: .infinity)
            #expect(infiniteEstimate1 == infiniteEstimate2)
        }
    }

    struct DimensionTests {
        typealias Dimension = _LayoutTraits.Dimension

        @Test(arguments: [
            (1.0, 2.0, 3.0, false),
            (0.0, 2.0, 3.0, false),
            (-0.1, 2.0, 3.0, true),
            (-CGFloat.infinity, 2.0, 3.0, true),
            (CGFloat.infinity, 2.0, 3.0, true),
            (CGFloat.nan, 2.0, 3.0, true),
            (1.0, .infinity, 3.0, true),
            (1.0, 4.0, 3.0, true),
            (1.0, 2.0, 1.5, true),
        ])
        func exitTest(_ min: CGFloat, _ ideal: CGFloat, _ max: CGFloat, _ expectedFailure: Bool) {
            let block = {
                _ = Dimension(min: min, ideal: ideal, max: max)
                var d = Dimension.fixed(.zero)
                d.max = ideal
                d.ideal = ideal
                d.min = min
            }
            if expectedFailure {
                withKnownIssue {
                    Issue.record("Skip since swift-testing does not support exit test yet")
                    // FIXME: Comment the crash case temporary since exit test is not supported on swift-testing so far.
                    // Blocked by #expect(exist:)
                    // block()
                }
            } else {
                block()
            }
        }

        @Test(arguments: [
            (Dimension.fixed(1.0), "1.0"),
            (Dimension(min: 1.0, ideal: 2.0, max: 4.0), "1.0...2.0...4.0"),
        ])
        func description(_ d: Dimension, expectedDescription: String) {
            #expect(d.description == expectedDescription)
        }
    }
}
