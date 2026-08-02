//
//  JindoTripleVStackTests.swift
//  OpenSwiftUITests

#if !os(macOS)
import Foundation
@_spi(Jindo)
import OpenSwiftUI
import Testing

@available(OpenSwiftUI_v4_1, *)
@available(macOS, unavailable)
struct JindoTripleVStackTests {
    @Test
    func configuration() {
        let notchSize = CGSize(width: 48, height: 12)
        var configuration = JindoTripleVStack.Configuration(
            notchSize: notchSize,
            horizontalSizing: .split,
            layoutMargins: EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        )

        #expect(configuration.notchSize == notchSize)
        #expect(configuration.centerAlignment == .center)
        #expect(configuration.bottomAlignment == .leading)
        #expect(configuration.uniformSpacing == nil)

        configuration.centerAlignment = .trailing
        configuration.bottomAlignment = .center
        configuration.uniformSpacing = 8

        #expect(configuration.centerAlignment == .trailing)
        #expect(configuration.bottomAlignment == .center)
        #expect(configuration.uniformSpacing == 8)
    }

    @Test
    func positionValueSemantics() {
        #expect(JindoTripleVStack.Position.leading == .leading(inset: nil))
        #expect(JindoTripleVStack.Position.leading != .leading(inset: 0))
        #expect(JindoTripleVStack.Position.leading(inset: 4) == .leading(inset: 4))
        #expect(JindoTripleVStack.Position.trailing != .trailing(inset: 0))
        #expect(JindoTripleVStack.Position.center != .bottom)
        #expect(JindoTripleVStack.Position.bottom != .bottom(leadingInset: 0))
        #expect(JindoTripleVStack.Position.bottom != .bottom(trailingInset: 0))
        #expect(JindoTripleVStack.Position.notch != .center)
    }

    @Test
    func sizingAndVerticalPlacementValues() {
        #expect(JindoTripleVStack.VerticalPlacement.default != .belowNotchIfTooWide)
        #expect(JindoTripleVStack.HorizontalSizing.automatic != .leading)
        #expect(JindoTripleVStack.HorizontalSizing.leading != .trailing)
        #expect(JindoTripleVStack.HorizontalSizing.trailing != .split)
        #expect(JindoTripleVStack.HorizontalSizing.split != .automatic)
    }

    @Test
    func layoutAndLayoutValueModifiers() {
        let configuration = JindoTripleVStack.Configuration(
            notchSize: CGSize(width: 48, height: 12),
            horizontalSizing: .automatic,
            layoutMargins: EdgeInsets()
        )
        requireLayout(JindoTripleVStack(configuration: configuration))

        let view = EmptyView()
            .jindoPosition(.leading(inset: 4))
            .jindoVerticalPlacement(.belowNotchIfTooWide)
            .jindoPriority(1)
            .jindoContentMargins(
                .init(top: 1, leading: 2, bottom: 3, trailing: 4)
            )
        requireView(view)
    }

    private func requireLayout<L>(_ layout: L) where L: Layout {}

    private func requireView<V>(_ view: V) where V: View {}
}
#endif
