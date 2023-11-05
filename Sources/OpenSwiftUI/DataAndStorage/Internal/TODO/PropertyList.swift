//
//  PropertyList.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/18.
//  Lastest Version: iOS 15.5
//  Status: Empty
//  ID: 2B32D570B0B3D2A55DA9D4BFC1584D20

@usableFromInline
@frozen
struct PropertyList: CustomStringConvertible {
    @usableFromInline
    var elements: Element?
  
    @inlinable
    init() { elements = nil }
  
    @usableFromInline
    var description: String {
        "TODO"
    }
}

extension PropertyList {
    @usableFromInline
    class Element: CustomStringConvertible {
        let keyType: Any.Type
        let before: Element?
        let after: Element?
        let length: Int
        let keyFilter: BloomFilter
        let id: UniqueID

        init(keyType: Any.Type, before: Element?, after: Element?, length: Int, keyFilter: BloomFilter, id: UniqueID) {
            self.keyType = keyType
            self.before = before
            self.after = after
            self.length = length
            self.keyFilter = keyFilter
            self.id = id
        }

        @usableFromInline
        var description: String {
            ""
        }

        /*@objc*/
        @usableFromInline
        deinit {}

        func byPrepending(_ element: Element?) -> Element {
            self
        }
    }
}

// extension PropertyList {
//    class Tracker {
//        @UnsafeLockedPointer
//        var data: TrackerData
//    }
// }
