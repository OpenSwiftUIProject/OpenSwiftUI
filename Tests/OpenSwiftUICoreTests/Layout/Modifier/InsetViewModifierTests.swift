//
//  InsetViewModifierTests.swift
//  OpenSwiftUICoreTests

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
