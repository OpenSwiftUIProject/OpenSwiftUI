//
//  AsyncImageExample.swift
//  Example
//
//  Created by Kyle on 1/18/26.
//

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
