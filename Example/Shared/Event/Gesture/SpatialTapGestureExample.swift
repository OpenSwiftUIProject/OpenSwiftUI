//
//  SpatialTapGestureExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct SpatialTapGestureExample: View {
    @State private var location: CGPoint = .zero

    var tap: some Gesture {
        SpatialTapGesture()
            .onEnded { event in
                location = event.location
            }
    }

    var body: some View {
        Circle()
            .fill(location.y > 50 ? Color.blue : Color.red)
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(tap)
    }
}
