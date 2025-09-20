//
//  SafeAreaInsetsTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing

@MainActor
@Suite(.enabled(if: attributeGraphEnabled, "OpenAttributeGraph is not ready yet"))
struct SafeAreaInsetsTests {
    @Test
    func insets() {
        let insets = SafeAreaInsets(
            space: .init(),
            elements: [.init(
                regions: .all,
                insets: .init(top: 1, leading: 2, bottom: 3, trailing: 4)
            )]
        )
        let graph = ViewGraph(rootViewType: EmptyView.self)
        let resolved = graph.rootSubgraph.apply {
            insets
                .resolve(
                    regions: .all,
                    in: .init(
                        context: AnyRuleContext(attribute: graph.rootView),
                        size: .init(value: graph.size),
                        environment: .init(value: graph.environment),
                        transform: .init(value: graph.transform),
                        position: .init(value: graph.zeroPoint),
                        safeAreaInsets: .init()
                    )
                )
        }
        #expect(resolved == .init(top: 1, leading: 2, bottom: 3, trailing: 4))
    }
}
