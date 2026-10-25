//
//  CompositeAppearanceTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
struct CompositeAppearanceTests {
    #if os(macOS)
    @Test(arguments: [
        (ColorScheme.light, [Int?]([10, 20, nil])),
        (ColorScheme.dark, [Int?]([11, 21, nil])),
    ])
    func providerResolvesNestedAppearancesInEnvironment(
        _ colorScheme: ColorScheme,
        expectedValues: [Int?]
    ) throws {
        let first = Appearance(provider: SchemeProvider(lightValue: 10, darkValue: 11))
        let second = Appearance(provider: SchemeProvider(lightValue: 20, darkValue: 21))
        let missing = Appearance(provider: SchemeProvider(lightValue: nil, darkValue: nil))
        let provider = CompositeAppearanceProvider(
            first,
            Appearance(provider: CompositeAppearanceProvider([second, missing]))
        )
        var environment = EnvironmentValues()
        environment.colorScheme = colorScheme
        let resolved = try #require(provider.resolve(in: environment) as? _ResolvedCompositeAppearance)
        #expect(resolved.appearanceStack.map { $0.asset(for: Key()) } == expectedValues)
        #expect(resolved.asset(for: Key()) == expectedValues[1])
    }

    @Test
    func emptyProviderResolvesToEmptyAppearance() throws {
        let provider = CompositeAppearanceProvider()
        let resolved = try #require(provider.resolve(in: EnvironmentValues()) as? _ResolvedCompositeAppearance)
        #expect(resolved.appearanceStack.isEmpty)
        #expect(!resolved.containsAsset(for: Key()))
        #expect(resolved.asset(for: Key()) == nil)
    }

    @Test
    func providerEqualityAndHashPreserveUnresolvedStack() {
        let first = Appearance(provider: SchemeProvider(lightValue: 10, darkValue: 11))
        let second = Appearance(provider: SchemeProvider(lightValue: 20, darkValue: 21))
        let array = CompositeAppearanceProvider([first, second])
        let variadic = CompositeAppearanceProvider(first, second)
        let nested = CompositeAppearanceProvider(Appearance(provider: variadic))
        #expect(array == variadic)
        #expect(Set([array, variadic]).count == 1)
        #expect(array != CompositeAppearanceProvider(second, first))
        #expect(array != CompositeAppearanceProvider(first))
        #expect(array != nested)
        let environment = EnvironmentValues()
        #expect(array.resolve(in: environment).isEqual(to: nested.resolve(in: environment)))
    }

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

    private struct SchemeProvider: AppearanceProvider {
        var lightValue: Int?
        var darkValue: Int?

        func resolve(in environment: EnvironmentValues) -> any _ResolvedAppearance {
            let value = environment.colorScheme == .light ? lightValue : darkValue
            return StubAppearance(value: value, isPresent: value != nil)
        }
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
