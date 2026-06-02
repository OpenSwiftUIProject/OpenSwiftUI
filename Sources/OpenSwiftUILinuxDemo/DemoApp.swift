import Foundation
import OpenSwiftUI

#if os(Android)
import Bionic
#elseif canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

struct ContentView: View {
    var body: some View {
        BreathingColorView()
    }
}

struct BreathingColorView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSince1970
            let breathe = (sin(time) + 1.0) / 2.0

            VStack(spacing: 40.0) {
                Text(verbatim: "Breathing Colors")
                    .font(.title)
                    .fontWeight(.bold)

                Color.blue.opacity(0.3 + breathe * 0.7)
                    .frame(width: 200.0, height: 200.0)
                    .scaleEffect(0.8 + breathe * 0.4)

                Color.blue
                    .frame(width: 200.0, height: 20.0)
                    .opacity(0.3 + breathe * 0.7)
                    .cornerRadius(10.0)
            }
            .padding()
        }
    }
}

#if os(Android) && OPENSWIFTUI_ANDROID_UIKIT
import Android
import OpenSwiftUIAndroidDemo

@main
struct DemoApp {
    static func main() {
        let status = MainActor.assumeIsolated {
            AndroidUIKitDemoRunner().run()
        }
        Android.exit(status)
    }
}
#else
@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
#endif
