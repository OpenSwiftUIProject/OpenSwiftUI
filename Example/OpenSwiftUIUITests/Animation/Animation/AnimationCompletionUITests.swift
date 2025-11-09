//
//  AnimationCompletionUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct AnimationCompletionUITests {
    @Test
    func logicalAndRemovedComplete() {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 3, count: 3)
            }

            @State private var opacity = 1.0
            @State private var scale = 1.0

            @State private var showGreen = false
            @State private var showBlue = false

            var body: some View {
                ZStack {
                    Color.red
                        .frame(width: 100 * scale, height: 100 * scale)
                        .opacity(opacity)
                    if showGreen { Color.green.frame(width: 20, height: 20) }
                    if showBlue { Color.blue.frame(width: 10, height: 10) }
                }
                .onAppear {
                    let animation = Animation.linear(duration: 2)
                        .logicallyComplete(after: 1)
                    withAnimation(animation, completionCriteria: .logicallyComplete) {
                        opacity = 0.1
                    } completion: {
                        showGreen.toggle()
                    }
                    withAnimation(animation, completionCriteria: .removed) {
                        scale = 0.1
                    } completion: {
                        showBlue.toggle()
                    }
                }
            }
        }
        openSwiftUIAssertAnimationSnapshot(
            of: ContentView()
        )
    }
}
