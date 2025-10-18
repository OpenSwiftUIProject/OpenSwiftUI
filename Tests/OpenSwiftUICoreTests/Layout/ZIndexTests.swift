//
//  ZIndexTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
import OpenSwiftUICore
import Testing

@MainActor
struct ZIndexTests {
    @Test
    func indexOrder() {
        struct ContentView: View {
            var body: some View {
                Color.red
                    .zIndex(0.5)
            }
        }
        // TODO: Add a test helper to hook into makeViewList and retrieve the zIndex value to verify it

        let graph = ViewGraph(
            rootViewType: ContentView.self,
            requestedOutputs: [.displayList]
        )
        graph.instantiateOutputs()
        graph.setRootView(ContentView())
        graph.setProposedSize(CGSize(width: 100, height: 100))
        let (displayList, _) = graph.displayList()
    }
}
