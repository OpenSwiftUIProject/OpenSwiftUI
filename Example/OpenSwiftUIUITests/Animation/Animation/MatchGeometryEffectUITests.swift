//
//  MatchGeometryEffectUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct MatchGeometryEffectExampleTests {
    @Test
    func axisChange() {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 2, count: 5)
            }
            
            @State private var isVertical = true
            @Namespace private var animation
            
            var body: some View {
                VStack {
                    if isVertical {
                        VStack {
                            Ellipse()
                                .fill(.red)
                                .matchedGeometryEffect(id: "ellipse", in: animation)
                            Rectangle()
                                .fill(.blue)
                                .matchedGeometryEffect(id: "rectangle", in: animation, properties: .size)
                                .transition(.opacity)
                        }
                    } else {
                        HStack {
                            Ellipse()
                                .fill(.red)
                                .matchedGeometryEffect(id: "ellipse", in: animation)
                            Rectangle()
                                .fill(.blue)
                                .matchedGeometryEffect(id: "rectangle", in: animation, properties: .size)
                                .transition(.opacity)
                        }

                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 2)) {
                        isVertical.toggle()
                    }
                }
            }
        }
        // When run seperately, precision: 1.0 works fine
        // but in the full suite, it will hit the same issue of #340
        withKnownIssue("#690", isIntermittent: true) {
            openSwiftUIAssertAnimationSnapshot(
                of: ContentView()
            )
        }
    }
}
