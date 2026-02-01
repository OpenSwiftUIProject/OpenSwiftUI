//
//  InsetViewModifierExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct InsetViewModifierExample: View {
    var body: some View {
        Color.red
            .safeAreaInset(edge: .leading) {
                Color.green.frame(width: 10)
            }
            .safeAreaInset(edge: .top) {
                Color.blue.frame(height: 20)
            }
            .safeAreaInset(edge: .trailing) {
                Color.gray.frame(width: 30)
            }
            .safeAreaInset(edge: .bottom) {
                Color.yellow.frame(height: 40)
            }
    }
}
