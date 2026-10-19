//
//  InsetViewModifierTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct InsetViewModifierTests {
    @Test
    func safeAreaInsetPreservesViewListChildren() {
        checkViewList(
            TupleView((Color.red, Color.blue))
                .safeAreaInset(edge: .top, spacing: 0) {
                    Color.clear.frame(height: 12)
                }
        )
    }

    @Test
    func safeAreaPaddingPreservesViewListChildren() {
        checkViewList(
            TupleView((Color.red, Color.blue))
                .safeAreaPadding(.horizontal, 20)
        )
    }

    @Test(arguments: [VerticalEdge.top, .bottom])
    func verticalSafeAreaInsetPreservesContentLayout(edge: VerticalEdge) {
        checkLayout(
            Color.red.frame(width: 32, height: 48)
                .safeAreaInset(edge: edge, spacing: 0) {
                    Color.clear.frame(width: 12, height: 12)
                },
            expectedSize: CGSize(width: 32, height: 60)
        )
    }

    @Test(arguments: [HorizontalEdge.leading, .trailing])
    func horizontalSafeAreaInsetPreservesContentLayout(edge: HorizontalEdge) {
        checkLayout(
            Color.red.frame(width: 32, height: 48)
                .safeAreaInset(edge: edge, spacing: 0) {
                    Color.clear.frame(width: 12, height: 12)
                },
            expectedSize: CGSize(width: 44, height: 48)
        )
    }

    @Test(arguments: [
        (Edge.top, CGSize(width: 32, height: 60)),
        (.bottom, CGSize(width: 32, height: 60)),
        (.leading, CGSize(width: 44, height: 48)),
        (.trailing, CGSize(width: 44, height: 48)),
    ])
    func safeAreaPaddingPreservesContentLayout(edge: Edge, expectedSize: CGSize) {
        checkLayout(
            Color.red.frame(width: 32, height: 48)
                .safeAreaPadding(Edge.Set(edge), 12),
            expectedSize: expectedSize
        )
    }

    private func checkLayout<Content: View>(_ content: Content, expectedSize: CGSize) {
        Update.perform {
            let graph = ViewGraph(rootViewType: Content.self, requestedOutputs: .layout)
            defer { graph.invalidate() }
            graph.setRootView(content)
            #expect(graph.sizeThatFits(.unspecified) == expectedSize)
        }
    }

    private func checkViewList<Content: View>(_ content: Content) {
        Update.perform {
            let graph = ViewGraph(rootViewType: Content.self)
            defer { graph.invalidate() }
            graph.rootSubgraph.apply {
                let inputs = _ViewListInputs(graph.graphInputs)
                let outputs = Content._makeViewList(
                    view: _GraphValue(Attribute(value: content)),
                    inputs: inputs
                )
                #expect(outputs.staticCount == 2)
                #expect(outputs.nextImplicitID == 2)
                #expect(outputs.makeAttribute(inputs: inputs).value.count(style: .init()) == 2)
            }
        }
    }
}
