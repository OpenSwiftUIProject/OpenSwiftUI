//
//  IDViewTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenAttributeGraphShims
import OpenSwiftUICore
import Testing

@MainActor
struct IDViewTests {
    @Test
    func viewExtension() {
        let empty = EmptyView()
        _ = empty.id("1")
        _ = empty.id(2)
        _ = empty.id(UUID())
    }

    @Test(.enabled(if: attributeGraphEnabled))
    func idViewDisplayList() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Color.red
                    Color.blue
                }.id(1)
            }
        }
        let graph = ViewGraph(
            rootViewType: ContentView.self,
            requestedOutputs: [.displayList]
        )
        graph.instantiateOutputs()
        graph.setRootView(ContentView())
        graph.setProposedSize(CGSize(width: 100, height: 100))
        let (displayList, _) = graph.displayList()
        let expectRegex = try! Regex(#"""
        \(display-list
          \(item #:identity \d+ #:version \d+
            \(frame \([^)]+\)\)
            \(effect
              \(item #:identity \d+ #:version \d+
                \(frame \([^)]+\)\)
                \(content-seed \d+\)
                \(color #[0-9A-F]{8}\)\)
              \(item #:identity \d+ #:version \d+
                \(frame \([^)]+\)\)
                \(content-seed \d+\)
                \(color #[0-9A-F]{8}\)\)\)\)\)
        """#)
        #expect(displayList.description.contains(expectRegex))
    }
}
