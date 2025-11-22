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
struct ContentView: View {
    var body: some View {
        VStack {
            Color.red
                .frame(width: 50, height: 30)
            Spacer()
            Color.blue
                .frame(width: 50, height: 30)
            Spacer()
            Color.green
                .frame(width: 50, height: 30)
        }
    }
}

// Run the application
ShaftHostingView.run(rootView: ContentView())
