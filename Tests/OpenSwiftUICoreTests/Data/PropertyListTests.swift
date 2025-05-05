//
//  PropertyListTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

struct PropertyListTests {
    @Test
    func description() throws {
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
