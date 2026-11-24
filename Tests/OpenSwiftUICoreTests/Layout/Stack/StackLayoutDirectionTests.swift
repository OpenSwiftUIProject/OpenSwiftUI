//
//  StackLayoutDirectionTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenAttributeGraphShims
import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct StackLayoutDirectionTests {
    @Test(arguments: [
        (LayoutDirection.leftToRight, [0, 28]),
        (.rightToLeft, [60, 0]),
    ] as [(LayoutDirection, [CGFloat])])
    func horizontalPlacement(direction: LayoutDirection, expected: [CGFloat]) {
        let stack = HStack(spacing: 8) {
            Color.red.frame(width: 20)
            Color.blue
        }
        #expect(childOrigins(of: stack, in: direction) == expected)
    }

    @Test(arguments: [
        (LayoutDirection.leftToRight, HorizontalAlignment.leading, [0, 0]),
        (.rightToLeft, .leading, [60, 0]),
        (.leftToRight, .trailing, [60, 0]),
        (.rightToLeft, .trailing, [0, 0]),
    ] as [(LayoutDirection, HorizontalAlignment, [CGFloat])])
    func verticalAlignment(direction: LayoutDirection, alignment: HorizontalAlignment, expected: [CGFloat]) {
        let stack = VStack(alignment: alignment, spacing: 0) {
            Color.red.frame(width: 20)
            Color.blue
        }
        #expect(childOrigins(of: stack, in: direction) == expected)
    }

    private func childOrigins(of stack: some View, in direction: LayoutDirection) -> [CGFloat] {
        let view = stack.environment(\.layoutDirection, direction)
        let graph = ViewGraph(rootViewType: type(of: view), requestedOutputs: [.layout, .displayList])
        graph.instantiateOutputs()
        graph.setRootView(view)
        graph.setProposedSize(CGSize(width: 80, height: 40))
        return graph.displayList().0.items.map(\.frame.minX)
    }
}
