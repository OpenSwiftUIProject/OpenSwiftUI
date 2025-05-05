//
//  PropertyListTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

struct PropertyListTests {
    @Test
    func override() {
        // Test basic override functionality
        var basePlist = PropertyList()
        basePlist[IntKey.self] = 10
        basePlist[BoolKey.self] = true
        basePlist[StringKey.self] = "base"
        #expect(basePlist.description == #"""
        [StringKey = base, BoolKey = true, IntKey = 10]
        """#)

        var overridePlist = PropertyList()
        overridePlist[IntKey.self] = 20
        overridePlist[StringKey.self] = "override"
        #expect(overridePlist.description == #"""
        [StringKey = override, IntKey = 20]
        """#)

        // Override basePlist with overridePlist
        basePlist.override(with: overridePlist)
        #expect(basePlist[IntKey.self] == 20)
        #expect(basePlist[BoolKey.self] == true)
        #expect(basePlist[StringKey.self] == "override")
        #expect(basePlist.description == #"""
        [StringKey = override, IntKey = 20, StringKey = base, BoolKey = true, IntKey = 10]
        """#)

        // Test empty override list
        var emptyPlist = PropertyList()
        var fullPlist = PropertyList()
        fullPlist[IntKey.self] = 42
        #expect(fullPlist.description == #"""
        [IntKey = 42]
        """#)

        fullPlist.override(with: emptyPlist)
        #expect(fullPlist[IntKey.self] == 42)
        #expect(fullPlist.description == #"""
        [IntKey = 42]
        """#)

        emptyPlist.override(with: fullPlist)
        #expect(emptyPlist[IntKey.self] == 42)
        #expect(emptyPlist.description == #"""
        [IntKey = 42]
        """#)

        // Test chained overrides
        var plist1 = PropertyList()
        plist1[IntKey.self] = 1
        
        var plist2 = PropertyList()
        plist2[IntKey.self] = 2
        plist2[StringKey.self] = "two"
        
        var plist3 = PropertyList()
        plist3[IntKey.self] = 3
        plist3[BoolKey.self] = true
        
        // Chain multiple overrides
        plist1.override(with: plist2)
        plist1.override(with: plist3)
        
        // Latest override should take precedence
        #expect(plist1[IntKey.self] == 3)
        #expect(plist1[StringKey.self] == "two")
        #expect(plist1[BoolKey.self] == true)
        #expect(plist1.description == #"""
        [BoolKey = true, IntKey = 3, EmptyKey = (), StringKey = two, IntKey = 2, IntKey = 1]
        """#)

        // Test derived values after override
        var derivedBasePlist = PropertyList()
        derivedBasePlist[IntKey.self] = 5
        
        var derivedOverridePlist = PropertyList()
        derivedOverridePlist[IntKey.self] = 10
        derivedBasePlist.override(with: derivedOverridePlist)
        #expect(derivedBasePlist[DerivedIntPlus2Key.self] == 12)
        #expect(derivedBasePlist.description == #"""
        [IntKey = 10, IntKey = 5]
        """#)
    }

    @Test
    func valueWithSecondaryLookup() {
        var plist = PropertyList()
        #expect(plist.valueWithSecondaryLookup(StringFromIntLookup.self) == StringFromIntLookup.Primary.defaultValue)
        plist[StringFromIntLookup.Primary.self] = "AA"
        #expect(plist.valueWithSecondaryLookup(StringFromIntLookup.self) == "AA")
        plist[StringFromIntLookup.Secondary.self] = 42
        #expect(plist.valueWithSecondaryLookup(StringFromIntLookup.self) == "42")
        plist[StringFromIntLookup.Primary.self] = "BB"
        #expect(plist.valueWithSecondaryLookup(StringFromIntLookup.self) == "BB")
    }

    @Test
    func description() {
        var plist = PropertyList()
        #expect(plist.description == "[]")
        
        var bool = plist[BoolKey.self]
        #expect(bool == BoolKey.defaultValue)
        #expect(plist.description == "[]")
        
        plist[BoolKey.self] = bool
        #expect(plist.description == "[\(BoolKey.self) = \(bool)]")
        
        plist[BoolKey.self] = !bool
        bool = plist[BoolKey.self]
        #expect(bool == !BoolKey.defaultValue)
        #expect(plist.description == "[\(BoolKey.self) = \(bool), \(BoolKey.self) = \(BoolKey.defaultValue)]")
        
        let value = 1
        plist[IntKey.self] = value
        #expect(plist.description == "[\(IntKey.self) = \(value), \(BoolKey.self) = \(bool), \(BoolKey.self) = \(BoolKey.defaultValue)]")
    }

    @Test
    func merging() {
        var plist1 = PropertyList()
        plist1[IntKey.self] = 42
        var plist2 = PropertyList()
        plist2[StringKey.self] = "Hello"

        let plist3 = plist1.merging(plist2)
        let plist4 = plist2.merging(plist1)

        #expect(plist3.description == #"""
        [StringKey = Hello, IntKey = 42]
        """#)
        #expect(plist4.description == #"""
        [IntKey = 42, StringKey = Hello]
        """#)
    }
}

struct PropertyListTrackerTests {
    @Test
    func invalidateValue() {
        let tracker = PropertyList.Tracker()
        
        var plist = PropertyList()
        plist[IntKey.self] = 42
        plist[StringKey.self] = "original"
        tracker.initializeValues(from: plist)

        #expect(tracker.value(plist, for: IntKey.self) == 42)
        #expect(tracker.derivedValue(plist, for: DerivedIntPlus2Key.self) == 44)
        #expect(tracker.value(plist, for: StringKey.self) == "original")
        #expect(tracker.derivedValue(plist, for: DerivedStringKey.self) == "d:original")
        #expect(!tracker.hasDifferentUsedValues(plist))
        
        var newPlist = PropertyList()
        newPlist[IntKey.self] = 100
        newPlist[StringKey.self] = "modified"
        #expect(tracker.hasDifferentUsedValues(newPlist))
        
        tracker.invalidateValue(for: IntKey.self, from: plist, to: newPlist)
        
        #expect(tracker.value(newPlist, for: IntKey.self) == 100)
        #expect(tracker.derivedValue(newPlist, for: DerivedIntPlus2Key.self) == 102)
        #expect(tracker.value(newPlist, for: StringKey.self) == "original")
        #expect(tracker.derivedValue(newPlist, for: DerivedStringKey.self) == "d:modified")
    }

    @Test
    func invalidateAllValues() {
        let tracker = PropertyList.Tracker()

        var plist = PropertyList()
        plist[IntKey.self] = 42
        plist[StringKey.self] = "original"
        plist[StringFromIntLookup.Secondary.self] = 23
        tracker.initializeValues(from: plist)

        #expect(tracker.value(plist, for: IntKey.self) == 42)
        #expect(tracker.derivedValue(plist, for: DerivedIntPlus2Key.self) == 44)
        #expect(tracker.value(plist, for: StringKey.self) == "original")
        #expect(tracker.valueWithSecondaryLookup(plist, secondaryLookupHandler: StringFromIntLookup.self) == "23")
        #expect(!tracker.hasDifferentUsedValues(plist))

        var newPlist = PropertyList()
        newPlist[IntKey.self] = 100
        newPlist[StringKey.self] = "modified"
        newPlist[StringFromIntLookup.Secondary.self] = 200

        #expect(tracker.hasDifferentUsedValues(newPlist))

        tracker.invalidateAllValues(from: plist, to: newPlist)
        #expect(tracker.value(newPlist, for: IntKey.self) == 100)
        #expect(tracker.derivedValue(plist, for: DerivedIntPlus2Key.self) == 102)
        #expect(tracker.value(newPlist, for: StringKey.self) == "modified")
        #expect(tracker.valueWithSecondaryLookup(plist, secondaryLookupHandler: StringFromIntLookup.self) == "200")
    }

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

        tracker1.formUnion(tracker2)
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
