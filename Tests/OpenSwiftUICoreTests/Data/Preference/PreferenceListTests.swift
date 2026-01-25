//
//  PreferenceListTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
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

#if OPENSWIFTUI_PREFERENCELIST

// MARK: - PreferenceListTests

struct PreferenceListTests {
    // MARK: - Basic Operations

    @Test
    func initCreatesEmpty() {
        let list = PreferenceList()
        #expect(list.description == "empty: []")
        #expect(list.seed.isEmpty)
    }

    @Test
    func contains() {
        var list = PreferenceList()
        #expect(list.contains(PrefIntKey.self) == false)
        list[PrefIntKey.self] = .init(value: 42, seed: .init(value: 1))
        #expect(list.contains(PrefIntKey.self) == true)
    }

    @Test(arguments: [
        (false, true),   // empty list -> not present
        (true, true),    // has value -> present
    ])
    func valueIfPresent(hasValue: Bool, expectNonNil: Bool) {
        var list = PreferenceList()
        if hasValue {
            list[PrefIntKey.self] = .init(value: 42, seed: .init(value: 1))
        }
        let value = list.valueIfPresent(for: PrefIntKey.self)
        #expect((value != nil) == (hasValue && expectNonNil))
    }

    @Test
    func removeValue() {
        var list = PreferenceList()
        list[PrefIntKey.self] = .init(value: 42, seed: .init(value: 1))
        #expect(list.contains(PrefIntKey.self) == true)
        list.removeValue(for: PrefIntKey.self)
        #expect(list.contains(PrefIntKey.self) == false)
    }

    @Test(arguments: [
        (10, UInt32(1), 5, 15),  // existing value + transform
        (0, UInt32(0), 5, 5),    // default value + transform (no initial set)
    ])
    func modifyValue(initialValue: Int, initialSeed: UInt32, addAmount: Int, expected: Int) {
        var list = PreferenceList()
        if initialSeed != 0 {
            list[PrefIntKey.self] = .init(value: initialValue, seed: .init(value: initialSeed))
        }
        list.modifyValue(for: PrefIntKey.self, transform: .init(value: { $0 += addAmount }, seed: .init(value: 1)))
        #expect(list[PrefIntKey.self].value == expected)
    }

    // MARK: - Seed Tests

    @Test
    func seedIsEmptyForEmptyList() {
        let list = PreferenceList()
        #expect(list.seed.isEmpty)
    }

    @Test
    func seedReflectsSingleValue() {
        var list = PreferenceList()
        list[PrefIntKey.self] = .init(value: 1, seed: .init(value: 42))
        #expect(list.seed.matches(VersionSeed(value: 42)))
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
        var list1 = PreferenceList()
        var list2 = PreferenceList()
        list1[PrefIntKey.self] = .init(value: 1, seed: seed1)
        list2[PrefIntKey.self] = .init(value: 1, seed: seed2)
        #expect(list1.mayNotBeEqual(to: list2) == expected)
    }

    // MARK: - Combine Tests

    @Test(arguments: [
        // (list1IntValue, list1Seed, list2IntValue, list2Seed, expectedIntValue, expectedDescription)
        (nil as Int?, UInt32(0), nil as Int?, UInt32(0), 0, "empty: []"),
        (10, UInt32(1), nil as Int?, UInt32(0), 10, "1: [PrefIntKey = 10]"),
        (nil as Int?, UInt32(0), 20, UInt32(1), 20, "1: [PrefIntKey = 20]"),
        (10, UInt32(1), 20, UInt32(2), 30, "547159728: [PrefIntKey = 30]"),
    ])
    func combine(
        list1Value: Int?,
        list1Seed: UInt32,
        list2Value: Int?,
        list2Seed: UInt32,
        expectedIntValue: Int,
        expectedDescription: String
    ) {
        var list1 = PreferenceList()
        var list2 = PreferenceList()
        if let v = list1Value {
            list1[PrefIntKey.self] = .init(value: v, seed: .init(value: list1Seed))
        }
        if let v = list2Value {
            list2[PrefIntKey.self] = .init(value: v, seed: .init(value: list2Seed))
        }
        list1.combine(with: list2)
        #expect(list1[PrefIntKey.self].value == expectedIntValue)
        #expect(list1.description == expectedDescription)
    }

    // MARK: - Filter and Description Tests

