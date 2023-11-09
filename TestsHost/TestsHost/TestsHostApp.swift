//
//  TestsHostApp.swift
//  TestsHost
//
//  Created by Kyle on 2023/11/9.
//

import OpenSwiftUI
import SwiftUI

@main
enum TestHostApp {
    static func main() {
        let useSwiftUI = true
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *),
           useSwiftUI {
            TestsHostSwiftUIApp.main()
        } else {
            TestsHostOpenSwiftUIApp.main()
        }
    }
}

struct TestsHostOpenSwiftUIApp: OpenSwiftUI.App {
    var body: some OpenSwiftUI.Scene {
        OpenSwiftUI.WindowGroup {
            OpenContentView()
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct TestsHostSwiftUIApp: SwiftUI.App {
    var body: some SwiftUI.Scene {
        SwiftUI.WindowGroup {
            ContentView()
        }
    }
}
