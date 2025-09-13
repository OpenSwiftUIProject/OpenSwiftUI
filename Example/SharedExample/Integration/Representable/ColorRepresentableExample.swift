//
//  ColorRepresentableExample.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if os(iOS) || os(visionOS)
import UIKit
typealias PlatformViewRepresentable = UIViewRepresentable
typealias PlatformViewControllerRepresentable = UIViewControllerRepresentable
#elseif os(macOS)
import AppKit
typealias PlatformViewRepresentable = NSViewRepresentable
typealias PlatformViewControllerRepresentable = NSViewControllerRepresentable
#endif

struct ColorViewRepresentableExample: PlatformViewRepresentable {
    #if os(iOS) || os(visionOS)
    func makeUIView(context: Context) -> some UIView {
        let v = UIView()
        v.backgroundColor = .red
        return v
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
    #elseif os(macOS)
    func makeNSView(context: Context) -> some NSView {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.red.cgColor
        return v
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {}
    #endif
}

struct ColorViewControllerRepresentableExample: PlatformViewControllerRepresentable {
    #if os(iOS) || os(visionOS)
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        return vc
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    #elseif os(macOS)
    func makeNSViewController(context: Context) -> some NSViewController {
        let vc = NSViewController()
        vc.view.wantsLayer = true
        vc.view.layer?.backgroundColor = NSColor.red.cgColor
        return vc
    }

    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {}
    #endif
}
