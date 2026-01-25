//
//  PreferenceListDualTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

// MARK: - Common PreferenceKeys

private struct AKey: PreferenceKey {
    static let defaultValue = 0
    static func reduce(value _: inout Int, nextValue _: () -> Int) {}
    static var _includesRemovedValues: Bool { true }
}

private struct BKey: PreferenceKey {
    static let defaultValue = 0
    static func reduce(value _: inout Int, nextValue _: () -> Int) {}
}

private struct CKey: PreferenceKey {
    static let defaultValue = 0
    static func reduce(value _: inout Int, nextValue _: () -> Int) {}
    static var _includesRemovedValues: Bool { true }
}

private struct DKey: PreferenceKey {
    static let defaultValue = 0
    static func reduce(value _: inout Int, nextValue _: () -> Int) {}
}

private struct PrefIntKey: PreferenceKey {
    static var defaultValue: Int { 0 }

    static func reduce(value: inout Int, nextValue: () -> Int) {
        value += nextValue()
    }
}

private struct PrefDoubleKey: PreferenceKey {
    static var defaultValue: Double { 0.0 }

    static func reduce(value: inout Double, nextValue: () -> Double) {
        value += nextValue()
    }
}

private struct PrefEnumKey: PreferenceKey {
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }

    enum Value: Sendable { case a, b }
    static var defaultValue: Value { .a }
}

// MARK: - PreferenceValues SwiftUI Extensions

extension PreferenceValues {
    @_silgen_name("OpenSwiftUITestStub_PreferenceValuesInit")
    init(swiftUI: Void)

    subscript<K>(swiftUI key: K.Type) -> Value<K.Value> where K: PreferenceKey {
        @_silgen_name("OpenSwiftUITestStub_PreferenceValuesSubscriptGetter")
        get
        @_silgen_name("OpenSwiftUITestStub_PreferenceValuesSubscriptSetter")
        set
    }

    @_silgen_name("OpenSwiftUITestStub_PreferenceValuesValueIfPresent")
    func swiftUI_valueIfPresent<K>(for key: K.Type = K.self) -> Value<K.Value>? where K: PreferenceKey

    @_silgen_name("OpenSwiftUITestStub_PreferenceValuesContains")
    func swiftUI_contains<K>(_ key: K.Type) -> Bool where K: PreferenceKey

    @_silgen_name("OpenSwiftUITestStub_PreferenceValuesRemoveValue")
    mutating func swiftUI_removeValue<K>(for key: K.Type) where K: PreferenceKey

    @_silgen_name("OpenSwiftUITestStub_PreferenceValuesModifyValue")
    mutating func swiftUI_modifyValue<K>(for key: K.Type, transform: Value<(inout K.Value) -> Void>) where K: PreferenceKey

    @_silgen_name("OpenSwiftUITestStub_PreferenceValuesMayNotBeEqual")
    func swiftUI_mayNotBeEqual(to other: PreferenceValues) -> Bool

    var swiftUI_seed: VersionSeed {
        @_silgen_name("OpenSwiftUITestStub_PreferenceValuesSeedGetter")
        get
    }

    @_silgen_name("OpenSwiftUITestStub_PreferenceValuesCombine")
    mutating func swiftUI_combine(with other: PreferenceValues)

    var swiftUI_description: String {
        @_silgen_name("OpenSwiftUITestStub_PreferenceValuesDescription")
        get
    }
}

// MARK: - PreferenceValuesDualTests

struct PreferenceValuesDualTests {
    // MARK: - Basic Operations

    @Test
    func initCreatesEmpty() {
        let values = PreferenceValues(swiftUI: ())
        #expect(values.swiftUI_description == "empty: []")
        #expect(values.swiftUI_seed.isEmpty)
    }

    @Test
    func contains() {
        var values = PreferenceValues(swiftUI: ())
        #expect(values.swiftUI_contains(PrefIntKey.self) == false)
        values[swiftUI: PrefIntKey.self] = .init(value: 42, seed: .init(value: 1))
        #expect(values.swiftUI_contains(PrefIntKey.self) == true)
    }

