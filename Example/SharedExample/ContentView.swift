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
        InsetViewModifierExample()
    }
}
