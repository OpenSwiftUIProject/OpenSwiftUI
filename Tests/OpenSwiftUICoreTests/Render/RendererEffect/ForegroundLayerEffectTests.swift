//
//  ForegroundLayerEffectTests.swift
//  OpenSwiftUICoreTests
//
//  Author: Codex 5.6 Sol

import Foundation
@_spi(Private) import OpenSwiftUICore
import Testing

@MainActor
@Suite
struct ForegroundLayerEffectTests {
    @Test
    func viewModifierEffect() {
        let modifier = _ForegroundLayerViewModifier()

        guard case let .properties(properties) = modifier.effectValue(size: .zero) else {
            Issue.record("Expected a properties effect")
            return
        }
        #expect(properties == .foregroundLayer)
    }

    @Test
    func levelProperties() {
        #expect(_ForegroundLayerLevel.none.properties.rawValue == 0x00)
        #expect(_ForegroundLayerLevel.primary.properties.rawValue == 0x01)
        #expect(_ForegroundLayerLevel.secondary.properties.rawValue == 0x10)
        #expect(_ForegroundLayerLevel.tertiary.properties.rawValue == 0x20)
        #expect(_ForegroundLayerLevel.quaternary.properties.rawValue == 0x40)

        let custom = _ForegroundLayerLevel([
            .secondaryForegroundLayer,
            .tertiaryForegroundLayer,
            .privacySensitive,
        ])
        #expect(custom.properties == [.secondaryForegroundLayer, .tertiaryForegroundLayer])
    }

    @Test
    func levelViewModifierEffect() {
        let level: _ForegroundLayerLevel = .init([
            .secondaryForegroundLayer,
            .tertiaryForegroundLayer,
        ])
        let modifier = _ForegroundLayerLevelViewModifier(level: level)

        guard case let .properties(properties) = modifier.effectValue(size: .zero) else {
            Issue.record("Expected a properties effect")
            return
        }
        #expect(properties == [.secondaryForegroundLayer, .tertiaryForegroundLayer])
    }

    @Test
    func colorMatrixEffectInitialization() {
        var foreground = _ColorMatrix()
        foreground.m11 = 0.25
        var background = _ColorMatrix()
        background.m22 = 0.5

        let effect = _ForegroundLayerColorMatrixEffect(
            foreground: foreground,
            background: background
        )

        #expect(effect.foreground == foreground)
        #expect(effect.background == background)
    }

    @Test
    func insertsAndGroupsLayerFilters() {
        var backgroundMatrix = _ColorMatrix()
        backgroundMatrix.m11 = 0.25
        var foregroundMatrix = _ColorMatrix()
        foregroundMatrix.m22 = 0.5
        let foregroundFrame = CGRect(x: 20, y: 0, width: 20, height: 10)
        let foregroundLayer = DisplayList.Item(
            .effect(
                .properties(.foregroundLayer),
                DisplayList([
                    item(frame: CGRect(x: 20, y: 0, width: 10, height: 10), version: 12),
                    item(frame: CGRect(x: 30, y: 0, width: 10, height: 10), version: 13),
                ])
            ),
            frame: foregroundFrame,
            identity: .none,
            version: .init(decodedValue: 13)
        )
        var displayList = DisplayList([
            item(frame: CGRect(x: 0, y: 0, width: 10, height: 10), version: 11),
            foregroundLayer,
        ])

        displayList.insertLayerFilters(
            matrices: [.none: backgroundMatrix, .primary: foregroundMatrix],
            version: .init(decodedValue: 10),
            premultiplied: true
        )

        #expect(displayList.items.count == 2)
        assertFilter(
            displayList.items[0],
            matrix: backgroundMatrix,
            premultiplied: true,
            frame: CGRect(x: 0, y: 0, width: 10, height: 10),
            version: 11,
            childOrigins: [.zero]
        )
        assertLayerFilter(
            displayList.items[1],
            properties: .foregroundLayer,
            matrix: foregroundMatrix,
            premultiplied: true,
            frame: foregroundFrame,
            version: 13,
            childOrigins: [.zero, CGPoint(x: 10, y: 0)]
        )
    }

    @Test
    func identityMatrixLeavesItemsUnwrapped() {
        let original = [
            item(frame: CGRect(x: 2, y: 3, width: 4, height: 5), version: 11),
            item(frame: CGRect(x: 8, y: 9, width: 4, height: 5), version: 12),
        ]
        var displayList = DisplayList(original)

        displayList.insertLayerFilters(
            matrices: [.none: _ColorMatrix()],
            version: .init(decodedValue: 10),
            premultiplied: false
        )

        #expect(displayList.items == original)
    }

