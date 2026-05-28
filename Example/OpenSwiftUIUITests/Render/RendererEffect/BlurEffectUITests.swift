//
//  BlurEffectUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct BlurEffectUITests {
    @Test
    func blurColor() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 100, height: 100)
                    .blur(radius: 10)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), drawHierarchyInKeyWindow: true)
    }

    @Test
    func blurImage() {
        struct ContentView: View {
            var body: some View {
                Image(decorative: "logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .blur(radius: 10)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), drawHierarchyInKeyWindow: true)
    }
}
