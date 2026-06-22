//
//  GeometryActionModifierExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Dispatch

struct GeometryActionModifierExample: View {
    @State private var measuredSize: CGSize = .zero
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 12) {
            Color.blue
                .frame(height: isExpanded ? 180 : 120)
                .onGeometryChange(for: CGSize.self) { geometry in
                    geometry.size
                } action: { newSize in
                    measuredSize = newSize
                }
                .onTapGesture {
                    isExpanded.toggle()
                }
        }
        .padding()
    }
}
