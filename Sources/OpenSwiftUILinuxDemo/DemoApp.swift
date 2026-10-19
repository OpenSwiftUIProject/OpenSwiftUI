import Foundation
import OpenSwiftUI
import OpenSwiftUIDemoContent

#if os(Android)
import Android
#elseif canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

#if os(Android) && OPENSWIFTUI_ANDROID_UIKIT
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
