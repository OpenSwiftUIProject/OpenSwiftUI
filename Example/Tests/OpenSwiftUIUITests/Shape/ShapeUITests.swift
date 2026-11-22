//
//  ShapeUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ShapeUITests {
    @Test
    func rectangle() {
        struct ContentView: View {
            var body: some View {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100, alignment: .center)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func circle() {
        struct ContentView: View {
            var body: some View {
                Circle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100, alignment: .center)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func shadow() {
        struct ContentView: View {
            var body: some View {
                Circle()
                    .fill(Color.red.shadow(.drop(color: .blue, radius: 5, x: 10, y: 10)))
                    .frame(width: 100, height: 100, alignment: .center)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test(arguments: BuiltInShapeExample.Kind.allCases)
    func builtInShapes(kind: BuiltInShapeExample.Kind) {
        openSwiftUIAssertSnapshot(
            of: BuiltInShapeExample(kind: kind),
            named: kind.rawValue
        )
    }

    @Test(arguments: ShapeStrokeExample.Variant.allCases)
    func strokes(variant: ShapeStrokeExample.Variant) {
        openSwiftUIAssertSnapshot(
            of: ShapeStrokeExample(variant: variant),
            named: variant.rawValue
        )
    }

    @Test(arguments: ShapeStrokeBorderExample.Variant.allCases)
    func strokeBorders(variant: ShapeStrokeBorderExample.Variant) {
        openSwiftUIAssertSnapshot(
            of: ShapeStrokeBorderExample(variant: variant),
            named: variant.rawValue
        )
    }

    @Test
    func flower() {
        openSwiftUIAssertSnapshot(of: FlowerView())
    }
}
