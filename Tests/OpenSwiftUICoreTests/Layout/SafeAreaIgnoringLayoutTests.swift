//
//  SafeAreaIgnoringLayoutTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@MainActor
@Suite(.tags(.aigc), .disabled(if: attributeGraphVendor == .oag))
struct SafeAreaIgnoringLayoutTests {
    @Test(arguments: [
        (.all, CGSize(width: 160, height: 240), CGPoint(x: -20, y: -10)),
        (.bottom, CGSize(width: 100, height: 230), CGPoint.zero),
        (.horizontal, CGSize(width: 160, height: 200), CGPoint(x: -20, y: 0)),
        (Edge.Set(), CGSize(width: 100, height: 200), CGPoint.zero),
    ] as [(Edge.Set, CGSize, CGPoint)])
    func placementExpandsSelectedEdges(
        edges: Edge.Set,
        expectedSize: CGSize,
        expectedOrigin: CGPoint
    ) {
        Update.perform {
            let graph = ViewGraph(rootViewType: EmptyView.self)
            defer { graph.invalidate() }
            graph.rootSubgraph.apply {
                let space = CoordinateSpace.ID()
                var transform = ViewTransform()
                transform.appendSizedSpace(id: space, size: CGSize(width: 160, height: 240))
                transform.appendTranslation(CGSize(width: -20, height: -10))
                let insets = SafeAreaInsets(
                    space: space,
                    elements: [.init(
                        regions: .container,
                        insets: .init(top: 10, leading: 20, bottom: 30, trailing: 40)
                    )]
                )
                let ruleContext = AnyRuleContext(attribute: graph.rootView)
                let context = _PositionAwarePlacementContext(
                    context: ruleContext,
                    size: .init(value: .fixed(CGSize(width: 100, height: 200))),
                    environment: .init(value: graph.environment),
                    transform: .init(value: transform),
                    position: .init(value: graph.zeroPoint),
                    safeAreaInsets: .init(Attribute(value: insets))
                )
                let placement = _SafeAreaIgnoringLayout(edges: edges).placement(
                    of: LayoutProxy(context: ruleContext, attributes: .init()),
                    in: context
                )

                #expect(placement.proposedSize == expectedSize)
                #expect(placement.anchor == .topLeading)
                #expect(placement.anchorPosition == expectedOrigin)
            }
        }
    }
}
