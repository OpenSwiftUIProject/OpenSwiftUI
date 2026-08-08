//
//  ContentView.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct ContentView: View {
    var body: some View {
        #if !os(macOS)
        JindoExample()
        #endif
    }
}
