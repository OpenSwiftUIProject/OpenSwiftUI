//
//  GeometryReaderExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

// FIXME: SwiftUI yellow background will ignoreSafeArea while OpenSwiftUI will have it.
// See #474
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
