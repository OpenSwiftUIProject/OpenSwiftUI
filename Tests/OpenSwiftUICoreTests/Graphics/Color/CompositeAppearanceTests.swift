//
//  CompositeAppearanceTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
struct CompositeAppearanceTests {
    #if os(macOS)
    @Test
    func nestedOverridesFallBackToLastContainingAppearance() {
        let appearance = _ResolvedCompositeAppearance([
            StubAppearance(value: 10),
            _ResolvedCompositeAppearance([
                StubAppearance(value: 20),
                StubAppearance(value: 30, isPresent: false),
            ]),
        ])
        #expect(appearance.appearanceStack.count == 3)
        #expect(appearance.containsAsset(for: Key()))
        #expect(appearance.asset(for: Key()) == 20)
    }

    @Test
    func selectedAppearanceDoesNotFallThroughOnNilAsset() {
        let appearance = _ResolvedCompositeAppearance([
            StubAppearance(value: 10),
            StubAppearance(value: nil),
        ])
        var calls = 0
        func accent() -> Color.Resolved {
            calls += 1
            return .red
        }
        #expect(appearance.asset(for: Key(), accentColor: accent()) == nil)
        #expect(calls == 1)
    }

    @Test(arguments: [false, true])
    func missingAssetDoesNotEvaluateAccent(_ empty: Bool) {
        let appearance = _ResolvedCompositeAppearance(empty ? [] : [StubAppearance(value: 10, isPresent: false)])
        var calls = 0
        func accent() -> Color.Resolved {
            calls += 1
            return .red
        }
        #expect(!appearance.containsAsset(for: Key()))
        #expect(appearance.asset(for: Key(), accentColor: accent()) == nil)
        #expect(calls == 0)
    }

    @Test
    func equalityAndHashUseFlattenedOrder() {
        let first = StubAppearance(value: 10)
        let second = StubAppearance(value: 20)
        let flat = _ResolvedCompositeAppearance([first, second])
        let nested = _ResolvedCompositeAppearance([first, _ResolvedCompositeAppearance([second])])
        #expect(flat.isEqual(to: nested))
        #expect(!flat.isEqual(to: _ResolvedCompositeAppearance([second, first])))
        #expect(!flat.isEqual(to: _ResolvedCompositeAppearance([first])))
        #expect(!flat.isEqual(to: first))
        var flatHasher = Hasher()
        var nestedHasher = flatHasher
        flat.hash(into: &flatHasher)
        nested.hash(into: &nestedHasher)
        #expect(flatHasher.finalize() == nestedHasher.finalize())
    }

    private struct Key: AppearanceAssetKey {
        typealias AssetType = Int
    }

    private struct StubAppearance: _ResolvedAppearance, Hashable {
        var value: Int?
        var isPresent = true

        func asset<K>(for key: K, accentColor: @autoclosure () -> Color.Resolved) -> K.AssetType? where K: AppearanceAssetKey {
            _ = accentColor()
            return value as? K.AssetType
        }

        func containsAsset<K>(for key: K) -> Bool where K: AppearanceAssetKey {
            isPresent
        }

        func isEqual(to other: any _ResolvedAppearance) -> Bool {
            guard let other = other as? Self else {
                return false
            }
            return self == other
        }
    }
    #endif
}
