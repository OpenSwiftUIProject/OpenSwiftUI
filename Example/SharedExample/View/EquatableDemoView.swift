//
//  EquatableView.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Equatable
import Foundation

@Equatable
struct EquatableDemoView: View {
    @Namespace private var namespace
    let count: Int
    @EquatableIgnored let tag: Int

    var body: some View {
        VStack {
            Color.red
        }
    }
}
