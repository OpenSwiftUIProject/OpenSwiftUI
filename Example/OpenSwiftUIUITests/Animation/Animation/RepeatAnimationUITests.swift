//
//  RepeatAnimationUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct RepeatAnimationUITests {
    @Test(arguments: [true, false])
    func frameAnimation(autoreverses: Bool) {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 2, count: 4)
            }

            let autoreverses: Bool

            @State private var smaller = false

            var body: some View {
                Color.red
                    .frame(width: smaller ? 50 : 100, height: smaller ? 50 : 100)
                    .animation(
                        .linear(duration: Self.model.duration / 2).repeatCount(2, autoreverses: autoreverses),
                        value: smaller
                    )
                    .onAppear {
                        smaller.toggle()
                    }
            }
        }
        openSwiftUIAssertAnimationSnapshot(
            of: ContentView(autoreverses: autoreverses),
            precision: 0.995,
            perceptualPrecision: 0.995,
            testName: #function + "\(autoreverses)"
        )
    }
}