    @Test
    func filterRemoved() {
        var list = PreferenceList()
        list[AKey.self] = .init(value: 0, seed: .invalid)
        list[BKey.self] = .init(value: 1, seed: .init(value: 1))
        list[CKey.self] = .init(value: 2, seed: .init(value: 2))
        #expect(list.description == "invalid: [CKey = 2, BKey = 1, AKey = 0]")
        list.filterRemoved()
        #expect(list.description == "invalid: [AKey = 0, CKey = 2]")
    }

    @Test(arguments: [
        (2, 2, "invalid: [BKey = 2, AKey = 2]"),
    ])
    func description(aValue: Int, bValue: Int, expectedDescription: String) {
        var list = PreferenceList()
        list[AKey.self] = .init(value: aValue, seed: .invalid)
        list[BKey.self] = .init(value: bValue, seed: .empty)
        #expect(list.description == expectedDescription)
    }

    @Test
    func subscriptWithZeroSeed() {
        var list = PreferenceList()
        list[PrefIntKey.self] = .init(value: 1, seed: .empty)
        list[PrefDoubleKey.self] = .init(value: 1.0, seed: .empty)
        list[PrefEnumKey.self] = .init(value: .a, seed: .empty)
        #expect(list.description == "empty: [PrefEnumKey = a, PrefDoubleKey = 1.0, PrefIntKey = 1]")
    }

    @Test(arguments: [
        (UInt32(1), UInt32(2), UInt32(3), "3634229150: [PrefIntKey = 2, PrefDoubleKey = 1.0]"),
    ])
    func subscriptWithSeed(intSeed: UInt32, doubleSeed: UInt32, intSeed2: UInt32, expectedDescription: String) {
        var list = PreferenceList()
        list[PrefIntKey.self] = .init(value: 1, seed: .init(value: intSeed))
        list[PrefDoubleKey.self] = .init(value: 1.0, seed: .init(value: doubleSeed))
        list[PrefIntKey.self] = .init(value: 2, seed: .init(value: intSeed2))
        #expect(list.description == expectedDescription)
    }
}

#endif

// MARK: - PreferenceValuesTests

struct PreferenceValuesTests {
    // MARK: - Basic Operations

    @Test
    func initCreatesEmpty() {
        let values = PreferenceValues()
        #expect(values.description == "empty: []")
        #expect(values.seed.isEmpty)
    }

    @Test
    func contains() {
        var values = PreferenceValues()
        #expect(values.contains(PrefIntKey.self) == false)
        values[PrefIntKey.self] = .init(value: 42, seed: .init(value: 1))
        #expect(values.contains(PrefIntKey.self) == true)
    }

    @Test(arguments: [
        (false, false),  // empty -> not present
        (true, true),    // has value -> present
    ])
    func valueIfPresent(hasValue: Bool, expectPresent: Bool) {
        var values = PreferenceValues()
        if hasValue {
            values[PrefIntKey.self] = .init(value: 42, seed: .init(value: 1))
        }
        let value = values.valueIfPresent(for: PrefIntKey.self)
        #expect((value != nil) == expectPresent)
    }

    @Test
    func removeValue() {
        var values = PreferenceValues()
        values[PrefIntKey.self] = .init(value: 42, seed: .init(value: 1))
        #expect(values.contains(PrefIntKey.self) == true)
        values.removeValue(for: PrefIntKey.self)
        #expect(values.contains(PrefIntKey.self) == false)
    }

    @Test(arguments: [
        (10, UInt32(1), 5, 15),  // existing value + transform
        (0, UInt32(0), 5, 5),    // default value + transform (no initial set)
    ])
    func modifyValue(initialValue: Int, initialSeed: UInt32, addAmount: Int, expected: Int) {
        var values = PreferenceValues()
        if initialSeed != 0 {
            values[PrefIntKey.self] = .init(value: initialValue, seed: .init(value: initialSeed))
        }
        values.modifyValue(for: PrefIntKey.self, transform: .init(value: { $0 += addAmount }, seed: .init(value: 1)))
        #expect(values[PrefIntKey.self].value == expected)
    }

    // MARK: - Seed Tests

    @Test
    func seedIsEmptyForEmptyValues() {
        let values = PreferenceValues()
        #expect(values.seed.isEmpty)
    }

    @Test
    func seedReflectsSingleValue() {
        var values = PreferenceValues()
        values[PrefIntKey.self] = .init(value: 1, seed: .init(value: 42))
        #expect(values.seed.matches(VersionSeed(value: 42)))
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
        var values1 = PreferenceValues()
        var values2 = PreferenceValues()
        values1[PrefIntKey.self] = .init(value: 1, seed: seed1)
        values2[PrefIntKey.self] = .init(value: 1, seed: seed2)
        #expect(values1.mayNotBeEqual(to: values2) == expected)
    }

