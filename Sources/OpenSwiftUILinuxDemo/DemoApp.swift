import OpenSwiftUI

#if os(Android) && OPENSWIFTUI_ANDROID_UIKIT
import Android

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
            VStack(spacing: 10.0) {
                Color.red
                Color.blue
            }
        }
    }
}
#endif
