//
//  MatchedGeometryEffectUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(
    .disabled(if: attributeGraphVendor == .compute, "Temporarily disabled for IAG snapshot crash"),
    .snapshots(record: .never, diffTool: diffTool)
)
struct MatchedGeometryEffectUITests {
    // FIXME: Check SharedFrame impl or DL
    @Test(.disabled("MatchedGeometryEffect effect does not match the animation"))
    func matchedGeometryEffect() {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 3, count: 6)
            }

            var body: some View {
                MatchedGeometryEffectModifierExample()
            }
        }
        openSwiftUIAssertAnimationSnapshot(
            of: ContentView(),
            size: CGSize(width: 300, height: 150)
        )
    }

    // FIXME: Check SharedFrame impl or DL
    @Test(.disabled("MatchedGeometryEffect effect does not match the animation"))
    func matchedGeometryEffectWithClipShape() {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 3, count: 6)
            }

            var body: some View {
                MatchedGeometryEffectClipShapeModifierExample()
            }
        }
        openSwiftUIAssertAnimationSnapshot(
            of: ContentView(),
            size: CGSize(width: 300, height: 150)
        )
    }
}