    @Test(arguments: [
        (false, false),  // empty -> not present
        (true, true),    // has value -> present
    ])
    func valueIfPresent(hasValue: Bool, expectPresent: Bool) {
        var values = PreferenceValues(swiftUI: ())
        if hasValue {
            values[swiftUI: PrefIntKey.self] = .init(value: 42, seed: .init(value: 1))
        }
        let value = values.valueIfPresent(for: PrefIntKey.self)
        #expect((value != nil) == expectPresent)
    }

    @Test
    func removeValue() {
        var values = PreferenceValues(swiftUI: ())
        values[swiftUI: PrefIntKey.self] = .init(value: 42, seed: .init(value: 1))
        #expect(values.swiftUI_contains(PrefIntKey.self) == true)
        values.swiftUI_removeValue(for: PrefIntKey.self)
        #expect(values.swiftUI_contains(PrefIntKey.self) == false)
    }

    @Test(arguments: [
        (10, UInt32(1), 5, 15),  // existing value + transform
        (0, UInt32(0), 5, 5),    // default value + transform (no initial set)
    ])
    func modifyValue(initialValue: Int, initialSeed: UInt32, addAmount: Int, expected: Int) {
        var values = PreferenceValues(swiftUI: ())
        if initialSeed != 0 {
            values[swiftUI: PrefIntKey.self] = .init(value: initialValue, seed: .init(value: initialSeed))
        }
        values.swiftUI_modifyValue(for: PrefIntKey.self, transform: .init(value: { $0 += addAmount }, seed: .init(value: 1)))
        #expect(values[swiftUI: PrefIntKey.self].value == expected)
    }

    // MARK: - Seed Tests

    @Test
    func seedIsEmptyForEmptyValues() {
        let values = PreferenceValues(swiftUI: ())
        #expect(values.swiftUI_seed.isEmpty)
    }

    @Test
    func seedReflectsSingleValue() {
        var values = PreferenceValues(swiftUI: ())
        values[swiftUI: PrefIntKey.self] = .init(value: 1, seed: .init(value: 42))
        #expect(values.swiftUI_seed.matches(VersionSeed(value: 42)))
    }

    // Note: mayNotBeEqual uses seed.matches() which returns false for invalid seeds
    @Test(arguments: [
        (VersionSeed.empty, VersionSeed.empty, false),
        (VersionSeed.empty, VersionSeed.invalid, true),
        (VersionSeed.invalid, VersionSeed.empty, true),
        (VersionSeed.invalid, VersionSeed.invalid, true),
        (VersionSeed(value: 1), VersionSeed(value: 1), false),
        (VersionSeed(value: 1), VersionSeed(value: 2), true),
    ])
    func mayNotBeEqual(seed1: VersionSeed, seed2: VersionSeed, expected: Bool) {
        var values1 = PreferenceValues(swiftUI: ())
        var values2 = PreferenceValues(swiftUI: ())
        values1[swiftUI: PrefIntKey.self] = .init(value: 1, seed: seed1)
        values2[swiftUI:PrefIntKey.self] = .init(value: 1, seed: seed2)
        #expect(values1.swiftUI_mayNotBeEqual(to: values2) == expected)
    }

    // MARK: - Combine Tests

    @Test(arguments: [
        // (values1IntValue, values1Seed, values2IntValue, values2Seed, expectedIntValue, expectedDescription)
        (nil as Int?, UInt32(0), nil as Int?, UInt32(0), 0, "empty: []"),
        (10, UInt32(1), nil as Int?, UInt32(0), 10, "1: [PrefInt = 10]"),
        (nil as Int?, UInt32(0), 20, UInt32(1), 20, "1: [PrefInt = 20]"),
        (10, UInt32(1), 20, UInt32(2), 10, "547159728: [PrefInt = 30]"),
    ])
    func combine(
        values1Value: Int?,
        values1Seed: UInt32,
        values2Value: Int?,
        values2Seed: UInt32,
        expectedIntValue: Int,
        expectedDescription: String
    ) {
        var values1 = PreferenceValues(swiftUI: ())
        var values2 = PreferenceValues(swiftUI: ())
        if let v = values1Value {
            values1[swiftUI: PrefIntKey.self] = .init(value: v, seed: .init(value: values1Seed))
        }
        if let v = values2Value {
            values2[swiftUI: PrefIntKey.self] = .init(value: v, seed: .init(value: values2Seed))
        }
        values1.swiftUI_combine(with: values2)
        #expect(values1[swiftUI: PrefIntKey.self].value == expectedIntValue)
        #expect(values1.swiftUI_description == expectedDescription)
    }

