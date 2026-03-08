//
//  VariableImageExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
import OpenCombineFoundation
#else
import Combine
#endif
import Foundation

struct VariableImageExample: View {
     @State private var value: Double = 0.0
     @State private var goingUp = true
 
     let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
 
     var body: some View {
         VStack(spacing: 40) {
             HStack(spacing: 30) {
                 Image(systemName: "speaker.wave.3", variableValue: value)
                 Image(systemName: "wifi", variableValue: value)
                 Image(systemName: "chart.bar.fill", variableValue: value)
             }
             .font(.system(size: 60))
             .foregroundStyle(.blue)
             .onReceive(timer) { _ in
                 if goingUp {
                     value += 0.02
                     if value >= 1.0 { goingUp = false }
                 } else {
                     value -= 0.02
                     if value <= 0.0 { goingUp = true }
                 }
             }
         }
     }
 }