    // MARK: - Combine Tests

    @Test(arguments: [
        // (values1IntValue, values1Seed, values2IntValue, values2Seed, expectedIntValue, expectedDescription)
        (nil as Int?, UInt32(0), nil as Int?, UInt32(0), 0, "empty: []"),
        (10, UInt32(1), nil as Int?, UInt32(0), 10, "1: [PrefInt = 10]"),
        (nil as Int?, UInt32(0), 20, UInt32(1), 20, "1: [PrefInt = 20]"),
        (10, UInt32(1), 20, UInt32(2), 30, "547159728: [PrefInt = 30]"),
    ])
    func combine(
        values1Value: Int?,
        values1Seed: UInt32,
        values2Value: Int?,
        values2Seed: UInt32,
        expectedIntValue: Int,
        expectedDescription: String
    ) {
        var values1 = PreferenceValues()
        var values2 = PreferenceValues()
        if let v = values1Value {
            values1[PrefIntKey.self] = .init(value: v, seed: .init(value: values1Seed))
        }
        if let v = values2Value {
            values2[PrefIntKey.self] = .init(value: v, seed: .init(value: values2Seed))
        }
        values1.combine(with: values2)
        // known issue 10, "1: [PrefInt = 10]")
        #expect(values1[PrefIntKey.self].value == expectedIntValue)
        #expect(values1.description == expectedDescription)
    }

    @Test
    func combineComplex() {
        // values1: A=1, B=2, C=3
        // values2: C=30, D=4, A=10
        // After combine: A, B, C, D with values based on combine behavior
        var values1 = PreferenceValues()
        var values2 = PreferenceValues()

        values1[AKey.self] = .init(value: 1, seed: .init(value: 1))
        values1[BKey.self] = .init(value: 2, seed: .init(value: 2))
        values1[CKey.self] = .init(value: 3, seed: .init(value: 3))

        values2[CKey.self] = .init(value: 30, seed: .init(value: 4))
        values2[DKey.self] = .init(value: 4, seed: .init(value: 5))
        values2[AKey.self] = .init(value: 10, seed: .init(value: 6))

        values1.combine(with: values2)
        #expect(values1.description == "2589144168: [A = 1, B = 2, C = 3, D = 4]")
    }

    // MARK: - Filter and Description Tests

    @Test
    func filterRemoved() {
        var values = PreferenceValues()
        values[AKey.self] = .init(value: 0, seed: .invalid)
        values[BKey.self] = .init(value: 1, seed: .init(value: 1))
        values[CKey.self] = .init(value: 2, seed: .init(value: 2))
        #expect(values.description == "invalid: [A = 0, B = 1, C = 2]")
        values.filterRemoved()
        #expect(values.description == "invalid: [C = 2, A = 0]")
    }

    @Test(arguments: [
        (2, 2, "invalid: [A = 2]"),
    ])
    func description(aValue: Int, bValue: Int, expectedDescription: String) {
        var values = PreferenceValues()
        values[AKey.self] = .init(value: aValue, seed: .invalid)
        values[BKey.self] = .init(value: bValue, seed: .empty)
        #expect(values.description == expectedDescription)
    }

    @Test
    func subscriptWithZeroSeed() {
        var values = PreferenceValues()
        values[PrefIntKey.self] = .init(value: 1, seed: .empty)
        values[PrefDoubleKey.self] = .init(value: 1.0, seed: .empty)
        values[PrefEnumKey.self] = .init(value: .a, seed: .empty)
        // Empty seed means values are not stored
        #expect(values.description == "empty: []")
    }

    @Test(arguments: [
        (UInt32(1), UInt32(2), UInt32(3), "398988569: [PrefInt = 2, PrefDouble = 1.0]"),
    ])
    func subscriptWithSeed(intSeed: UInt32, doubleSeed: UInt32, intSeed2: UInt32, expectedDescription: String) {
        var values = PreferenceValues()
        values[PrefIntKey.self] = .init(value: 1, seed: .init(value: intSeed))
        values[PrefDoubleKey.self] = .init(value: 1.0, seed: .init(value: doubleSeed))
        values[PrefIntKey.self] = .init(value: 2, seed: .init(value: intSeed2))
        #expect(values.description == expectedDescription)
    }
}
