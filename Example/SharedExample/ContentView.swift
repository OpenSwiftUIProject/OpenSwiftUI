//
//  ContentView.swift
//  SharedExample
//
//  Created by Kyle on 2023/11/9.
//

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Foundation

struct ContentView: View {
    var body: some View {
        Color.blue
            .frame(width: 80, height: 60)
            .scaleEffect(0.5)
            .background { Color.red }
             .frame(width: 10, height: 10)
             .clipped()
    }
}
