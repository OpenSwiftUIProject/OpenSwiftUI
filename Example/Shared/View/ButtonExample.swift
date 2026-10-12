//
//  ButtonExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct ButtonExample: View {
    var onPress: (Int) -> Void = { _ in }

    @State private var count = 0

    var body: some View {
        Button {
            count += 1
            onPress(count)
        } label: {
            Text("Count: \(count)")
                .frame(minWidth: 120, minHeight: 44)
        }
    }
}

#Preview {
    ButtonExample()
}
