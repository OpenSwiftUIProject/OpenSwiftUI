import OpenSwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 10.0) {
            Text("OpenSwiftUI on Android")
            Text("with UIKit-cross-platform")
            Color.red
            Color.blue
        }
        .frame(width: 640.0, height: 480.0)
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
