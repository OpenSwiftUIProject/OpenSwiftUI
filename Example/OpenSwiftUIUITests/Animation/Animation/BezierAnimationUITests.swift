//
//  BezierAnimationUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct BezierAnimationUITests {
    @Test
    func colorRow() {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 2, count: 5)
            }

            @State private var animate = false
            private var animationDuration: Double { Self.model.duration }

            var body: some View {
                VStack(spacing: 10) {
                    AnimationRow(
                        color: .blue,
                        animate: animate,
                        animation: .linear(duration: animationDuration)
                    )
                    AnimationRow(
                        color: .green,
                        animate: animate,
                        animation: .easeIn(duration: animationDuration)
                    )
                    AnimationRow(
                        color: .red,
                        animate: animate,
                        animation: .easeOut(duration: animationDuration)
                    )
                    AnimationRow(
                        color: .orange,
                        animate: animate,
                        animation: .easeInOut(duration: animationDuration)
                    )
                    AnimationRow(
                        color: .purple,
                        animate: animate,
                        animation: .timingCurve(0.68, -0.6, 0.32, 1.6, duration: animationDuration)
                    )
                }
                .padding()
                .frame(width: 200, height: 200)
                .onAppear {
                    animate.toggle()
                }
            }
            struct AnimationRow: View {
                let color: Color
                let animate: Bool
                let animation: Animation

                private let squareSize: CGFloat = 20.0

                var body: some View {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Color.black.opacity(0.1)
                            color
                            // TODO: Color interpolation not aligned yet
                            // Color(animate ? color : .gray)
                                .frame(width: squareSize, height: squareSize)
                                .offset(x: animate ? geometry.size.width - squareSize : 0)
                        }
                    }
                    .frame(height: squareSize)
                    .animation(animation, value: animate)
                }
            }
        }
        // When run separately, precision: 1.0 works fine
        // but in the full suite, it will hit the same issue of #340
        withKnownIssue("#690", isIntermittent: true) {
            openSwiftUIAssertAnimationSnapshot(
                of: ContentView(),
            )
        }
    }
}
