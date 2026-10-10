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
    @State private var taps = 0

    var body: some View {
        VStack(spacing: 10) {
            Text("SDL3 + Skia")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.primary)
            Text("Clicks: \(taps)")
                .font(.system(size: 20, design: .monospaced))
                .foregroundColor(.blue)
            Text("A new page begins with a single line. Keep going until the words find their place, then leave a little room for the next idea.")
                .font(.system(size: 18))
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.center)
            (alternate ? Color.green : Color.red)
                .onTapGesture {
                    taps += 1
                    alternate.toggle()
                    print("SDL3 top tap: \(alternate ? "green" : "red")")
                }
            (alternateBottom ? Color.yellow : Color.blue)
                .onTapGesture(count: 2) {
                    alternateBottom.toggle()
                    print("SDL3 bottom double tap: \(alternateBottom ? "yellow" : "blue")")
                }
        }
        .padding(16)
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
