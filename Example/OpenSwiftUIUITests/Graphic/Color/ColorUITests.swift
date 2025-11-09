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
    func colorAnimation() {
        struct ContentView: View {
            @State private var showRed = false
            var body: some View {
                VStack {
                    Color(platformColor: showRed ? .red : .blue)
                        .frame(width: showRed ? 50 : 100, height: showRed ? 50 : 100)
                }
                .animation(.easeInOut(duration: 1), value: showRed)
                .onAppear {
                    showRed.toggle()
                }
            }
        }
        let model = AnimationTestModel(duration: 1, count: 10)
        openSwiftUIAssertAnimationSnapshot(
            of: ContentView(),
            model: model,
        )
    }
}
