//
//  TextSizeFittingTests.swift
//  OpenSwiftUICoreTests
//

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @_spi(Private) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
struct TextSizeFittingLogicTests {
    @Test
    func stickyLogicReusesVariantUntilProposalGrows() {
        var logic = StickyTextSizeFittingLogic(
            committedValue: (.compact, .init(width: 100, height: 40))
        )

        #expect(logic.suggestedVariant(for: .init(width: 100, height: 40)) == .compact)
        #expect(logic.suggestedVariant(for: .init(width: 80, height: 30)) == .compact)
        #expect(logic.suggestedVariant(for: .init(width: 101, height: 40)) == nil)
        #expect(logic.suggestedVariant(for: .init(width: 100, height: 41)) == nil)
    }

    @Test(arguments: [Axis.horizontal, .vertical], [false, true])
    func stickyLogicRejectsNaNUnlessAxisIsSticky(axis: Axis, committedIsNaN: Bool) {
        var proposal = _ProposedSize(width: 100, height: 40)
        var committedProposal = proposal
        if committedIsNaN {
            committedProposal[axis] = .nan
        } else {
            proposal[axis] = .nan
        }
        var logic = StickyTextSizeFittingLogic(
            committedValue: (.compact, committedProposal)
        )

        #expect(logic.suggestedVariant(for: proposal) == nil)

        logic.stickOnHorizontalGrowth = axis == .vertical
        logic.stickOnVerticalGrowth = axis == .horizontal
        #expect(logic.suggestedVariant(for: proposal) == nil)

        logic.stickOnHorizontalGrowth = axis == .horizontal
        logic.stickOnVerticalGrowth = axis == .vertical
        #expect(logic.suggestedVariant(for: proposal) == .compact)
    }

    @Test
    func invalidatingCommittedVariantClearsSuggestion() {
        var logic = StickyTextSizeFittingLogic(
            committedValue: (.small, .init(width: 100, height: 40))
        )

        logic.onInvalidation(of: .compact)
        #expect(logic.suggestedVariant(for: .init(width: 100, height: 40)) == .small)

        logic.onInvalidation(of: .small)
        #expect(logic.suggestedVariant(for: .init(width: 100, height: 40)) == nil)
    }
}

@MainActor
@Suite(.tags(.aigc), .disabled(if: attributeGraphVendor == .oag))
struct ResolvedTextHelperSizeFittingTests {
    @Test(arguments: [(9.0, false), (10.0, true), (11.0, true)])
    func deadlineInvalidatesUnchangedInputs(time: Double, expected: Bool) {
        withHelper(time: time, nextUpdate: .time(Time(seconds: 10))) { helper in
            let shouldUpdate = helper.shouldUpdate(
                for: (nil, EnvironmentValues(), nil),
                inputChanged: false
            )
            #expect(shouldUpdate == expected)
        }
    }

    @Test
    func recipeCachesDeadlineWhenNoUpdateIsDue() {
        let resolved = ResolvedStyledText(
            storage: nil,
            layoutProperties: .init(),
            layoutMargins: .zero,
            stylePadding: .zero,
            archiveOptions: .init(),
            isCollapsible: false,
            features: [],
            suffix: .none,
            attachments: .init(),
            styles: [],
            transitions: [],
            scaleFactorOverride: nil
        )
        withHelper(nextUpdate: .recipe(
            lastTime: .zero,
            lastDate: Date(timeIntervalSinceReferenceDate: 0),
            reduceFrequency: false,
            resolved: resolved
        )) { helper in
            let shouldUpdate = helper.shouldUpdate(
                for: (nil, EnvironmentValues(), nil),
                inputChanged: false
            )
            #expect(!shouldUpdate)
            guard case let .time(deadline) = helper.nextUpdate else {
                Issue.record("The recipe did not cache its deadline.")
                return
            }
            #expect(deadline == .infinity)
        }
    }

    @Test(arguments: [false, true])
    func unchangedInputsWithoutDeadlineDoNotUpdate(inputChanged: Bool) {
        withHelper { helper in
            let shouldUpdate = helper.shouldUpdate(
                for: (nil, EnvironmentValues(), nil),
                inputChanged: inputChanged
            )
            #expect(!shouldUpdate)
        }
    }

    @Test(arguments: [false, true])
    func textChangeRequiresInputInvalidation(inputChanged: Bool) {
        withHelper { helper in
            helper.lastText = Text(verbatim: "before")
            let shouldUpdate = helper.shouldUpdate(
                for: (Text(verbatim: "after"), EnvironmentValues(), nil),
                inputChanged: inputChanged
            )
            #expect(shouldUpdate == inputChanged)
        }
    }

    @Test(arguments: [false, true])
    func usedEnvironmentChangeRequiresInputInvalidation(inputChanged: Bool) {
        withHelper { helper in
            var environment = EnvironmentValues()
            environment.lineLimit = 2
            let tracked = EnvironmentValues(environment.plist, tracker: helper.tracker)
            _ = tracked.lineLimit
            var changed = environment
            changed.lineLimit = 3

            let shouldUpdate = helper.shouldUpdate(
                for: (nil, changed, nil),
                inputChanged: inputChanged
            )
            #expect(shouldUpdate == inputChanged)

            var unrelated = environment
            unrelated.lineSpacing = 4
            let unrelatedShouldUpdate = helper.shouldUpdate(
                for: (nil, unrelated, nil),
                inputChanged: inputChanged
            )
            #expect(!unrelatedShouldUpdate)
        }
    }

    @Test
    func narrowerVariantRequiresInitialResolution() {
        withHelper(nextUpdate: .time(Time(seconds: 100))) { helper in
            helper.sizeVariant = .compact
            var narrower = helper.narrowerVariant

            #expect(narrower.sizeVariant == .small)
            guard case let .time(deadline) = narrower.nextUpdate else {
                Issue.record("The narrower variant has no initial deadline.")
                return
            }
            #expect(deadline == .zero)
            let shouldUpdate = narrower.shouldUpdate(
                for: (nil, EnvironmentValues(), nil),
                inputChanged: false
            )
            #expect(shouldUpdate)
        }
    }

    private func withHelper(
        time: Double = 1,
        nextUpdate: ResolvedTextHelper.NextUpdate = .none,
        _ body: (inout ResolvedTextHelper) -> Void
    ) {
        let graph = Graph()
        let subgraph = Subgraph(graph: graph)
        subgraph.apply {
            var helper = ResolvedTextHelper(
                time: Attribute(value: Time(seconds: time)),
                referenceDate: .init(),
                includeDefaultAttributes: false,
                allowsKeyColors: false,
                archiveOptions: .init(),
                features: [],
                attachmentsAsAuxiliaryMetadata: false,
                idiom: AnyInterfaceIdiom(.phone),
                lastText: nil,
                nextUpdate: nextUpdate,
                sizeVariant: .regular
            )
            body(&helper)
        }
    }
}
