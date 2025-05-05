//
//  PropertyListTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.0.87)
import Testing
import SwiftUI
import OpenSwiftUI
import OpenSwiftUITestsSupport

#if compiler(>=6.1) // https://github.com/swiftlang/swift/issues/81248

extension PropertyList {
    @_silgen_name("OpenSwiftUITestStub_PropertyListInit")
    init(swiftUI: Void)

    @_silgen_name("OpenSwiftUITestStub_PropertyListInitWithData")
    init(swiftUI_data: AnyObject?)

    @_silgen_name("OpenSwiftUITestStub_PropertyListOverride")
    mutating func swiftUI_override(with other: PropertyList)

    subscript<K>(swiftUI key: K.Type) -> K.Value where K: PropertyKey {
        @_silgen_name("OpenSwiftUITestStub_PropertyListSubscriptWithPropertyKeyGetter")
        get
        @_silgen_name("OpenSwiftUITestStub_PropertyListSubscriptWithPropertyKeySetter")
        set
    }

    subscript<K>(swiftUI key: K.Type) -> K.Value where K: DerivedPropertyKey {
        @_silgen_name("OpenSwiftUITestStub_PropertyListSubscriptWithDerivedPropertyKeyGetter")
        get
    }

    @_silgen_name("OpenSwiftUITestStub_PropertyListValueWithSecondaryLookup")
    func swiftUI_valueWithSecondaryLookup<L>(_ key: L.Type) -> L.Primary.Value where L: PropertyKeyLookup

    @_silgen_name("OpenSwiftUITestStub_PropertyListPrependValue")
    mutating func swiftUI_prependValue<K>(_ value: K.Value, for key: K.Type) where K: PropertyKey

    @_silgen_name("OpenSwiftUITestStub_PropertyListMayNotBeEqual")
    func swiftUI_mayNotBeEqual(to: PropertyList) -> Bool

    @_silgen_name("OpenSwiftUITestStub_PropertyListMayNotBeEqualIgnoredTypes")
    func swiftUI_mayNotBeEqual(to: PropertyList, ignoredTypes: inout [ObjectIdentifier]) -> Bool

    @_silgen_name("OpenSwiftUITestStub_PropertyListSet")
    mutating func swiftUI_set(_ other: PropertyList)

    var swiftUI_description: String {
        @_silgen_name("OpenSwiftUITestStub_PropertyListDescription")
        get
    }

    @_silgen_name("OpenSwiftUITestStub_PropertyListForEach")
    func swiftUI_forEach<K>(keyType: K.Type, _ body: (K.Value, inout Bool) -> Void) where K: PropertyKey

    @_silgen_name("OpenSwiftUITestStub_PropertyListMerge")
    mutating func swiftUI_merge(_ plist: PropertyList)

    @_silgen_name("OpenSwiftUITestStub_PropertyListMerging")
    func swiftUI_merging(_ other: PropertyList) -> PropertyList

    @_silgen_name("OpenSwiftUITestStub_PropertyListValue")
    static func swiftUI_value<T>(as _: T.Type, from element: Element) -> T
}

private struct DerivedIntPlus2Key: DerivedPropertyKey {
    static func value(in plist: PropertyList) -> Int {
        plist[swiftUI: IntKey.self] + 2
    }
}

