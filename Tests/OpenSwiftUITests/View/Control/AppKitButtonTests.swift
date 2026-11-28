//
//  AppKitButtonTests.swift
//  OpenSwiftUITests

#if os(macOS)
import AppKit
import COpenSwiftUI
import OpenAttributeGraphShims
@testable import OpenSwiftUI
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct AppKitButtonTests {
    // On macOS 26, AppKit reported no intrinsic artwork width for Game2048's circular
    // New Game button, and its bezel collapsed to 1 pt. The rectangular content insets
    // also shifted the icon left when the bezel was given its full width.
    @Test(arguments: [ControlSize.small, .regular])
    func circularButtonCentersItsIcon(controlSize: ControlSize) throws {
        let rootView = Button("New Game", systemImage: "arrow.clockwise") {}
            .labelStyle(.iconOnly)
            .font(.title3.weight(.bold))
            .buttonStyle(BorderedButtonStyle_CarMac(tint: nil, isProminent: true))
            .buttonBorderShape(.circle)
            .controlSize(controlSize)
        let host = NSHostingView(rootView: rootView)
        for width: CGFloat in [160, 200] {
            host.setFrameSize(CGSize(width: width, height: 120))
            host._renderForTest(interval: 0)
            host.layoutSubtreeIfNeeded()

            let button = try #require(host.subviews.compactMap { $0 as? NSButton }.first)
            let icon = try #require(button.contentView?.subviews.first)
            let iconFrame = icon.convert(icon.bounds, to: button)
            #expect(button.bounds.width == button.bounds.height)
            #expect(iconFrame.width > 0)
            #expect(button.bounds.contains(iconFrame))
            #expect(abs(iconFrame.midX - button.bounds.midX) <= 0.5)
        }
    }
}
#endif
