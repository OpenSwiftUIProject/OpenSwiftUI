//
//  CachedEnvironmentTests.swift
//  OpenSwiftUICoreTests

import OpenGraphShims
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
@testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@MainActor
struct CachedEnvironmentTests {
    @Test
    func attribute() {
        let graph = Graph(shared: Graph())
        let globalSubgraph = Subgraph(graph: graph)
        Subgraph.current = globalSubgraph
        defer { Subgraph.current = nil }
        var env = CachedEnvironment(.init(value: .init()))
        let attribute1 = env.attribute(id: .layoutDirection) { $0.layoutDirection }
        let attribute2 = env.attribute(id: .layoutDirection) { $0.layoutDirection }
        #expect(attribute1 == attribute2)
    }
}
