//
//  GeometryEffectExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct AsyncRenderExample: View {
    @State private var items = [6]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(items, id: \.self) { item in
                Color.blue.opacity(Double(item) / 6.0)
                    .frame(height: 50)
                    .transition(.slide)
            }
        }
        .animation(.easeInOut(duration: 2), value: items)
        .onAppear {
            items.removeAll { $0 == 6 }
        }
    }
}
