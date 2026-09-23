import Foundation
import OpenSwiftUI

@main
struct SDLExampleApp: App {
    var body: some Scene {
        WindowGroup {
            SDLExampleView()
        }
    }
}

private struct SDLExampleView: View {
    @State private var alternate = false
    @State private var alternateBottom = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 10) {
            (alternate ? Color.green : Color.red)
                .onTapGesture {
                    alternate.toggle()
                    print("SDL3 top tap: \(alternate ? "green" : "red")")
                }
            (alternateBottom ? Color.yellow : Color.blue)
                .onTapGesture(count: 2) {
                    alternateBottom.toggle()
                    print("SDL3 bottom double tap: \(alternateBottom ? "yellow" : "blue")")
                }
        }
        .onAppear {
            if ProcessInfo.processInfo.environment["OPENSWIFTUI_SDL_DEMO_ANIMATE"] == "1" {
                timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                    alternate.toggle()
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}
