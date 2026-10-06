//
//  CompositingGroupExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct CompositingGroupExample: View {
    var body: some View {
        VStack {
            CompositingGroupTextExample()
            CompositingGroupCirclesExample()
        }
    }
}

struct CompositingGroupTextExample: View {
    var body: some View {
        let view = ZStack {
            Text("CompositingGroup")
                .foregroundColor(.black)
                .padding(20)
                .background(Color.red)
            Text("CompositingGroup")
                .blur(radius: 2)
        }
        .font(.largeTitle)
        return VStack {
            view
                .compositingGroup()
                .opacity(0.5)
            view
                .opacity(0.5)
        }
    }
}

struct CompositingGroupCirclesExample: View {
    let size: Double = 40
    var body: some View {
        let circles: some View = ZStack {
            Circle()
                .frame(width: size, height: size)
                .foregroundColor(.red)
                .offset(y: -size / 4)

            Circle()
                .frame(width: size, height: size)
                .foregroundColor(.blue)
                .offset(x: -size / 4, y: size / 4)

            Circle()
                .frame(width: size, height: size)
                .foregroundColor(.green)
                .offset(x: size / 4, y: size / 4)
        }
        return VStack(spacing: size / 2) {
            circles
            circles
                .opacity(0.5)
            circles
                .compositingGroup()
                .opacity(0.5)
        }
    }
}

#Preview {
    CompositingGroupExample()
}
