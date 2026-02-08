//
//  ClipEffectUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ClipEffectUITests {
    // FIXME: Investigate the diff. perceptualPrecision should be 1.0

    @Test
    func clipShapeCircle() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), perceptualPrecision: 0.9)
    }

    @Test
    func clipShapeRoundedRectangle() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 100, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), perceptualPrecision: 0.9)
    }

    @Test
    func clipShapeCapsule() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 100, height: 50)
                    .clipShape(Capsule())
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), perceptualPrecision: 0.9)
    }

    @Test
    func clipped() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 150, height: 150)
                    .offset(x: 25, y: 25)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .background { Color.red }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func clipShapeEllipse() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 100, height: 60)
                    .clipShape(Ellipse())
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), perceptualPrecision: 0.99)
    }
}

