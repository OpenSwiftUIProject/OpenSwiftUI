//
//  LayoutDirectionBehaviorTests.swift
//  OpenSwiftUITests

import Foundation
import OpenAttributeGraphShims
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct LayoutDirectionBehaviorTests {
    @Test(arguments: [
        (.fixed, .leftToRight, .leftToRight, false),
        (.fixed, .rightToLeft, .rightToLeft, false),
        (.mirrors, .leftToRight, .leftToRight, false),
        (.mirrors, .rightToLeft, .leftToRight, true),
        (.mirrors(in: .leftToRight), .leftToRight, .rightToLeft, true),
        (.mirrors(in: .leftToRight), .rightToLeft, .rightToLeft, false),
    ] as [(LayoutDirectionBehavior, LayoutDirection, LayoutDirection, Bool)])
    func directionBehavior(
        behavior: LayoutDirectionBehavior,
        direction: LayoutDirection,
        childDirection: LayoutDirection,
        mirrors: Bool
    ) throws {
        try withFixture(behavior: behavior, direction: direction) { fixture in
            let child = fixture.child
            #expect(child.environment.value.layoutDirection == childDirection)
            #expect(fixture.environment.value.layoutDirection == direction)
            #expect(child.size.value.proposal == _ProposedSize(width: 40.75, height: 30.75))
            let output = try #require(fixture.outputs.displayList).value
            if mirrors {
                #expect(child.position.value == .zero)
                #expect(child.containerPosition.value == .zero)
                #expect(child.size.value.value == CGSize(width: 41, height: 31))
                let point = child.transform.value.convert(
                    .globalToSpace(.local), point: CGPoint(x: 13.125, y: 25.125)
                )
                #expect(point == CGPoint(x: 37.75, y: 5))
                let item = try #require(output.items.first)
                #expect(output.items.count == 1)
                #expect(item.frame == CGRect(x: 7.125, y: 16.125, width: 40.75, height: 30.75))
                guard case let .effect(.transform(.affine(transform)), content) = item.value else {
                    Issue.record("Expected an affine mirror around the child display list")
                    return
                }
                #expect(CGPoint(x: 3, y: 5).applying(transform) == CGPoint(x: 37.75, y: 5))
                #expect(content == fixture.content.value)
            } else {
                #expect(child.position.value == CGPoint(x: 10.125, y: 20.125))
                #expect(child.containerPosition.value == CGPoint(x: 3, y: 4))
                #expect(child.size.value.value == CGSize(width: 40.75, height: 30.75))
                #expect(child.transform.value == ViewTransform())
                #expect(output == fixture.content.value)
            }
        }
    }

    @Test
    func changesUpdateTheExistingGraph() throws {
        try withFixture(behavior: .fixed, direction: .leftToRight) { fixture in
            let displayList = try #require(fixture.outputs.displayList)
            #expect(displayList.value == fixture.content.value)

            fixture.effect.value.behavior = .mirrors(in: .leftToRight)
            #expect(fixture.child.environment.value.layoutDirection == .rightToLeft)
            #expect(fixture.child.position.value == .zero)
            let identity = try #require(displayList.value.items.first).identity

            fixture.position.value = CGPoint(x: 20.125, y: 30.125)
            fixture.size.value = .fixed(CGSize(width: 80.75, height: 50.75))
            #expect(fixture.child.size.value.value == CGSize(width: 81, height: 51))
            let item = try #require(displayList.value.items.first)
            #expect(item.identity == identity)
            #expect(item.frame == CGRect(x: 17.125, y: 26.125, width: 80.75, height: 50.75))
            guard case let .effect(.transform(.affine(transform)), _) = item.value else {
                Issue.record("Expected the mirror to track the new width")
                return
            }
            #expect(CGPoint(x: 3, y: 5).applying(transform) == CGPoint(x: 77.75, y: 5))

            fixture.environment.value.layoutDirection = .rightToLeft
            #expect(fixture.child.environment.value.layoutDirection == .rightToLeft)
            #expect(fixture.child.position.value == CGPoint(x: 20.125, y: 30.125))
            #expect(fixture.child.containerPosition.value == CGPoint(x: 3, y: 4))
            #expect(fixture.child.transform.value == ViewTransform())
            #expect(displayList.value == fixture.content.value)

            fixture.effect.value.behavior = .fixed
            fixture.environment.value.layoutDirection = .leftToRight
            #expect(fixture.child.environment.value.layoutDirection == .leftToRight)
        }
    }

    @Test(arguments: [false, true])
    func missingOrEmptyContentProducesNoDisplayItems(hasContent: Bool) throws {
        try withFixture(behavior: .mirrors, direction: .rightToLeft, hasContent: hasContent) { fixture in
            fixture.content.value = DisplayList()
            let displayList = try #require(fixture.outputs.displayList)
            #expect(displayList.value.isEmpty)
        }
    }

    @Test
    func environmentAndGeometryUpdateWithoutDisplayList() throws {
        try withFixture(behavior: .mirrors, direction: .rightToLeft, requiresDisplayList: false) { fixture in
            #expect(fixture.outputs.displayList == nil)
            #expect(fixture.child.environment.value.layoutDirection == .leftToRight)
            #expect(fixture.child.position.value == .zero)
            #expect(fixture.child.size.value.value == CGSize(width: 41, height: 31))
        }
    }

    private struct Fixture {
        let effect: Attribute<_LayoutDirectionBehaviorEffect>
        let environment: Attribute<EnvironmentValues>
        let position: Attribute<CGPoint>
        let size: Attribute<ViewSize>
        let content: Attribute<DisplayList>
        let child: _ViewInputs
        let outputs: _ViewOutputs
    }

    private func withFixture(
        behavior: LayoutDirectionBehavior,
        direction: LayoutDirection,
        requiresDisplayList: Bool = true,
        hasContent: Bool = true,
        _ body: (Fixture) throws -> Void
    ) throws {
        let graph = Graph(shared: Graph())
        let subgraph = Subgraph(graph: graph)
        defer { subgraph.invalidate() }
        try subgraph.apply {
            var values = EnvironmentValues()
            values.layoutDirection = direction
            values.displayScale = 2
            let environment = Attribute(value: values)
            let position = Attribute(value: CGPoint(x: 10.125, y: 20.125))
            let size = Attribute(value: ViewSize.fixed(CGSize(width: 40.75, height: 30.75)))
            let base = _GraphInputs(
                time: Attribute(value: .zero),
                phase: Attribute(value: .init()),
                environment: environment,
                transaction: Attribute(value: .init())
            )
            var inputs = _ViewInputs(
                base,
                position: position,
                size: size,
                transform: Attribute(value: ViewTransform()),
                containerPosition: Attribute(value: CGPoint(x: 3, y: 4)),
                hostPreferenceKeys: Attribute(value: PreferenceKeys())
            )
            inputs.preferences.requiresDisplayList = requiresDisplayList
            let content = Attribute(value: DisplayList(DisplayList.Item(
                .effect(.identity, DisplayList()),
                frame: CGRect(x: 1, y: 2, width: 3, height: 4),
                identity: .init(),
                version: .init(forUpdate: ())
            )))
            let effect = Attribute(value: _LayoutDirectionBehaviorEffect(behavior: behavior))
            var child = inputs
            let outputs = _LayoutDirectionBehaviorEffect._makeView(
                modifier: _GraphValue(effect), inputs: inputs
            ) { _, childInputs in
                child = childInputs
                var outputs = _ViewOutputs()
                if requiresDisplayList && hasContent {
                    outputs.displayList = content
                }
                return outputs
            }
            return Result {
                try body(Fixture(
                    effect: effect, environment: environment, position: position,
                    size: size, content: content, child: child, outputs: outputs
                ))
            }
        }.get()
    }
}
