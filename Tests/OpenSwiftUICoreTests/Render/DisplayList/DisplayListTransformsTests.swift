//
//  DisplayListTransformsTests.swift
//  OpenSwiftUICoreTests
//
//  Author: Codex 5.6 Sol

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

@MainActor
@Suite
struct DisplayListTransformsTests {
    @Test
    func stateSelectsMatchingDisplayList() {
        let firstHash = StrongHash(of: 1)
        let secondHash = StrongHash(of: 2)
        let first = DisplayList(contentItem(identity: 1, version: 3))
        let second = DisplayList(contentItem(identity: 2, version: 4))
        let states = DisplayList(item(
            .states([(firstHash, first), (secondHash, second)]),
            version: 5
        ))
        var displayList = DisplayList(item(
            .effect(.state(secondHash), states),
            version: 17
        ))

        displayList.applyViewGraphTransform(
            time: Attribute(identifier: .nil),
            version: .init(decodedValue: 100)
        )

        guard case let .effect(.identity, transformedStates) = displayList.items[0].value,
              case let .effect(.identity, selected) = transformedStates.items[0].value
        else {
            Issue.record("Expected the matching state to replace the state table")
            return
        }
        #expect(selected.items.count == 1)
        #expect(selected.items[0].identity == .init(decodedValue: 2))
        #expect(transformedStates.items[0].version.value == 17)
        #expect(displayList.items[0].version.value == 17)
        #expect(displayList.features.isEmpty)
    }

    @Test
    func stateWithoutMatchBecomesEmpty() {
        let selectedHash = StrongHash(of: 1)
        let states = DisplayList(item(
            .states([(StrongHash(of: 2), DisplayList(contentItem(identity: 2, version: 4)))]),
            version: 5
        ))
        var displayList = DisplayList(item(
            .effect(.state(selectedHash), states),
            version: 17
        ))

        displayList.applyViewGraphTransform(
            time: Attribute(identifier: .nil),
            version: .init(decodedValue: 100)
        )

        guard case let .effect(.identity, transformedStates) = displayList.items[0].value,
              case .empty = transformedStates.items[0].value
        else {
            Issue.record("Expected an unmatched state to become empty")
            return
        }
        #expect(transformedStates.items[0].version.value == 17)
        #expect(displayList.items[0].version.value == 17)
        #expect(displayList.features.isEmpty)
    }

    @Test
    func flattenedContentUsesCombinedItemVersionAsSeed() {
        let hash = StrongHash(of: 1)
        let states = DisplayList(item(
            .states([(hash, DisplayList(contentItem(identity: 1, version: 3)))]),
            version: 5
        ))
        let state = DisplayList(item(.effect(.state(hash), states), version: 17))
        var displayList = DisplayList(item(
            .content(.init(
                .flattened(state, CGPoint(x: 2, y: 3), .init()),
                seed: .init(decodedValue: 123)
            )),
            version: 23
        ))

        displayList.applyViewGraphTransform(
            time: Attribute(identifier: .nil),
            version: .init(decodedValue: 100)
        )

        guard case let .content(content) = displayList.items[0].value,
              case let .flattened(transformed, origin, _) = content.value,
              case .effect(.identity, _) = transformed.items[0].value
        else {
            Issue.record("Expected flattened content to be transformed recursively")
            return
        }
        #expect(origin == CGPoint(x: 2, y: 3))
        #expect(content.seed == DisplayList.Seed(.init(decodedValue: 23)))
        #expect(displayList.items[0].version.value == 23)
    }

    @Test
    func flattenedContentWithoutTransformFeaturesIsUnchanged() {
        let nested = DisplayList(contentItem(identity: 1, version: 3))
        let flattened = item(
            .content(.init(
                .flattened(nested, CGPoint(x: 2, y: 3), .init()),
                seed: .init(decodedValue: 123)
            )),
            version: 9
        )
        let stateEffect = item(
            .effect(.state(StrongHash(of: 1)), DisplayList()),
            version: 17
        )
        var displayList = DisplayList([flattened, stateEffect])

        displayList.applyViewGraphTransform(
            time: Attribute(identifier: .nil),
            version: .init(decodedValue: 100)
        )

        guard case let .content(content) = displayList.items[0].value,
              case let .flattened(transformed, origin, _) = content.value
        else {
            Issue.record("Expected flattened content to remain flattened")
            return
        }
        #expect(origin == CGPoint(x: 2, y: 3))
        #expect(content.seed == .init(decodedValue: 123))
        #expect(transformed.items[0].identity == .init(decodedValue: 1))
        #expect(displayList.items[0].version.value == 9)
    }

    @Test
    func interpolatorRootBecomesIdentity() {
        let child = DisplayList(contentItem(identity: 1, version: 3))
        var displayList = DisplayList(item(
            .effect(
                .interpolatorRoot(
                    DisplayList.InterpolatorGroup(),
                    contentOrigin: CGPoint(x: 2, y: 3),
                    contentOffset: CGSize(width: 4, height: 5)
                ),
                child
            ),
            version: 17
        ))

        displayList.applyViewGraphTransform(
            time: Attribute(identifier: .nil),
            version: .init(decodedValue: 100)
        )

        guard case let .effect(.identity, transformed) = displayList.items[0].value else {
            Issue.record("Expected the interpolator root to become identity")
            return
        }
        #expect(transformed.items[0].identity == .init(decodedValue: 1))
        #expect(displayList.items[0].version.value == 17)
        #expect(displayList.features.isEmpty)
    }

    @Test
    func unrelatedDisplayListIsUnchanged() {
        var displayList = DisplayList(contentItem(identity: 1, version: 3))
        let original = displayList

        displayList.applyViewGraphTransform(
            time: Attribute(identifier: .nil),
            version: .init(decodedValue: 100)
        )

        #expect(displayList == original)
    }

    private func item(
        _ value: DisplayList.Item.Value,
        version: Int
    ) -> DisplayList.Item {
        DisplayList.Item(
            value,
            frame: .zero,
            identity: .none,
            version: .init(decodedValue: version)
        )
    }

    private func contentItem(identity: UInt32, version: Int) -> DisplayList.Item {
        DisplayList.Item(
            .content(.init(
                .color(.init(red: 1, green: 0, blue: 0, opacity: 1)),
                seed: .init(decodedValue: UInt16(version))
            )),
            frame: .zero,
            identity: .init(decodedValue: identity),
            version: .init(decodedValue: version)
        )
    }
}
