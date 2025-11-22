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
                .frame(width: 100, height: 60)
            Spacer()
            Color.blue
                .frame(width: 100, height: 60)
                .rotationEffect(.degrees(45))
            Spacer()
            Color.green
                .frame(width: 100, height: 60)
        }
    }
}

// Run the application
ShaftHostingView.run(rootView: ContentView())
