//
//  PlatformViewControllerRepresentableUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

#if os(iOS)
import UIKit
typealias PlatformViewControllerRepresentable = UIViewControllerRepresentable
#elseif os(macOS)
import AppKit
typealias PlatformViewControllerRepresentable = NSViewControllerRepresentable
#endif

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct PlatformViewControllerRepresentableUITests {
    @Test
    func plainColorView() {
        struct PlainColorView: PlatformViewControllerRepresentable {
            #if os(iOS)
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
        struct ContentView: View {
            var body: some View {
                PlainColorView()
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
