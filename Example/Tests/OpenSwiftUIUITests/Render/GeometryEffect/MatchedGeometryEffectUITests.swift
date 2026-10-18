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
                MatchedGeometryEffectModifierExample(initialToggle: true)
            }
        }
        openSwiftUIAssertAnimationSnapshot(
            of: ContentView(),
            precision: 0.98, // FIXME: Text and button rendering differ in the middle frame
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
                MatchedGeometryEffectClipShapeModifierExample(initialToggle: true)
            }
        }
        openSwiftUIAssertAnimationSnapshot(
            of: ContentView(),
            precision: 0.98, // FIXME: Text and button rendering differ in the middle frame
            size: CGSize(width: 300, height: 150)
        )
    }
}
