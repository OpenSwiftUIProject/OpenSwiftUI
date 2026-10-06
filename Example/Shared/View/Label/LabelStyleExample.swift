//
//  LabelStyleExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct LabelStyleExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("Automatic")
            } icon: {
                Color.red
                    .frame(width: 16, height: 16)
            }
            .labelStyle(.automatic)

            Label {
                Text("Icon only")
            } icon: {
                Color.green
                    .frame(width: 16, height: 16)
            }
            .labelStyle(.iconOnly)

            Label {
                Text("Title only")
            } icon: {
                Color.blue
                    .frame(width: 16, height: 16)
            }
            .labelStyle(.titleOnly)

            Label {
                Text("Title and icon")
            } icon: {
                Color.orange
                    .frame(width: 16, height: 16)
            }
            .labelStyle(.titleAndIcon)
        }
        .padding()
    }
}

#Preview {
    LabelStyleExample()
}
