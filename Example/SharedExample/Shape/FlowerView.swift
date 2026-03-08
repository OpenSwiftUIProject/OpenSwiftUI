//
//  FlowerView.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Foundation

struct FlowerView: View {
    var body: some View {
        ZStack {
            ForEach(0..<6) { i in
                Capsule()
                    .fill(i.isMultiple(of: 2) ? .primary : .secondary)
                    .frame(width: 120, height: 40)
                    .rotationEffect(.degrees(Double(i) * 30))
                    .shadow(color: .purple, radius: 8, x: 4, y: 4)
            }
        }
        .foregroundStyle(.cyan, .orange)
    }
}

struct FlowerViewAnimation: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<6) { i in
                Capsule()
                    .fill(i.isMultiple(of: 2) ? .primary : .secondary)
                    .frame(width: 120, height: 40)
                    .rotationEffect(.degrees(Double(i) * 30))
                    .shadow(color: .purple, radius: 8, x: 4, y: 4)
            }
        }
        .foregroundStyle(.cyan, .orange)
        .scaleEffect(animate ? 1.2 : 0.8)
        .rotationEffect(.degrees(animate ? 360 : 0))
        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
        .task { animate = true }
    }
}
