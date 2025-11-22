//
//  main.swift
//  ShaftExample
//
//  Example application demonstrating OpenSwiftUI rendering via Shaft
//

import Foundation
import OpenSwiftUI
import OpenSwiftUIShaftBackend


// Define a simple OpenSwiftUI view
struct ContentView: OpenSwiftUI.View {
    var body: some OpenSwiftUI.View {
        BlueColor()
    }
}

struct BlueColor: OpenSwiftUI.View {
    var id: String { "BlueColor" }

    var body: some OpenSwiftUI.View {
        Color.blue._identified(by: id)
    }
}

// Run the application
ShaftHostingView.run(rootView: ContentView())
