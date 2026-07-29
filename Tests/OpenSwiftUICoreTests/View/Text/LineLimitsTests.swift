//
//  LineLimitsTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@testable
import OpenSwiftUICore
import Testing

@MainActor
struct LineLimitsTests {
    private func modifier<V: View>(_ view: V) throws -> LineLimitModifier {
        let modified = try #require(
            view as? ModifiedContent<EmptyView, LineLimitModifier>
        )
        return modified.modifier
    }

    private func applying(
        _ modifier: LineLimitModifier,
        to initial: EnvironmentValues = .init()
    ) -> EnvironmentValues {
        let graph = ViewGraph(rootViewType: EmptyView.self)
        return graph.globalSubgraph.apply {
            var environment = initial
            let attribute = Attribute(value: modifier)
            LineLimitModifier.makeEnvironment(
                modifier: attribute,
                environment: &environment
            )
            return environment
        }
    }

    @Test
    func modifierLayout() {
        #expect(
            MemoryLayout<LineLimitModifier>.size
                == MemoryLayout<Int?>.stride + MemoryLayout<Int?>.size
        )
        #expect(
            MemoryLayout<LineLimitModifier>.stride
                == 2 * MemoryLayout<Int?>.stride
        )
        #expect(
            MemoryLayout<LineLimitModifier>.alignment
                == MemoryLayout<Int?>.alignment
        )
        #expect(
            MemoryLayout<LineLimitModifier>.offset(of: \.lowerLimit) == 0
        )
        #expect(
            MemoryLayout<LineLimitModifier>.offset(of: \.upperLimit)
                == MemoryLayout<Int?>.stride
        )
    }

    @Test
    func environmentValues() {
        var environment = EnvironmentValues()
        #expect(environment.lineLimit == nil)
        #expect(environment.lowerLineLimit == nil)

        environment.lineLimit = 4
        environment.lowerLineLimit = 2
        #expect(environment.lineLimit == 4)
        #expect(environment.lowerLineLimit == 2)

        environment.lineLimit = nil
        environment.lowerLineLimit = nil
        #expect(environment.lineLimit == nil)
        #expect(environment.lowerLineLimit == nil)
    }

    @Test
    func optionalOverload() throws {
        let set = try #require(
            EmptyView().lineLimit(5) as?
                ModifiedContent<
                    EmptyView,
                    _EnvironmentKeyWritingModifier<Int?>
                >
        )
        #expect(set.modifier.keyPath == \EnvironmentValues.lineLimit)
        #expect(set.modifier.value == 5)

        let clear = try #require(
            EmptyView().lineLimit(nil) as?
                ModifiedContent<
                    EmptyView,
                    _EnvironmentKeyWritingModifier<Int?>
                >
        )
        #expect(clear.modifier.keyPath == \EnvironmentValues.lineLimit)
        #expect(clear.modifier.value == nil)
    }

    @Test
    func rangeOverloads() throws {
        var value = try modifier(EmptyView().lineLimit(2...))
        #expect(value.lowerLimit == 2)
        #expect(value.upperLimit == nil)

        value = try modifier(EmptyView().lineLimit(...4))
        #expect(value.lowerLimit == nil)
        #expect(value.upperLimit == 4)

        value = try modifier(EmptyView().lineLimit(2...4))
        #expect(value.lowerLimit == 2)
        #expect(value.upperLimit == 4)
    }

    @Test
    func reservesSpaceOverload() throws {
        var value = try modifier(
            EmptyView().lineLimit(3, reservesSpace: false)
        )
        #expect(value.lowerLimit == nil)
        #expect(value.upperLimit == 3)

        value = try modifier(
            EmptyView().lineLimit(3, reservesSpace: true)
        )
        #expect(value.lowerLimit == 3)
        #expect(value.upperLimit == 3)
    }

    @Test(.disabled(if: attributeGraphVendor == .oag))
    func modifierOverwritesBothEnvironmentValues() {
        var initial = EnvironmentValues()
        initial.lineLimit = 9
        initial.lowerLineLimit = 8

        var result = applying(
            .init(lowerLimit: nil, upperLimit: 4),
            to: initial
        )
        #expect(result.lineLimit == 4)
        #expect(result.lowerLineLimit == nil)

        result = applying(
            .init(lowerLimit: 2, upperLimit: nil),
            to: initial
        )
        #expect(result.lineLimit == nil)
        #expect(result.lowerLineLimit == 2)
    }
}
