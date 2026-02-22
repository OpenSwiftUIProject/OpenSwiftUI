//
//  ZIndexTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
import OpenSwiftUICore
import Testing
import Foundation

@MainActor
struct ZIndexTests {
    @Test
    func traitCollectionZIndex() {
        var collection = ViewTraitCollection()
        #expect(collection.zIndex.isApproximatelyEqual(to: 0.0))
        collection.zIndex = 1.5
        #expect(collection.zIndex.isApproximatelyEqual(to: 1.5))
    }

    @Test(.enabled(if: attributeGraphEnabled))
    func zIndexDisplayList() {
        struct ContentView: View {
            var body: some View {
                GeometryReader { proxy in
                    VStack {
                        Color.white
                            .frame(width: 100, height: 100, alignment: .center)
                            .zIndex(1)
                        Color.black
                            .frame(width: 100, height: 100, alignment: .center)
                   }
                    .frame(width: 200, height: 200)
                }
                .ignoresSafeArea()
            }
        }
        let graph = ViewGraph(
            rootViewType: ContentView.self,
            requestedOutputs: [.layout, .displayList]
        )
        graph.instantiateOutputs()
        graph.setRootView(ContentView())
        graph.setProposedSize(CGSize(width: 1000, height: 1000))
        let (displayList, _) = graph.displayList()
        let expectRegex = try! Regex(#"""
        \(display-list
          \(item #:identity \d+ #:version \d+
            \(frame \(50.0 104.0; 100.0 100.0\)\)
            \(content-seed \d+\)
            \(color #000000FF\)\)
          \(item #:identity \d+ #:version \d+
            \(frame \(50.0 -4.0; 100.0 100.0\)\)
            \(content-seed \d+\)
            \(color #FFFFFFFF\)\)\)
        """#)
        #expect(displayList.description.contains(expectRegex))
    }
}