    @Test
    func recursivelySplitsMixedLayerContent() {
        var primaryMatrix = _ColorMatrix()
        primaryMatrix.m11 = 0.25
        var secondaryMatrix = _ColorMatrix()
        secondaryMatrix.m22 = 0.5
        let child = DisplayList([
            layerItem(
                .foregroundLayer,
                frame: CGRect(x: 0, y: 0, width: 10, height: 10),
                version: 11
            ),
            layerItem(
                .secondaryForegroundLayer,
                frame: CGRect(x: 10, y: 0, width: 10, height: 10),
                version: 12
            ),
        ])
        var displayList = DisplayList(
            DisplayList.Item(
                .effect(.opacity(0.5), child),
                frame: CGRect(x: 0, y: 0, width: 20, height: 10),
                identity: .none,
                version: .init(decodedValue: 12)
            )
        )

        displayList.insertLayerFilters(
            matrices: [.primary: primaryMatrix, .secondary: secondaryMatrix],
            version: .init(decodedValue: 10),
            premultiplied: false
        )

        #expect(displayList.items.count == 1)
        guard case let .effect(.opacity(opacity), transformedChild) = displayList.items[0].value else {
            Issue.record("Expected the outer opacity effect to be preserved")
            return
        }
        #expect(opacity == 0.5)
        #expect(transformedChild.items.count == 2)
        assertLayerFilter(
            transformedChild.items[0],
            properties: .foregroundLayer,
            matrix: primaryMatrix,
            premultiplied: false,
            frame: CGRect(x: 0, y: 0, width: 10, height: 10),
            version: 11,
            childOrigins: [.zero]
        )
        assertLayerFilter(
            transformedChild.items[1],
            properties: .secondaryForegroundLayer,
            matrix: secondaryMatrix,
            premultiplied: false,
            frame: CGRect(x: 10, y: 0, width: 10, height: 10),
            version: 12,
            childOrigins: [.zero]
        )
    }

    private func item(frame: CGRect, version: Int) -> DisplayList.Item {
        DisplayList.Item(
            .content(.init(
                .color(.init(red: 1, green: 1, blue: 1, opacity: 1)),
                seed: .init(decodedValue: UInt16(version))
            )),
            frame: frame,
            identity: .none,
            version: .init(decodedValue: version)
        )
    }

    private func layerItem(
        _ properties: DisplayList.Properties,
        frame: CGRect,
        version: Int
    ) -> DisplayList.Item {
        DisplayList.Item(
            .effect(.properties(properties), DisplayList(item(frame: frame, version: version))),
            frame: frame,
            identity: .none,
            version: .init(decodedValue: version)
        )
    }

    private func assertFilter(
        _ item: DisplayList.Item,
        matrix: _ColorMatrix,
        premultiplied: Bool,
        frame: CGRect,
        version: Int,
        childOrigins: [CGPoint],
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(
            item.frame == CGRect(origin: .zero, size: frame.size),
            sourceLocation: sourceLocation
        )
        #expect(item.version.value == version, sourceLocation: sourceLocation)
        guard case let .effect(.filter(filter), content) = item.value,
              case let .colorMatrix(actualMatrix, actualPremultiplied) = filter
        else {
            Issue.record("Expected a color matrix filter", sourceLocation: sourceLocation)
            return
        }
        #expect(actualMatrix == matrix, sourceLocation: sourceLocation)
        #expect(actualPremultiplied == premultiplied, sourceLocation: sourceLocation)
        guard content.items.count == 1 else {
            Issue.record("Expected one compositing group", sourceLocation: sourceLocation)
            return
        }
        let group = content.items[0]
        #expect(group.frame == frame, sourceLocation: sourceLocation)
        #expect(group.version.value == version, sourceLocation: sourceLocation)
        guard case let .effect(.compositingGroup, children) = group.value else {
            Issue.record("Expected a compositing group", sourceLocation: sourceLocation)
            return
        }
        #expect(children.items.map(\.frame.origin) == childOrigins, sourceLocation: sourceLocation)
    }

    private func assertLayerFilter(
        _ item: DisplayList.Item,
        properties: DisplayList.Properties,
        matrix: _ColorMatrix,
        premultiplied: Bool,
        frame: CGRect,
        version: Int,
        childOrigins: [CGPoint],
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(item.frame == frame, sourceLocation: sourceLocation)
        #expect(item.version.value == version, sourceLocation: sourceLocation)
        guard case let .effect(.properties(actualProperties), content) = item.value else {
            Issue.record("Expected a properties effect", sourceLocation: sourceLocation)
            return
        }
        #expect(actualProperties == properties, sourceLocation: sourceLocation)
        guard content.items.count == 1 else {
            Issue.record("Expected one filtered item", sourceLocation: sourceLocation)
            return
        }
        assertFilter(
            content.items[0],
            matrix: matrix,
            premultiplied: premultiplied,
            frame: frame,
            version: version,
            childOrigins: childOrigins,
            sourceLocation: sourceLocation
        )
    }
}
