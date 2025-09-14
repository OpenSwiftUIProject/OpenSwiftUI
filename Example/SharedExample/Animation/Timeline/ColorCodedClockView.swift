//
//  ColorCodedClockView.swift
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
struct ColorCodedClockView: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
            let date = timeline.date
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            let second = calendar.component(.second, from: date)
            
            VStack(spacing: 20) {
                Text("Color-Coded Clock")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack(spacing: 10) {
                    // Hour
                    TimeComponentView(
                        value: hour,
                        maxValue: 24,
                        label: "Hours",
                        baseColor: .red
                    )
                    
                    Text(":")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Minute
                    TimeComponentView(
                        value: minute,
                        maxValue: 60,
                        label: "Minutes",
                        baseColor: .green
                    )
                    
                    Text(":")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Second
                    TimeComponentView(
                        value: second,
                        maxValue: 60,
                        label: "Seconds",
                        baseColor: .blue
                    )
                }
                
                // Color legend
                HStack(spacing: 20) {
                    LegendItem(color: .red, label: "Hours")
                    LegendItem(color: .green, label: "Minutes")
                    LegendItem(color: .blue, label: "Seconds")
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                
                // Time progress bars
                VStack(spacing: 10) {
                    ProgressBar(value: hour, maxValue: 24, color: .red, label: "Hour Progress")
                    ProgressBar(value: minute, maxValue: 60, color: .green, label: "Minute Progress")
                    ProgressBar(value: second, maxValue: 60, color: .blue, label: "Second Progress")
                }
                .padding()
            }
            .padding()
        }
    }
}

struct TimeComponentView: View {
    let value: Int
    let maxValue: Int
    let label: String
    let baseColor: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(String(format: "%02d", value))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(
                    LinearGradient(
                        colors: [
                            baseColor.opacity(0.6),
                            baseColor.opacity(Double(value) / Double(maxValue) + 0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(15)
                .shadow(radius: 5)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 5) {
            LinearGradient(
                colors: [color.opacity(0.6), color],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 15, height: 15)
            .cornerRadius(3)
            
            Text(label)
                .font(.caption)
        }
    }
}

struct ProgressBar: View {
    let value: Int
    let maxValue: Int
    let color: Color
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(value)/\(maxValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // Progress fill with gradient
                    LinearGradient(
                        colors: [
                            color.opacity(0.7),
                            color
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(
                        width: geometry.size.width * (Double(value) / Double(maxValue)),
                        height: 8
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            .frame(height: 8)
        }
    }
}
#endif
