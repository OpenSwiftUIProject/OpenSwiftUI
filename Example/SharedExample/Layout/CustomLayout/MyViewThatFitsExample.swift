//
//  MyViewThatFitsExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

// The DL does not fully align since we have not implement canonicalize API yet.
// See https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/349
struct MyViewThatFitsExample: View {
    @State private var showRed = false
    var body: some View {
        MyViewThatFitsByLayout {
            Color.red.frame(width: 100, height: 200)
            Color.blue.frame(width: 200, height: 100)
        }
        .frame(width: 100, height: showRed ? 200 : 100)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showRed.toggle()
            }
        }
        .id(showRed)
    }
}
