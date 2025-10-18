//
//  ViewAliasTests.swift
//  OpenSwiftUITests

import Testing
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if os(iOS) || os(visionOS)
import UIKit
#endif

@MainActor
struct ViewAliasTests {
    @Test
    func optionalViewAliasDynamicProperty() {
        struct ContentView: View {
            @OptionalViewAlias
            private var alias: ChildView.Alias?

            var body: some View {
                ChildView()
                    .viewAlias(ChildView.Alias.self) { Color.red }
                    .onAppear {
                        #expect(alias == nil)
                    }
            }
        }

        struct ChildView: View {
            struct Alias: ViewAlias {}

            @OptionalViewAlias
            private var alias: Alias?

            var body: some View {
                Alias()
                    .onAppear {
                        #expect(alias != nil)
                    }
            }
        }
        // How to tirgger onAppear
        let graph = ViewGraph(
            rootViewType: ContentView.self,
            requestedOutputs: [.displayList]
        )
        graph.instantiateOutputs()
        graph.setRootView(ContentView())
        graph.setProposedSize(CGSize(width: 100, height: 100))
        let (displayList, _) = graph.displayList()
        print(displayList.description)
        let expectRegex = try! Regex(#"""
        \(display-list
          \(item #:identity \d+ #:version \d+
            \(frame \([^)]+\)\)
            \(effect
              \(item #:identity \d+ #:version \d+
                \(frame \([^)]+\)\)
                \(content-seed \d+\)
                \(color #[0-9A-F]{8}\)\)\)\)\)
        """#)
        #expect(displayList.description.contains(expectRegex))
    }
}
