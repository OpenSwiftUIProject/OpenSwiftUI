//
//  MatchedGeometryEffectUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(
    .snapshots(record: .never, diffTool: diffTool)
)
struct MatchedGeometryEffectUITests {
    @Test
    func matchedGeometryEffect() {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 2, count: 4)
            }

            var body: some View {
                MatchedGeometryEffectModifierExample()
            }
        }
        openSwiftUIAssertAnimationSnapshot(
            of: ContentView(),
            precision: 0.8, // FIXME: general animation snapshot issue
            size: CGSize(width: 300, height: 150)
        )
    }

    @Test
    func matchedGeometryEffectWithClipShape() {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 2, count: 4)
            }

            var body: some View {
                MatchedGeometryEffectClipShapeModifierExample()
            }
        }
        withKnownIssue("clipShape rect bug") {
            openSwiftUIAssertAnimationSnapshot(
                of: ContentView(),
                size: CGSize(width: 300, height: 150)
            )
        }
    }
}
