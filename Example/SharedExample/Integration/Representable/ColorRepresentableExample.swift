//
//  ColorRepresentable.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if os(iOS)
import UIKit
typealias PlatformViewRepresentable = UIViewRepresentable
#elseif os(macOS)
import AppKit
typealias PlatformViewRepresentable = NSViewRepresentable
#endif

struct ColorRepresentableExample: PlatformViewRepresentable {
    #if os(iOS)
    func makeUIView(context: Context) -> some UIView {
        let v = UIView()
        v.backgroundColor = .red
        return v
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
    #elseif os(macOS)
    func makeNSView(context: Context) -> some NSView {
        let v = NSView()
        v.backgroundColor = .red
        return v
    }

    func updateNSView(_ uiView: NSViewType, context: Context) {}
    #endif
}
