//
//  VariadicViewTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenSwiftUICore
import Testing

struct PassthroughUnaryViewRoot: _VariadicView.UnaryViewRoot {
    func body(children: _VariadicView.Children) -> some View {
        children
    }
}

struct PassthroughMultiViewRoot: _VariadicView.MultiViewRoot {
    func body(children: _VariadicView.Children) -> some View {
        children
    }
}

@MainActor
struct VariadicViewTests {

    #if canImport(Darwin)
        @Test
        func nestedUnaryViewRoot() {
            struct ContentView: View {
                var body: some View {
                    _VariadicView.Tree(PassthroughUnaryViewRoot()) {
                        _VariadicView.Tree(PassthroughUnaryViewRoot()) {
                            Color.red
                            Color.blue
                        }
                    }
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
            let expectRegex = try! Regex(
                #"""
                \(display-list
                    \(item #:identity \d+ #:version \d+
                    \(frame \([^)]+\)\)
                    \(effect
                        \(item #:identity \d+ #:version \d+
                        \(frame \([^)]+\)\)
                        \(effect
                            \(item #:identity \d+ #:version \d+
                            \(frame \([^)]+\)\)
                            \(content-seed \d+\)
                            \(color #[0-9A-F]{8}\)\)\)\)
                        \(item #:identity \d+ #:version \d+
                        \(frame \([^)]+\)\)
                        \(effect
                            \(item #:identity \d+ #:version \d+
                            \(frame \([^)]+\)\)
                            \(content-seed \d+\)
                            \(color #[0-9A-F]{8}\)\)\)\)\)\)\)
                """#)
            #expect(displayList.description.contains(expectRegex))
        }

        @Test
        func nestedMultiViewRoot() {
            struct ContentView: View {
                var body: some View {
                    _VariadicView.Tree(PassthroughMultiViewRoot()) {
                        _VariadicView.Tree(PassthroughMultiViewRoot()) {
                            Color.red
                            Color.blue
                        }
                    }
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
            let expectRegex = try! Regex(
                #"""
                \(display-list
                    \(item #:identity \d+ #:version \d+
                    \(frame \([^)]+\)\)
                    \(effect
                        \(item #:identity \d+ #:version \d+
                        \(frame \([^)]+\)\)
                        \(effect
                            \(item #:identity \d+ #:version \d+
                            \(frame \([^)]+\)\)
                            \(content-seed \d+\)
                            \(color #[0-9A-F]{8}\)\)\)\)
                        \(item #:identity \d+ #:version \d+
                        \(frame \([^)]+\)\)
                        \(effect
                            \(item #:identity \d+ #:version \d+
                            \(frame \([^)]+\)\)
                            \(content-seed \d+\)
                            \(color #[0-9A-F]{8}\)\)\)\)\)\)\)
                """#)
            #expect(displayList.description.contains(expectRegex))
        }
    #endif
}
