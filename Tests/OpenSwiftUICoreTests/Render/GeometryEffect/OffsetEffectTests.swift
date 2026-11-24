//
//  OffsetEffectTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenAttributeGraphShims
import OpenSwiftUICore
import Testing

@MainActor
struct OffsetEffectTests {
    @Test(.disabled(if: attributeGraphVendor == .oag), arguments: [
        (LayoutDirection.leftToRight, CGPoint(x: 48, y: 21)),
        (.rightToLeft, CGPoint(x: 24, y: 21)),
    ])
    func offsetFromCenteredPosition(direction: LayoutDirection, expected: CGPoint) {
        let view = Color.red
            .frame(width: 8, height: 8)
            .offset(x: 12, y: 5)
            .frame(width: 80, height: 40)
            .environment(\.layoutDirection, direction)
        let graph = ViewGraph(rootViewType: type(of: view), requestedOutputs: [.layout, .displayList])
        graph.instantiateOutputs()
        graph.setRootView(view)
        graph.setProposedSize(CGSize(width: 80, height: 40))
        #expect(graph.displayList().0.items.map(\.frame.origin) == [expected])
    }
}
