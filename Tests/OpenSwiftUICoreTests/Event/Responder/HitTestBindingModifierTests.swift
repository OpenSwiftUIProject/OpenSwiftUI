//
//  HitTestBindingModifierTests.swift
//  OpenSwiftUICoreTests

import Foundation
import Numerics
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@testable
#if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
@_private(sourceFile: "HitTestBindingModifier.swift")
#endif
import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct HitTestBindingModifierTests {
    // MARK: - Point Sampling

    // Select each test mode explicitly; platform defaults disable point clouds on visionOS.

    @Test(arguments: [
        (disablePointCloud: false, expectsHit: true),
        (disablePointCloud: true, expectsHit: false),
    ])
    func pointCloudCanBeDisabled(disablePointCloud: Bool, expectsHit: Bool) {
        withResponders {
            let responder = TestResponder()
            // The center misses, but nearby samples reach the responder.
            responder.contains = { $0.x > 0 }
            let options: ViewResponder.ContainsPointsOptions = disablePointCloud
                ? .disablePointCloudHitTesting
                : []
            let result = responder.hitTest(globalPoint: .zero, radius: 8, options: options)
            #expect(result === (expectsHit ? responder : nil))
        }
    }

    #if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
    @Test(arguments: [
        (radius: 0, expectedCount: 1, outerDistance: 0),
        // The first ring appears only after the radius exceeds the minimum spacing.
        (radius: 4, expectedCount: 1, outerDistance: 0),
        (radius: CGFloat(4).nextUp, expectedCount: 5, outerDistance: 4),
        (radius: 8, expectedCount: 5, outerDistance: 4),
        (radius: -8, expectedCount: 5, outerDistance: 4),
        (radius: 60, expectedCount: 61, outerDistance: 50),
        (radius: 1000, expectedCount: 61, outerDistance: 50),
    ] as [(CGFloat, Int, CGFloat)])
    func pointCloudBounds(radius: CGFloat, expectedCount: Int, outerDistance: CGFloat) throws {
        let center = CGPoint(x: 10, y: 20)
        let (points, _) = hitPoints(point: center, radius: radius)
        try #require(points.count == expectedCount)
        #expect(points[0] == center)
        let maximumDistance = try #require(points.map { hypot($0.x - center.x, $0.y - center.y) }.max())
        #expect(maximumDistance.isApproximatelyEqual(to: outerDistance, absoluteTolerance: 1e-10))
        if radius < 0 {
            let (positiveRadiusPoints, _) = hitPoints(point: center, radius: -radius)
            #expect(points == positiveRadiusPoints)
        }
    }

    @Test
    func weightedHitPoints() throws {
        let center = CGPoint(x: 10, y: 20)
        let (points, weights) = hitPoints(point: center, radius: 60)

        try #require(points.count == 61)
        try #require(weights.count == 61)
        #expect(points[0] == center)
        #expect(weights[0] == 24)
        #expect(weights.reduce(0, +).isApproximatelyEqual(to: 144, absoluteTolerance: 1e-10))

        // The center and each ring contribute weight 24; more samples do not give a ring more influence.
        let rings: [(indices: Range<Int>, distance: CGFloat, weight: Double)] = [
            (1..<5, 10, 6),
            (5..<13, 20, 3),
            (13..<25, 30, 2),
            (25..<41, 40, 1.5),
            (41..<61, 50, 1.2),
        ]
        for ring in rings {
            for index in ring.indices {
                let offset = points[index] - center
                #expect(hypot(offset.width, offset.height).isApproximatelyEqual(to: ring.distance, absoluteTolerance: 1e-10))
                #expect(weights[index].isApproximatelyEqual(to: ring.weight, absoluteTolerance: 1e-10))
            }
            #expect(weights[ring.indices].reduce(0, +).isApproximatelyEqual(to: 24, absoluteTolerance: 1e-10))
            // Ring offsets cancel around the supplied center, including after translation.
            let sumX = points[ring.indices].reduce(0) { $0 + $1.x - center.x }
            let sumY = points[ring.indices].reduce(0) { $0 + $1.y - center.y }
            #expect(sumX.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-10))
            #expect(sumY.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-10))
        }

        // Start on +x and rotate toward +y; distances alone would not detect reversed rotation.
        let firstRing = [
            CGPoint(x: 20, y: 20),
            CGPoint(x: 10, y: 30),
            CGPoint(x: 0, y: 20),
            CGPoint(x: 10, y: 10),
        ]
        for (point, expected) in zip(points[1..<5], firstRing) {
            #expect(point.x.isApproximatelyEqual(to: expected.x, absoluteTolerance: 1e-10))
            #expect(point.y.isApproximatelyEqual(to: expected.y, absoluteTolerance: 1e-10))
        }

        printPointCloud(enabled: false, center: center, points: points, weights: weights, rings: rings)
    }

    #endif

    // MARK: - Hit Testing

    @Test(arguments: [
        (opacity: 0.0009, expectsHit: false),
        (opacity: 0.001, expectsHit: true),
    ])
    func opacityIsCheckedBeforeContainment(opacity: Double, expectsHit: Bool) {
        withResponders {
            let responder = TestResponder()
            var checkedContainment = false
            responder.contains = { _ in
                checkedContainment = true
                return true
            }
            responder.testOpacity = opacity
            // Below the opacity threshold, reject the responder before checking its geometry.
            let result = responder.hitTest(globalPoint: .zero, radius: 0, options: [])
            #expect(result === (expectsHit ? responder : nil))
            #expect(checkedContainment == expectsHit)
        }
    }

    @Test(arguments: [false, true])
    func missingContainmentRejectsHit(disablePointCloud: Bool) {
        withResponders {
            let responder = TestResponder()
            responder.contains = { _ in false }
            let options: ViewResponder.ContainsPointsOptions = disablePointCloud
                ? .disablePointCloudHitTesting
                : []
            #expect(responder.hitTest(globalPoint: .zero, radius: 0, options: options) == nil)
        }
    }

    @Test(arguments: [
        (disablePointCloud: false, frontEnabled: true, selectsFront: true),
        (disablePointCloud: true, frontEnabled: true, selectsFront: false),
        (disablePointCloud: false, frontEnabled: false, selectsFront: false),
        (disablePointCloud: true, frontEnabled: false, selectsFront: false),
    ])
    func frontChildOcclusionDependsOnHitTestMode(disablePointCloud: Bool, frontEnabled: Bool, selectsFront: Bool) {
        withResponders {
            let root = TestResponder()
            let back = TestResponder()
            let front = TestResponder()
            back.priority = 100
            front.enabled = frontEnabled
            root.testChildren = [back, front]
            // Point clouds honor opaque occlusion; single-point tests compare priorities.
            // A disabled front child neither wins nor hides the higher-priority back child.
            let options: ViewResponder.ContainsPointsOptions = disablePointCloud
                ? .disablePointCloudHitTesting
                : []
            let result = root.hitTest(globalPoint: .zero, radius: 0, options: options)
            #expect(result === (selectsFront ? front : back))
        }
    }

    @Test(arguments: [
        (frontPriority: 1.0, parentEnabled: true, selectsFront: false),
        (frontPriority: 1.1, parentEnabled: true, selectsFront: false),
        (frontPriority: 1.2, parentEnabled: true, selectsFront: true),
        (frontPriority: 1.1, parentEnabled: false, selectsFront: false),
    ])
    func translucentChildrenRequireClearWinner(frontPriority: Double, parentEnabled: Bool, selectsFront: Bool) {
        withResponders {
            let root = TestResponder()
            let back = TestResponder()
            let front = TestResponder()
            back.testOpacity = 0.5
            front.testOpacity = 0.5
            front.priority = frontPriority
            root.enabled = parentEnabled
            root.testChildren = [back, front]
            // Neither child occludes the other. Selection needs a 20% lead; otherwise use the parent.
            // If the parent also disallows hits, an ambiguous result has no target.
            let expected: ViewResponder? = selectsFront ? front : (parentEnabled ? root : nil)
            #expect(root.hitTest(globalPoint: .zero, radius: 0, options: []) === expected)
        }
    }

    @Test(arguments: [
        (priority: 0.25, selectsChild: false),
        (priority: 1.0 / 3.0, selectsChild: true),
    ])
    func childMustMeetMinimumScore(priority: Double, selectsChild: Bool) {
        withResponders {
            let root = TestResponder()
            let child = TestResponder()
            child.priority = priority
            root.testChildren = [child]
            // One center sample has weight 24: score 6 falls back to the parent, while score 8 qualifies.
            #expect(root.hitTest(globalPoint: .zero, radius: 0, options: []) === (selectsChild ? child : root))
        }
    }

    @Test
    func parentClipsChildPointCloud() {
        withResponders {
            let root = TestResponder()
            let child = TestResponder()
            root.testChildren = [child]
            root.contains = { $0.x == 0 && $0.y == 0 }
            child.contains = { $0.x > 0 }
            // The child contains nearby samples, but the parent admits only the center point.
            #expect(root.hitTest(globalPoint: .zero, radius: 8, options: []) === root)
        }
    }

    @Test(arguments: [
        (priority: 1.0, selectsFront: true),
        (priority: 0.0, selectsFront: false),
    ])
    func singlePointTiesFavorFrontChild(priority: Double, selectsFront: Bool) {
        withResponders {
            let root = TestResponder()
            let back = TestResponder()
            let front = TestResponder()
            front.priority = priority
            back.priority = priority
            root.testChildren = [back, front]
            // Equal positive priorities favor the front child; zero cannot displace the parent.
            let result = root.hitTest(globalPoint: .zero, radius: 0, options: .disablePointCloudHitTesting)
            #expect(result === (selectsFront ? front : root))
        }
    }

    @Test
    func singlePointRepeatedResponderKeepsFirstPriority() {
        withResponders {
            let root = TestResponder()
            let shared = TestResponder()
            let other = TestResponder()
            var visits = 0
            shared.contains = { [unowned shared] _ in
                visits += 1
                shared.priority = visits == 1 ? 1 : 3
                return true
            }
            other.priority = 2
            root.testChildren = [other, shared, shared]

            // Visit shared (1), shared (3), then other (2). Repeating the same target must retain
            // its first priority, so other still wins despite shared's second, higher result.
            #expect(root.hitTest(globalPoint: .zero, radius: 0, options: .disablePointCloudHitTesting) === other)
            #expect(visits == 2)
        }
    }

    @Test(arguments: [
        // Scores 12 and 13.2 belong to one target, so their small difference is not ambiguity.
        (backPriority: 1.1, includeCompetitor: false),
        // Updating that target from 12 to 24 lets it beat the separate competitor's score 18.
        (backPriority: 2.0, includeCompetitor: true),
    ])
    func pointCloudRepeatedDescendantDoesNotCompeteWithItself(backPriority: Double, includeCompetitor: Bool) {
        withResponders {
            let root = TestResponder()
            let front = TestResponder()
            let back = TestResponder()
            let shared = TestResponder()
            front.testOpacity = 0.5
            back.testOpacity = 0.5
            back.priority = backPriority
            shared.testOpacity = 0.5
            shared.priority = 4
            front.testChildren = [shared]
            back.testChildren = [shared]
            root.testChildren = [back, front]
            if includeCompetitor {
                let other = TestResponder()
                other.testOpacity = 0.5
                other.priority = 1.5
                root.testChildren.insert(other, at: 0)
            }
            #expect(root.hitTest(globalPoint: .zero, radius: 0, options: []) === shared)
        }
    }

    @Test(arguments: [0.5, 1.0])
    func pointCloudRanksDescendantUsingSubtreeScoreAndCoverage(descendantOpacity: Double) {
        withResponders {
            let root = TestResponder()
            let branch = TestResponder()
            let descendant = TestResponder()
            let other = TestResponder()
            branch.testOpacity = 0.5
            descendant.testOpacity = descendantOpacity
            descendant.priority = 4
            other.testOpacity = 0.5
            other.priority = 2
            branch.testChildren = [descendant]
            root.testChildren = [other, branch]

            #expect(branch.hitTest(globalPoint: .zero, radius: 0, options: []) === descendant)
            // Selecting a descendant does not transfer its score or opacity to the branch.
            // The branch still contributes score 12 and no coverage, so the sibling's score 24 wins.
            #expect(root.hitTest(globalPoint: .zero, radius: 0, options: []) === other)
        }
    }

    @Test
    func pointCloudRejectedCandidateStillOccludesBackChild() {
        withResponders {
            let root = TestResponder()
            let front = TestResponder()
            let runnerUp = TestResponder()
            let occluder = TestResponder()
            let back = TestResponder()
            front.testOpacity = 0.5
            front.priority = 2
            runnerUp.testOpacity = 0.5
            occluder.priority = 0.25
            back.priority = 100
            root.testChildren = [back, occluder, runnerUp, front]

            // Visit front (24), runner-up (12), occluder (6), then back.
            // The opaque occluder loses selection but must still block the high-priority back child.
            #expect(root.hitTest(globalPoint: .zero, radius: 0, options: []) === front)
        }
    }

    @Test(arguments: [false, true])
    func nanPriorityDoesNotReplaceCurrentHit(disablePointCloud: Bool) {
        withResponders {
            let root = TestResponder()
            let front = TestResponder()
            let back = TestResponder()
            // Keep the front translucent so point-cloud traversal reaches the NaN candidate.
            front.testOpacity = 0.5
            back.testOpacity = 0.5
            back.priority = .nan
            root.testChildren = [back, front]
            let options: ViewResponder.ContainsPointsOptions = disablePointCloud
                ? .disablePointCloudHitTesting
                : []

            #expect(root.hitTest(globalPoint: .zero, radius: 0, options: options) === front)
        }
    }

    // MARK: - Helpers

    private func withResponders(_ body: () -> Void) {
        // ViewResponder.init reads ViewGraph.current, even when the test has no real view layout.
        let graph = ViewGraph(rootViewType: EmptyView.self)
        graph.globalSubgraph.apply(body)
    }

    #if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
    private func printPointCloud(
        enabled: Bool,
        center: CGPoint,
        points: [CGPoint],
        weights: [Double],
        rings: [(indices: Range<Int>, distance: CGFloat, weight: Double)]
    ) {
        guard enabled else { return }
        let halfWidth = 30
        let halfHeight = 15
        let extent: CGFloat = 60
        var grid = Array(
            repeating: Array(repeating: Character(" "), count: halfWidth * 2 + 1),
            count: halfHeight * 2 + 1
        )
        for row in grid.indices {
            grid[row][halfWidth] = "|"
        }
        for column in grid[halfHeight].indices {
            grid[halfHeight][column] = "-"
        }
        for (ringIndex, ring) in rings.enumerated() {
            for index in ring.indices {
                let offset = points[index] - center
                let column = halfWidth + Int((offset.width / extent * CGFloat(halfWidth)).rounded())
                let row = halfHeight + Int((offset.height / extent * CGFloat(halfHeight)).rounded())
                grid[row][column] = Character(String(ringIndex + 1))
            }
        }
        grid[halfHeight][halfWidth] = "O"
        let legend = rings.enumerated().map { index, ring in
            "\(index + 1): distance=\(ring.distance), samples=\(ring.indices.count), weight=\(ring.weight)"
        }
        print(([
            "hitPoints: center=\(center), radius=60, samples=\(points.count)",
            "Offsets from center: x increases right, y increases down; bounds are -60...60.",
            "O: center, weight=\(weights[0])",
        ] + legend + grid.map { String($0) }).joined(separator: "\n"))
    }
    #endif
}

// Supplies containment and scores independently of view layout; hitTest itself remains the production implementation.
private final class TestResponder: ViewResponder {
    var testOpacity = 1.0
    var enabled = true
    var priority = 1.0
    var testChildren: [ViewResponder] = []
    var contains: (CGPoint) -> Bool = { _ in true }

    override var opacity: Double { testOpacity }
    override var allowsHitTesting: Bool { enabled }
    override var children: [ViewResponder] { testChildren }

    override func containsGlobalPoints(
        _ points: [PlatformPoint],
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> ContainsPointsResult {
        ContainsPointsResult(
            mask: points.mapBool(contains),
            priority: priority,
            children: testChildren
        )
    }
}
