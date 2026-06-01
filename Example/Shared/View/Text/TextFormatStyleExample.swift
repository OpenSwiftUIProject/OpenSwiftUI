//
//  TextFormatStyleExample.swift
//  Shared

import Foundation

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct TextFormatStyleExample: View {
    @State private var myDate = Date()

    var body: some View {
        VStack {
            Text(myDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
            Text(myDate, format: Date.FormatStyle(date: .complete, time: .complete))
            Text(myDate, format: Date.FormatStyle().hour(.defaultDigitsNoAMPM).minute())
        }
    }
}
