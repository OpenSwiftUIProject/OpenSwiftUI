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

    @Test
    func clippedAncestorPreservesPlatformViewPosition() {
        struct ColorView: PlatformViewRepresentable {
            #if os(iOS) || os(visionOS)
            func makeUIView(context: Context) -> some UIView {
                let view = UIView()
                view.backgroundColor = .green
                return view
            }

            func updateUIView(_ uiView: UIViewType, context: Context) {}
            #elseif os(macOS)
            func makeNSView(context: Context) -> some NSView {
                let view = NSView()
                view.wantsLayer = true
                view.layer?.backgroundColor = NSColor.green.cgColor
                return view
            }

            func updateNSView(_ nsView: NSViewType, context: Context) {}
            #endif
        }

        struct ContentView: View {
            var body: some View {
                VStack(spacing: 12) {
                    Color.red
                        .frame(width: 40, height: 40)
                    ColorView()
                        .frame(width: 100, height: 16)
                }
                .padding(8)
                .background(Color.yellow)
                .clipped()
                .frame(
                    width: defaultSize.width,
                    height: defaultSize.height,
                    alignment: .bottom
                )
            }
        }

        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
