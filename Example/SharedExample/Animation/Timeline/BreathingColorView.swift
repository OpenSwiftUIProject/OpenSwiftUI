//
//  BreathingColorView.swift
//  SharedExample
//
//  Created by Kyle on 2025/9/15.
//

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if !OPENSWIFTUI // FIXME: Missing Shape and Text
struct BreathingColorView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSince1970
            let breathe = (sin(time) + 1) / 2 // Oscillates between 0 and 1
            
            VStack(spacing: 40) {
                Text("Breathing Colors")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Main breathing circle
                Circle()
                    .fill(
                        Color.blue.opacity(0.3 + breathe * 0.7)
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(0.8 + breathe * 0.4)
                
                // Color intensity indicator
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 200, height: 20)
                    .opacity(0.3 + breathe * 0.7)
                    .cornerRadius(10)
                
                Text("Opacity: \(0.3 + breathe * 0.7, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}
#endif