struct PropertyListTests {
    @Test
    func override() {
        // Test basic override functionality
        var basePlist = PropertyList(swiftUI: ())
        basePlist[swiftUI: IntKey.self] = 10
        basePlist[swiftUI: BoolKey.self] = true
        basePlist[swiftUI: StringKey.self] = "base"
        #expect(basePlist.swiftUI_description == #"""
        [StringKey = base, BoolKey = true, IntKey = 10]
        """#)

        var overridePlist = PropertyList(swiftUI: ())
        overridePlist[swiftUI: IntKey.self] = 20
        overridePlist[swiftUI: StringKey.self] = "override"
        #expect(overridePlist.swiftUI_description == #"""
        [StringKey = override, IntKey = 20]
        """#)

        // Override basePlist with overridePlist
        basePlist.swiftUI_override(with: overridePlist)
        #expect(basePlist[swiftUI: IntKey.self] == 20)
        #expect(basePlist[swiftUI: BoolKey.self] == true)
        #expect(basePlist[swiftUI: StringKey.self] == "override")
        #expect(basePlist.swiftUI_description == #"""
        [StringKey = override, IntKey = 20, StringKey = base, BoolKey = true, IntKey = 10]
        """#)

        // Test empty override list
        var emptyPlist = PropertyList(swiftUI: ())
        var fullPlist = PropertyList(swiftUI: ())
        fullPlist[swiftUI: IntKey.self] = 42
        #expect(fullPlist.swiftUI_description == #"""
        [IntKey = 42]
        """#)

        fullPlist.swiftUI_override(with: emptyPlist)
        #expect(fullPlist[swiftUI: IntKey.self] == 42)
        #expect(fullPlist.swiftUI_description == #"""
        [IntKey = 42]
        """#)

        emptyPlist.swiftUI_override(with: fullPlist)
        #expect(emptyPlist[swiftUI: IntKey.self] == 42)
        #expect(emptyPlist.swiftUI_description == #"""
        [IntKey = 42]
        """#)

        // Test chained overrides
        var plist1 = PropertyList(swiftUI: ())
        plist1[swiftUI: IntKey.self] = 1
        
        var plist2 = PropertyList(swiftUI: ())
        plist2[swiftUI: IntKey.self] = 2
        plist2[swiftUI: StringKey.self] = "two"
        
        var plist3 = PropertyList(swiftUI: ())
        plist3[swiftUI: IntKey.self] = 3
        plist3[swiftUI: BoolKey.self] = true
        
        // Chain multiple overrides
        plist1.swiftUI_override(with: plist2)
        plist1.swiftUI_override(with: plist3)
        
        // Latest override should take precedence
        #expect(plist1[swiftUI: IntKey.self] == 3)
        #expect(plist1[swiftUI: StringKey.self] == "two")
        #expect(plist1[swiftUI: BoolKey.self] == true)
        #expect(plist1.swiftUI_description == #"""
        [BoolKey = true, IntKey = 3, EmptyKey = (), StringKey = two, IntKey = 2, IntKey = 1]
        """#)

        // Test derived values after override
        var derivedBasePlist = PropertyList(swiftUI: ())
        derivedBasePlist[swiftUI: IntKey.self] = 5
        
        var derivedOverridePlist = PropertyList(swiftUI: ())
        derivedOverridePlist[swiftUI: IntKey.self] = 10
        derivedBasePlist.swiftUI_override(with: derivedOverridePlist)
        #expect(derivedBasePlist[swiftUI: DerivedIntPlus2Key.self] == 12)
        #expect(derivedBasePlist.swiftUI_description == #"""
        [IntKey = 10, IntKey = 5]
        """#)
    }

    @Test
    func valueWithSecondaryLookup() {
        var plist = PropertyList(swiftUI: ())
        #expect(plist.swiftUI_valueWithSecondaryLookup(StringFromIntLookup.self) == StringFromIntLookup.Primary.defaultValue)
        plist[swiftUI: StringFromIntLookup.Primary.self] = "AA"
        #expect(plist.swiftUI_valueWithSecondaryLookup(StringFromIntLookup.self) == "AA")
        plist[swiftUI: StringFromIntLookup.Secondary.self] = 42
        #expect(plist.swiftUI_valueWithSecondaryLookup(StringFromIntLookup.self) == "42")
        plist[swiftUI: StringFromIntLookup.Primary.self] = "BB"
        #expect(plist.swiftUI_valueWithSecondaryLookup(StringFromIntLookup.self) == "BB")
    }

    @Test
    func description() {
        var plist = PropertyList(swiftUI: ())
        #expect(plist.swiftUI_description == "[]")
        
        var bool = plist[swiftUI: BoolKey.self]
        #expect(bool == BoolKey.defaultValue)
        #expect(plist.swiftUI_description == "[]")
        
        plist[swiftUI: BoolKey.self] = bool
        #expect(plist.swiftUI_description == "[\(BoolKey.self) = \(bool)]")
        
        plist[swiftUI: BoolKey.self] = !bool
        bool = plist[swiftUI: BoolKey.self]
        #expect(bool == !BoolKey.defaultValue)
        #expect(plist.swiftUI_description == "[\(BoolKey.self) = \(bool), \(BoolKey.self) = \(BoolKey.defaultValue)]")
        
        let value = 1
        plist[swiftUI: IntKey.self] = value
        #expect(plist.swiftUI_description == "[\(IntKey.self) = \(value), \(BoolKey.self) = \(bool), \(BoolKey.self) = \(BoolKey.defaultValue)]")
    }

    @Test
    func merging() {
        var plist1 = PropertyList(swiftUI: ())
        plist1[swiftUI: IntKey.self] = 42
        var plist2 = PropertyList(swiftUI: ())
        plist2[swiftUI: StringKey.self] = "Hello"

        let plist3 = plist1.swiftUI_merging(plist2)
        let plist4 = plist2.swiftUI_merging(plist1)

        #expect(plist3.swiftUI_description == #"""
        [StringKey = Hello, IntKey = 42]
        """#)
        #expect(plist4.swiftUI_description == #"""
        [IntKey = 42, StringKey = Hello]
        """#)
    }
}

extension PropertyList.Tracker {
    // FIXME: Compiler limitation
    // @_silgen_name("OpenSwiftUITestStub_PropertyListTrackerInit")
    // init(swiftUI: Void)

    @_silgen_name("OpenSwiftUITestStub_PropertyListTrackerReset")
    func swiftUI_reset()

    @_silgen_name("OpenSwiftUITestStub_PropertyListTrackerValue")
    func swiftUI_value<K>(_ plist: PropertyList, for key: K.Type) -> K.Value where K: PropertyKey

    @_silgen_name("OpenSwiftUITestStub_PropertyListTrackerValueWithSecondaryLookup")
    func swiftUI_valueWithSecondaryLookup<Lookup>(_ plist: PropertyList, secondaryLookupHandler: Lookup.Type) -> Lookup.Primary.Value where Lookup: PropertyKeyLookup

    @_silgen_name("OpenSwiftUITestStub_PropertyListTrackerDerivedValue")
    func swiftUI_derivedValue<K>(_ plist: PropertyList, for key: K.Type) -> K.Value where K: DerivedPropertyKey

    @_silgen_name("OpenSwiftUITestStub_PropertyListTrackerInitializeValues")
    func swiftUI_initializeValues(from plist: PropertyList)

    @_silgen_name("OpenSwiftUITestStub_PropertyListTrackerInvalidateValue")
    func swiftUI_invalidateValue<K>(for key: K.Type, from oldPlist: PropertyList, to newPlist: PropertyList) where K: PropertyKey

    @_silgen_name("OpenSwiftUITestStub_PropertyListTrackerInvalidateAllValues")
    func swiftUI_invalidateAllValues(from oldPlist: PropertyList, to newPlist: PropertyList)

    @_silgen_name("OpenSwiftUITestStub_PropertyListTrackerHasDifferentUsedValues")
    func swiftUI_hasDifferentUsedValues(_ plist: PropertyList) -> Bool

    @_silgen_name("OpenSwiftUITestStub_PropertyListTrackerFormUnion")
    func swiftUI_formUnion(_ other: PropertyList.Tracker)
}

struct PropertyListTrackerTests {
    @Test
    func invalidateValue() {
        let tracker = PropertyList.Tracker()

        var plist = PropertyList(swiftUI: ())
        plist[swiftUI: IntKey.self] = 42
        plist[swiftUI: StringKey.self] = "original"
        tracker.swiftUI_initializeValues(from: plist)

        #expect(tracker.swiftUI_value(plist, for: IntKey.self) == 42)
        #expect(tracker.swiftUI_derivedValue(plist, for: DerivedIntPlus2Key.self) == 44)
        #expect(tracker.swiftUI_value(plist, for: StringKey.self) == "original")
        #expect(tracker.swiftUI_derivedValue(plist, for: DerivedStringKey.self) == "d:original")
        #expect(!tracker.swiftUI_hasDifferentUsedValues(plist))

        var newPlist = PropertyList(swiftUI: ())
        newPlist[swiftUI: IntKey.self] = 100
        newPlist[swiftUI: StringKey.self] = "modified"
        #expect(tracker.swiftUI_hasDifferentUsedValues(newPlist))

        tracker.swiftUI_invalidateValue(for: IntKey.self, from: plist, to: newPlist)
        #expect(tracker.swiftUI_value(newPlist, for: IntKey.self) == 100)
        #expect(tracker.swiftUI_derivedValue(newPlist, for: DerivedIntPlus2Key.self) == 102)
        #expect(tracker.swiftUI_value(newPlist, for: StringKey.self) == "original")
        #expect(tracker.swiftUI_derivedValue(newPlist, for: DerivedStringKey.self) == "d:modified")
    }

    @Test
    func invalidateAllValues() {
        let tracker = PropertyList.Tracker()

        var plist = PropertyList()
        plist[swiftUI: IntKey.self] = 42
        plist[swiftUI: StringKey.self] = "original"
        plist[swiftUI: StringFromIntLookup.Secondary.self] = 23
        tracker.swiftUI_initializeValues(from: plist)

        #expect(tracker.swiftUI_value(plist, for: IntKey.self) == 42)
        #expect(tracker.swiftUI_derivedValue(plist, for: DerivedIntPlus2Key.self) == 44)
        #expect(tracker.swiftUI_value(plist, for: StringKey.self) == "original")
        #expect(tracker.swiftUI_valueWithSecondaryLookup(plist, secondaryLookupHandler: StringFromIntLookup.self) == "23")
        #expect(!tracker.swiftUI_hasDifferentUsedValues(plist))

        var newPlist = PropertyList()
        newPlist[swiftUI: IntKey.self] = 100
        newPlist[swiftUI: StringKey.self] = "modified"
        newPlist[swiftUI: StringFromIntLookup.Secondary.self] = 200

        #expect(tracker.swiftUI_hasDifferentUsedValues(newPlist))

        tracker.swiftUI_invalidateAllValues(from: plist, to: newPlist)
        #expect(tracker.swiftUI_value(newPlist, for: IntKey.self) == 100)
        #expect(tracker.swiftUI_derivedValue(newPlist, for: DerivedIntPlus2Key.self) == 102)
        #expect(tracker.swiftUI_value(newPlist, for: StringKey.self) == "modified")
        #expect(tracker.swiftUI_valueWithSecondaryLookup(newPlist, secondaryLookupHandler: StringFromIntLookup.self) == "200")
    }

    @Test
    func formUnion() {
        let tracker1 = PropertyList.Tracker()
        var plist1 = PropertyList(swiftUI: ())
        plist1[swiftUI: IntKey.self] = 23
        plist1[swiftUI: BoolKey.self] = true
        tracker1.swiftUI_initializeValues(from: plist1)
        #expect(tracker1.swiftUI_value(plist1, for: IntKey.self) == 23)
        #expect(tracker1.swiftUI_value(plist1, for: BoolKey.self) == true)

        let tracker2 = PropertyList.Tracker()
        var plist2 = PropertyList(swiftUI: ())
        plist2[swiftUI: IntKey.self] = 42
        plist2[swiftUI: StringKey.self] = "2"
        tracker2.swiftUI_initializeValues(from: plist2)
        #expect(tracker2.swiftUI_value(plist2, for: IntKey.self) == 42)
        #expect(tracker2.swiftUI_value(plist2, for: StringKey.self) == "2")

        tracker1.swiftUI_formUnion(tracker2)
        #expect(tracker1.swiftUI_value(plist2, for: IntKey.self) == 23)
        #expect(tracker1.swiftUI_value(plist2, for: BoolKey.self) == true)
        #expect(tracker1.swiftUI_value(plist2, for: StringKey.self) == "2")

        #expect(tracker1.swiftUI_value(plist1, for: IntKey.self) == 23)
        #expect(tracker1.swiftUI_value(plist1, for: BoolKey.self) == true)
        #expect(tracker1.swiftUI_value(plist1, for: StringKey.self) == "")

        plist1[swiftUI: IntKey.self] = 24
        plist2[swiftUI: IntKey.self] = 25
        #expect(tracker1.swiftUI_value(plist1, for: IntKey.self) == 24)
        #expect(tracker1.swiftUI_value(plist2, for: IntKey.self) == 25)
    }
}

#endif

#endif