    @Test
    func combineComplex() {
        // values1: A=1, B=2, C=3
        // values2: C=30, D=4, A=10
        // After combine: A, B, C, D with values based on combine behavior
        var values1 = PreferenceValues(swiftUI: ())
        var values2 = PreferenceValues(swiftUI: ())

        values1[swiftUI: AKey.self] = .init(value: 1, seed: .init(value: 1))
        values1[swiftUI: BKey.self] = .init(value: 2, seed: .init(value: 2))
        values1[swiftUI: CKey.self] = .init(value: 3, seed: .init(value: 3))

        values2[swiftUI: CKey.self] = .init(value: 30, seed: .init(value: 4))
        values2[swiftUI: DKey.self] = .init(value: 4, seed: .init(value: 5))
        values2[swiftUI: AKey.self] = .init(value: 10, seed: .init(value: 6))

        values1.swiftUI_combine(with: values2)
        #expect(values1.swiftUI_description == "2589144168: [A = 1, B = 2, C = 3, D = 4]")
    }

    // MARK: - Filter and Description Tests

    // @Test
    // func filterRemoved() {
    //     var values = PreferenceValues(swiftUI: ())
    //     values[swiftUI: AKey.self] = .init(value: 0, seed: .invalid)
    //     values[swiftUI: BKey.self] = .init(value: 1, seed: .init(value: 1))
    //     values[swiftUI: CKey.self] = .init(value: 2, seed: .init(value: 2))
    //     #expect(values.swiftUI_description == "invalid: [A = 0, B = 1, C = 2]")
    //     values.swiftUI_filterRemoved()
    //     #expect(values.swiftUI_description == "invalid: [C = 2, A = 0]")
    // }

    @Test(arguments: [
        (2, 2, "invalid: [A = 2]"),
    ])
    func description(aValue: Int, bValue: Int, expectedDescription: String) {
        var values = PreferenceValues(swiftUI: ())
        values[swiftUI: AKey.self] = .init(value: aValue, seed: .invalid)
        values[swiftUI: BKey.self] = .init(value: bValue, seed: .empty)
        #expect(values.swiftUI_description == expectedDescription)
    }

    @Test
    func subscriptWithZeroSeed() {
        var values = PreferenceValues(swiftUI: ())
        values[swiftUI: PrefIntKey.self] = .init(value: 1, seed: .empty)
        values[swiftUI: PrefDoubleKey.self] = .init(value: 1.0, seed: .empty)
        values[swiftUI: PrefEnumKey.self] = .init(value: .a, seed: .empty)
        // Empty seed means values are not stored
        #expect(values.swiftUI_description == "empty: []")
    }

    @Test(arguments: [
        (UInt32(1), UInt32(2), UInt32(3), "3634229150: [PrefIntKey = 2, PrefDoubleKey = 1.0]"),
    ])
    func subscriptWithSeed(intSeed: UInt32, doubleSeed: UInt32, intSeed2: UInt32, expectedDescription: String) {
        var values = PreferenceValues(swiftUI: ())
        values[swiftUI: PrefIntKey.self] = .init(value: 1, seed: .init(value: intSeed))
        values[swiftUI: PrefDoubleKey.self] = .init(value: 1.0, seed: .init(value: doubleSeed))
        values[swiftUI: PrefIntKey.self] = .init(value: 2, seed: .init(value: intSeed2))
        #expect(values.swiftUI_description == expectedDescription)
    }
}


#endif
