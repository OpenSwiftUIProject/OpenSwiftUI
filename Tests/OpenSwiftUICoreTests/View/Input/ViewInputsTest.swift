//
//  ViewInputsTest.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct ViewInputsTest {
    @Test
    func debugProperties() {
        let graph = ViewGraph(rootViewType: EmptyView.self)
        graph.globalSubgraph.apply {
            var inputs = _ViewInputs(withoutGeometry: graph.graphInputs)

            #expect(inputs.changedDebugProperties == .all)
            inputs.changedDebugProperties = []

            inputs.transform = .init(value: .init())
            #expect(inputs.changedDebugProperties.contains(.transform))

            inputs.size = .init(value: .zero)
            #expect(inputs.changedDebugProperties.contains(.size))

            inputs.environment = .init(value: .init())
            #expect(inputs.changedDebugProperties.contains(.environment))

            inputs.viewPhase = .init(value: .invalid)
            #expect(inputs.changedDebugProperties.contains(.phase))
        }
    }
}
