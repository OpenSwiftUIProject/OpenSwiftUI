//
//  ShadowEffectUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ShadowEffectUITests {
    @Test
    func shadowDefault() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 100, height: 100)
                    .shadow(radius: 10)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), drawHierarchyInKeyWindow: true)
    }

    @Test
    func shadowCustomColor() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 100, height: 100)
                    .shadow(color: .red, radius: 10)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), drawHierarchyInKeyWindow: true)
    }

    @Test
    func shadowOffset() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 100, height: 100)
                    .shadow(color: .black, radius: 5, x: 10, y: 10)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), drawHierarchyInKeyWindow: true)
    }
}
