//
//  ViewAliasTests.swift
//  OpenSwiftUITests

import Foundation
import Testing
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import OpenSwiftUITestsSupport

@MainActor
struct ViewAliasTests {
    #if canImport(Darwin)
    @Test
    func optionalViewAliasDynamicProperty() async throws {
        struct ContentView: View {
            var confirmation: Confirmation?

            @OptionalViewAlias
            private var alias: ChildView.Alias?

            var body: some View {
                ChildView(confirmation: confirmation)
                    .viewAlias(ChildView.Alias.self) { Color.red }
                    .onAppear {
                        #expect(alias == nil)
                        confirmation?()
                    }
            }
        }

        struct ChildView: View {
            var confirmation: Confirmation?

            struct Alias: ViewAlias {}

            @OptionalViewAlias
            private var alias: Alias?

            var body: some View {
                Alias()
                    .onAppear {
                        #expect(alias != nil)
                        confirmation?()
                    }
            }
        }
        try await triggerLayoutWithWindow(expectedCount: 2) { confirmation in
            PlatformHostingController(
                rootView: ContentView(
                    confirmation: confirmation
                )
            )
        }

        // DisplayList expectation
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
    #endif
}
