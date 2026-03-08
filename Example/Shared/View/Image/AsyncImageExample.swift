//
//  AsyncImageExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Foundation

struct AsyncImageExample: View {
    var body: some View {
        AsyncImage(url: URL(string: "https://picsum.photos/200"))
    }
}
