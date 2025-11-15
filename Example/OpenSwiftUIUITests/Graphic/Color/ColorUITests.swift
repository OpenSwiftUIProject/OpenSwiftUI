//
//  ColorUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ColorUITests {
    @Test(
        arguments: [
            (Color(red: 1.0, green: 0.0, blue: 0.0), "red"),
            (Color(red: 0.0, green: 1.0, blue: 0.0), "green"),
            (Color(red: 0.0, green: 0.0, blue: 1.0), "blue"),
            (Color(red: 1.0, green: 1.0, blue: 0.0), "yellow"),
            (Color(red: 1.0, green: 0.0, blue: 1.0), "magenta"),
            (Color(red: 0.0, green: 1.0, blue: 1.0), "cyan"),
            (Color(red: 0.5, green: 0.5, blue: 0.5), "gray"),
        ]
    )
    func rgbColors(_ color: Color, name: String) {
        openSwiftUIAssertSnapshot(
            of: color,
            testName: "rgb_\(name)"
        )
    }

    @Test(
        arguments: [
            (Color(white: 0.0), "black"),
            (Color(white: 0.25), "dark_gray"),
            (Color(white: 0.5), "medium_gray"),
            (Color(white: 0.75), "light_gray"),
            (Color(white: 1.0), "white"),
        ]
    )
    func grayscaleColors(_ color: Color, name: String) {
        openSwiftUIAssertSnapshot(
            of: color,
            testName: "grayscale_\(name)"
        )
    }

    @Test(
        arguments: [
            (Color(hue: 0.0, saturation: 1.0, brightness: 1.0), "red"),
            (Color(hue: 0.33, saturation: 1.0, brightness: 1.0), "green"),
            (Color(hue: 0.67, saturation: 1.0, brightness: 1.0), "blue"),
            (Color(hue: 0.5, saturation: 0.5, brightness: 1.0), "desaturated_cyan"),
            (Color(hue: 0.0, saturation: 1.0, brightness: 0.5), "dark_red"),
        ]
    )
    func hsbColors(_ color: Color, name: String) {
        openSwiftUIAssertSnapshot(
            of: color,
            testName: "hsb_\(name)"
        )
    }

    @Test
    func frameAnimation() {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 1, count: 4)
            }

            @State private var smaller = false
            var body: some View {
                Color.red
                    .frame(width: smaller ? 50 : 100, height: smaller ? 50 : 100)
                    .animation(.linear(duration: Self.model.duration), value: smaller)
                    .onAppear {
                        smaller.toggle()
                    }
            }
        }
        withKnownIssue("#340", isIntermittent: true) {
            openSwiftUIAssertAnimationSnapshot(of: ContentView())
        }
    }

    // FIXME
    @Test(.disabled("Color interpolation is not aligned with SwiftUI yet"))
    func colorAnimation() {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 1, count: 4)
            }

            @State private var showRed = false
            var body: some View {
                Color(platformColor: showRed ? .red : .blue)
                    .animation(.linear(duration: Self.model.duration), value: showRed)
                    .onAppear {
                        showRed.toggle()
                    }
            }
        }
        openSwiftUIAssertAnimationSnapshot(of: ContentView())
    }

    // FIXME
    @Test(.disabled("Color interpolation is not aligned with SwiftUI yet"))
    func frameColorAnimation() {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 1, count: 4)
            }

            @State private var showRed = false
            var body: some View {
                Color(platformColor: showRed ? .red : .blue)
                    .frame(width: showRed ? 50 : 100, height: showRed ? 50 : 100)
                    .animation(.linear(duration: Self.model.duration), value: showRed)
                    .onAppear {
                        showRed.toggle()
                    }
            }
        }
        openSwiftUIAssertAnimationSnapshot(
            of: ContentView()
        )
    }
}
