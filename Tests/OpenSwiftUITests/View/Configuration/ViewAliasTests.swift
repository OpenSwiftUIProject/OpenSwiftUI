//
//  ViewAliasTests.swift
//  OpenSwiftUITests

import Foundation
import Testing
import OpenAttributeGraphShims
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import OpenSwiftUITestsSupport

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct ViewAliasTests {
    @Test
    func staticViewAliasUsageRendersSource() {
        struct Alias: ViewAlias {}

        struct ContentView: View {
            var body: some View {
                Alias()
                    .viewAlias(Alias.self) {
                        Color.black
                    }
            }
        }

        let displayList = DisplayListUtil.renderDisplayList(ContentView())
        #expect(displayList.contains(singleColorDisplayListRegex("#000000FF")))
        #expect(DisplayListUtil.containsColor("#000000FF", in: displayList))
    }

    @Test(arguments: [true, false])
    func optionalViewAliasUsage(sourceIsPresent: Bool) {
        struct Alias: ViewAlias {}

        struct ContentView: View {
            var source: Color?

            var body: some View {
                Alias()
                    .optionalViewAlias(Alias.self) {
                        source
                    }
            }
        }

        let source: Color? = sourceIsPresent ? .black : nil
        let displayList = DisplayListUtil.renderDisplayList(ContentView(source: source))
        if sourceIsPresent {
            #expect(displayList.contains(effectColorDisplayListRegex("#000000FF")))
            #expect(DisplayListUtil.containsColor("#000000FF", in: displayList))
        } else {
            #expect(displayList.wholeMatch(of: emptyDisplayListRegex) != nil)
            #expect(!DisplayListUtil.containsAnyColor(displayList))
        }
    }

    @Test
    func viewListUsageRendersStaticAndOptionalAliasSources() {
        struct StaticAlias: ViewAlias {}
        struct OptionalAlias: ViewAlias {}

        struct StaticContentView: View {
            var body: some View {
                VStack {
                    StaticAlias()
                }
                .viewAlias(StaticAlias.self) {
                    Color.black
                }
            }
        }

        struct OptionalContentView: View {
            var source: Color?

            var body: some View {
                VStack {
                    OptionalAlias()
                }
                .optionalViewAlias(OptionalAlias.self) {
                    source
                }
            }
        }

        let staticDisplayList = DisplayListUtil.renderDisplayList(StaticContentView())
        #expect(staticDisplayList.contains(singleColorDisplayListRegex("#000000FF")))
        #expect(DisplayListUtil.containsColor("#000000FF", in: staticDisplayList))

        let optionalPresentDisplayList = DisplayListUtil.renderDisplayList(OptionalContentView(source: .black))
        #expect(optionalPresentDisplayList.contains(effectColorDisplayListRegex("#000000FF")))
        #expect(DisplayListUtil.containsColor("#000000FF", in: optionalPresentDisplayList))

        let optionalNilDisplayList = DisplayListUtil.renderDisplayList(OptionalContentView(source: nil))
        #expect(optionalNilDisplayList.wholeMatch(of: emptyDisplayListRegex) != nil)
        #expect(!DisplayListUtil.containsAnyColor(optionalNilDisplayList))
    }

    @Test
    func optionalViewAliasConsumerTracksPresentAndNilSource() {
        struct Alias: ViewAlias {}

        struct AliasReader: View {
            @OptionalViewAlias
            private var alias: Alias?

            var body: some View {
                if let alias {
                    alias
                } else {
                    Color.white
                }
            }
        }

        struct ContentView: View {
            var source: Color?

            var body: some View {
                AliasReader()
                    .optionalViewAlias(Alias.self) {
                        source
                    }
            }
        }

        let presentDisplayList = DisplayListUtil.renderDisplayList(ContentView(source: .black))
        #expect(presentDisplayList.contains(effectColorDisplayListRegex("#000000FF")))
        #expect(DisplayListUtil.containsColor("#000000FF", in: presentDisplayList))
        #expect(!presentDisplayList.contains(effectColorDisplayListRegex("#FFFFFFFF")))
        #expect(!DisplayListUtil.containsColor("#FFFFFFFF", in: presentDisplayList))

        let nilDisplayList = DisplayListUtil.renderDisplayList(ContentView(source: nil))
        #expect(nilDisplayList.contains(effectColorDisplayListRegex("#FFFFFFFF")))
        #expect(DisplayListUtil.containsColor("#FFFFFFFF", in: nilDisplayList))
        #expect(!nilDisplayList.contains(effectColorDisplayListRegex("#000000FF")))
        #expect(!DisplayListUtil.containsColor("#000000FF", in: nilDisplayList))
    }

    @Test
    func optionalViewAliasDynamicProperty() {
        struct ContentView: View {
            @OptionalViewAlias
            private var alias: ChildView.Alias?

            var body: some View {
                if alias == nil {
                    ChildView()
                        .viewAlias(ChildView.Alias.self) { Color.black }
                } else {
                    Color.red
                }
            }
        }

        struct ChildView: View {
            struct Alias: ViewAlias {}

            @OptionalViewAlias
            private var alias: Alias?

            var body: some View {
                if let alias {
                    alias
                } else {
                    Color.white
                }
            }
        }

        let displayList = DisplayListUtil.renderDisplayList(ContentView())
        #expect(displayList.contains(effectColorDisplayListRegex("#000000FF")))
        #expect(DisplayListUtil.containsColor("#000000FF", in: displayList))
        #expect(!DisplayListUtil.containsColor("#FF3B30FF", in: displayList))
        #expect(!DisplayListUtil.containsColor("#FFFFFFFF", in: displayList))
    }

    private var emptyDisplayListRegex: Regex<AnyRegexOutput> {
        try! Regex(#"\(display-list\)"#)
    }

    private func singleColorDisplayListRegex(_ color: String) -> Regex<AnyRegexOutput> {
        try! Regex(#"""
        \(display-list
          \(item #:identity \d+ #:version \d+
            \(frame \([^)]+\)\)
            \(content-seed \d+\)
            \(color \#(color)\)\)\)
        """#)
    }

    private func effectColorDisplayListRegex(_ color: String) -> Regex<AnyRegexOutput> {
        try! Regex(#"""
        \(display-list
          \(item #:identity \d+ #:version \d+
            \(frame \([^)]+\)\)
            \(effect
              \(item #:identity \d+ #:version \d+
                \(frame \([^)]+\)\)
                \(content-seed \d+\)
                \(color \#(color)\)\)\)\)\)
        """#)
    }
}
