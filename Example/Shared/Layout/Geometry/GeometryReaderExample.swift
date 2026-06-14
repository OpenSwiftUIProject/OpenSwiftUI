//
//  GeometryReaderExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct GeometryReaderExample: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Color.blue
                    .frame(
                        width: geometry.size.width / 2,
                        height: geometry.size.height / 2
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.yellow.opacity(0.3))
        }
    }
}
