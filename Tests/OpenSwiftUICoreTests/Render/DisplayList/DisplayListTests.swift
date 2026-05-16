//
//  DisplayListTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenSwiftUICore
import Testing

@MainActor
@Suite
struct DisplayListTests {
    @Test
    func version() {
        typealias Version = DisplayList.Version
        let v0 = Version()
        let v1 = Version(decodedValue: 999)
        let v2 = Version(forUpdate: ())
        #expect(v0.value == 0)
        #expect(v1.value == 999)
        #expect(v2.value == 1000)
        #expect(v1 < v2)
        
        var combineVersion = v0
        #expect(combineVersion.value == 0)
        combineVersion.combine(with: v1)
        #expect(combineVersion.value == 999)        
    }

    @Test
    func properties() {
        func item(_ value: DisplayList.Item.Value) -> DisplayList.Item {
            DisplayList.Item(
                value,
                frame: .zero,
                identity: .init(decodedValue: 1),
                version: .init(decodedValue: 1)
            )
        }

        let privacyItem = item(.effect(.properties(.privacySensitive), .init()))
        let ignoresEventsItem = item(.effect(.properties(.ignoresEvents), .init()))
        let privacyList = DisplayList(privacyItem)
        let ignoresEventsList = DisplayList(ignoresEventsItem)

        #expect(privacyList.properties == .privacySensitive)
        #expect(ignoresEventsList.properties == .ignoresEvents)

        let maskItem = item(.effect(.mask(privacyList), ignoresEventsList))
        #expect(DisplayList(maskItem).properties == [.privacySensitive, .ignoresEvents])

        let flattenedItem = item(.content(.init(
            .flattened(privacyList, .zero, .init()),
            seed: .init(decodedValue: 1)
        )))
        #expect(DisplayList(flattenedItem).properties == .privacySensitive)

        let statesItem = item(.states([
            (StrongHash(of: 1), privacyList),
            (StrongHash(of: 2), ignoresEventsList),
        ]))
        #expect(DisplayList(statesItem).properties == [.privacySensitive, .ignoresEvents])
    }

    @Suite
    struct DisplayListItemMatchesTopLevelStructureTests {
        enum TestCase {
            case emptyWithDifferentIdentity
            case sameColorContent
            case samePlaceholderContent
            case differentContentKinds
            case sameOpacityEffect
            case sameStateEffect
            case differentEffectKinds
            case sameStateKeys
            case reorderedStateKeys
            case shorterStateKeys
            case differentItemKinds
        }

        private func itemStructureFixture(
            for testCase: TestCase
        ) -> (lhs: DisplayList.Item, rhs: DisplayList.Item, expected: Bool) {
            func item(
                _ value: DisplayList.Item.Value,
                identity: DisplayList.Identity = .init(decodedValue: 1)
            ) -> DisplayList.Item {
                DisplayList.Item(
                    value,
                    frame: .zero,
                    identity: identity,
                    version: .init(decodedValue: 0)
                )
            }

            let redContent = item(.content(.init(
                .color(.init(red: 1, green: 0, blue: 0, opacity: 1)),
                seed: .init(decodedValue: 1)
            )))
            let greenContent = item(.content(.init(
                .color(.init(red: 0, green: 1, blue: 0, opacity: 1)),
                seed: .init(decodedValue: 2)
            )))
            let placeholder1 = item(.content(.init(
                .placeholder(id: .init(decodedValue: 1)),
                seed: .init(decodedValue: 1)
            )))
            let placeholder2 = item(.content(.init(
                .placeholder(id: .init(decodedValue: 2)),
                seed: .init(decodedValue: 2)
            )))
            let key1 = StrongHash(of: 1)
            let key2 = StrongHash(of: 2)

            switch testCase {
            case .emptyWithDifferentIdentity:
                return (
                    item(.empty),
                    item(.empty, identity: .init(decodedValue: 2)),
                    true
                )
            case .sameColorContent:
                return (redContent, greenContent, true)
            case .samePlaceholderContent:
                return (placeholder1, placeholder2, true)
            case .differentContentKinds:
                return (redContent, placeholder1, false)
            case .sameOpacityEffect:
                return (
                    item(.effect(.opacity(1), .init())),
                    item(.effect(.opacity(0.5), DisplayList(redContent))),
                    true
                )
            case .sameStateEffect:
                return (
                    item(.effect(.state(StrongHash(of: 1)), .init())),
                    item(.effect(.state(StrongHash(of: 2)), DisplayList(redContent))),
                    true
                )
            case .differentEffectKinds:
                return (
                    item(.effect(.opacity(1), .init())),
                    item(.effect(.identity, .init())),
                    false
                )
            case .sameStateKeys:
                return (
                    item(.states([
                        (key1, .init()),
                        (key2, DisplayList(redContent)),
                    ])),
                    item(.states([
                        (key1, DisplayList(placeholder1)),
                        (key2, .init()),
                    ])),
                    true
                )
            case .reorderedStateKeys:
                return (
                    item(.states([
                        (key1, .init()),
                        (key2, DisplayList(redContent)),
                    ])),
                    item(.states([
                        (key2, .init()),
                        (key1, DisplayList(redContent)),
                    ])),
                    false
                )
            case .shorterStateKeys:
                return (
                    item(.states([
                        (key1, .init()),
                        (key2, DisplayList(redContent)),
                    ])),
                    item(.states([
                        (key1, .init()),
                    ])),
                    false
                )
            case .differentItemKinds:
                return (item(.empty), redContent, false)
            }
        }

        @Test(arguments: [
            TestCase.emptyWithDifferentIdentity,
            .sameColorContent,
            .samePlaceholderContent,
            .differentContentKinds,
            .sameOpacityEffect,
            .sameStateEffect,
            .differentEffectKinds,
            .sameStateKeys,
            .reorderedStateKeys,
            .shorterStateKeys,
            .differentItemKinds,
        ])
        func itemMatchesTopLevelStructure(_ testCase: TestCase) {
            let fixture = itemStructureFixture(for: testCase)
            #expect(fixture.lhs.matchesTopLevelStructure(of: fixture.rhs) == fixture.expected)
        }
    }
}
