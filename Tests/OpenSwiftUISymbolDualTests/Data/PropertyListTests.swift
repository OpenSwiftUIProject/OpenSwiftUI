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
    func valueWithSecondaryLookup<L>(_ key: L.Type) -> L.Primary.Value where L: PropertyKeyLookup
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
        #expect(tracker.swiftUI_derivedValue(plist, for: DerivedIntPlus2Key.self) == 102)
        #expect(tracker.swiftUI_value(newPlist, for: StringKey.self) == "modified")
        #expect(tracker.swiftUI_valueWithSecondaryLookup(plist, secondaryLookupHandler: StringFromIntLookup.self) == "200")
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
