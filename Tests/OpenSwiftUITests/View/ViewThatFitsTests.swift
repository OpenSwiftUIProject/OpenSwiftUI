//
//  ViewThatFitsTests.swift
//  OpenSwiftUITests

import Foundation
import OpenAttributeGraphShims
@testable import OpenSwiftUI
import Testing

@MainActor
struct ViewThatFitsTests {
    @Test
    func initialization() {
        let defaultView = ViewThatFits { EmptyView() }
        #expect(defaultView._tree.root.axes == [.horizontal, .vertical])

        let horizontalView = ViewThatFits(in: .horizontal) { EmptyView() }
        #expect(horizontalView._tree.root.axes == .horizontal)
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func selectsFirstChildThatFits() {
        struct ContentView: View {
            var body: some View {
                ViewThatFits {
                    Color.red.frame(width: 200, height: 200)
                    Color.blue.frame(width: 100, height: 100)
                }
            }
        }

        let graph = ViewGraph(
            rootViewType: ContentView.self,
            requestedOutputs: [.layout, .displayList]
        )
        graph.instantiateOutputs()
        graph.setRootView(ContentView())

        graph.setProposedSize(CGSize(width: 150, height: 150))
        let (fallbackDisplayList, _) = graph.displayList()
        #expect(fallbackDisplayList.items.count == 1)
        #expect(fallbackDisplayList.items.first?.frame.size == CGSize(width: 100, height: 100))

        graph.setProposedSize(CGSize(width: 250, height: 250))
        let (preferredDisplayList, _) = graph.displayList()
        #expect(preferredDisplayList.items.count == 1)
        #expect(preferredDisplayList.items.first?.frame.size == CGSize(width: 200, height: 200))
    }
}
