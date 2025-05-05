//
//  PropertyListTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.0.87)
import Testing
import SwiftUI
import OpenSwiftUI
import OpenSwiftUITestsSupport

#if compiler(>=6.1) // https://github.com/swiftlang/swift/issues/81248

extension PropertyList.Tracker {
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
    func formUnion() {
        let tracker1 = PropertyList.Tracker()
        var plist1 = PropertyList()
        plist1[IntKey.self] = 23
        plist1[BoolKey.self] = true
        tracker1.initializeValues(from: plist1)
        #expect(tracker1.value(plist1, for: IntKey.self) == 23)
        #expect(tracker1.value(plist1, for: BoolKey.self) == true)

        let tracker2 = PropertyList.Tracker()
        var plist2 = PropertyList()
        plist2[IntKey.self] = 42
        plist2[StringKey.self] = "2"
        tracker2.initializeValues(from: plist2)
        #expect(tracker2.value(plist2, for: IntKey.self) == 42)
        #expect(tracker2.value(plist2, for: StringKey.self) == "2")

        tracker1.swiftUI_formUnion(tracker2)
        #expect(tracker1.value(plist2, for: IntKey.self) == 23)
        #expect(tracker1.value(plist2, for: BoolKey.self) == true)
        #expect(tracker1.value(plist2, for: StringKey.self) == "2")

        #expect(tracker1.value(plist1, for: IntKey.self) == 23)
        #expect(tracker1.value(plist1, for: BoolKey.self) == true)
        #expect(tracker1.value(plist1, for: StringKey.self) == "")

        plist1[IntKey.self] = 24
        plist2[IntKey.self] = 25
        #expect(tracker1.value(plist1, for: IntKey.self) == 24)
        #expect(tracker1.value(plist2, for: IntKey.self) == 25)
    }
}

#endif

#endif
