//
//  AnimatedColorTimelineView.swift
//  SharedExample
//
//  Created by Kyle on 2025/9/15.
//

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if OPENSWIFTUI
// FIXME: Missing LinearGradient, Shape, Text and safeArea.
// We use a simplified version for OpenSwiftUI now.
struct AnimatedColorTimelineView: View {
    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince1970

            ZStack {
                // Animated background color
                Color(
                    hue: (sin(time * 0.5) + 1) / 2,
                    saturation: 0.8,
                    brightness: 0.9
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
//                    Text("Animated Colors")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)

                    // Pulsing circle that changes color
//                    Circle()
//                        .fill(
                            Color(
                                hue: (cos(time * 2) + 1) / 2,
                                saturation: 1.0,
                                brightness: 1.0
                            )
//                        )
                        .frame(
                            width: 100 + sin(time * 3) * 20,
                            height: 100 + sin(time * 3) * 20
                        )

                    // Display current color values
                    let currentHue = (sin(time * 0.5) + 1) / 2
                    let _ = print(currentHue)
//                    Text("Background Hue: \(currentHue, specifier: "%.2f")")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.black.opacity(0.3))
//                        .cornerRadius(10)
                }
            }
        }
    }
}
#else
struct AnimatedColorTimelineView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSince1970

            ZStack {
                // Animated gradient background
                LinearGradient(
                    colors: [
                        Color(
                            hue: (sin(time * 0.5) + 1) / 2,
                            saturation: 0.8,
                            brightness: 0.9
                        ),
                        Color(
                            hue: (cos(time * 0.3) + 1) / 2,
                            saturation: 0.6,
                            brightness: 0.7
                        ),
                        Color(
                            hue: (sin(time * 0.7 + .pi) + 1) / 2,
                            saturation: 0.9,
                            brightness: 0.8
                        )
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Content overlay
                VStack(spacing: 30) {
                    Text("Animated Colors")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 5)

                    // Pulsing circle
                    Circle()
                        .fill(
                            Color(
                                hue: (sin(time * 2) + 1) / 2,
                                saturation: 1.0,
                                brightness: 1.0
                            )
                        )
                        .frame(
                            width: 100 + sin(time * 3) * 20,
                            height: 100 + sin(time * 3) * 20
                        )
                        .shadow(radius: 10)

                    // Color info
                    let currentHue = (sin(time * 0.5) + 1) / 2
                    Text("Hue: \(currentHue, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
        }
    }
}
#endif
