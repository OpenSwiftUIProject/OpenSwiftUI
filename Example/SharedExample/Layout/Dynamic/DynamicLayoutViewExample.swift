//
//  DynamicLayoutViewExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct DynamicLayoutViewExample: View {
    @State var show = false
    var body: some View {
        VStack {
            Color.red
                .task { show = true }
            if show {
                Color.blue
            }
        }
    }
}
