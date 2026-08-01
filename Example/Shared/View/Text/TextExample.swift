//
//  TextExample.swift
//  Shared

import Foundation
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct TextForegroundExample: View {
    var body: some View {
        VStack {
            Text("Hello World")
            Text("From OpenSwiftUI")
                .foregroundStyle(.red)
        }
    }
}

struct TextFormatStyleExample: View {
    @State private var myDate = Date(timeIntervalSince1970: 1_767_225_600)

    var body: some View {
        VStack {
            Text(myDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
            Text(myDate, format: Date.FormatStyle(date: .complete, time: .complete))
            Text(myDate, format: Date.FormatStyle().hour(.defaultDigitsNoAMPM).minute())
        }
    }
}

struct TextBackgroundHeightExample: View {
    var body: some View {
        Text("Hello, world!")
            .background(Color.red)
    }
}
