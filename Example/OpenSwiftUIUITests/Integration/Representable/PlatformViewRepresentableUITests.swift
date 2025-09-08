//
//  PlatformViewRepresentableUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

#if os(iOS) || os(visionOS)
import UIKit
typealias PlatformViewRepresentable = UIViewRepresentable
#elseif os(macOS)
import AppKit
typealias PlatformViewRepresentable = NSViewRepresentable
#endif

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct PlatformViewRepresentableUITests {
    @Test
    func plainColorView() {
        struct PlainColorView: PlatformViewRepresentable {
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
        struct ContentView: View {
            var body: some View {
                PlainColorView()
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
