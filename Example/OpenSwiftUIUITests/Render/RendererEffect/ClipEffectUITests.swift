//
//  ClipEffectUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ClipEffectUITests {
    @Test(.disabled("Shape is not implemented correctly"))
    func clipShapeCircle() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test(.disabled("Shape is not implemented correctly"))
    func clipShapeRoundedRectangle() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 100, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test(.disabled("Shape is not implemented correctly"))
    func clipShapeCapsule() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 100, height: 50)
                    .clipShape(Capsule())
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
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

    @Test(.disabled("Shape is not implemented correctly"))
    func clipShapeEllipse() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 100, height: 60)
                    .clipShape(Ellipse())
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}

