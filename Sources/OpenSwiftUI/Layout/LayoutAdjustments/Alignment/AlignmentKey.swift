//
//  AlignmentKey.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/17.
//  Lastest Version: iOS 15.5
//  Status: Complete
//  ID: E20796D15DD3D417699102559E024115

@usableFromInline
@frozen
struct AlignmentKey: Hashable, Comparable {
    private let bits: UInt

    @usableFromInline
    static func < (lhs: AlignmentKey, rhs: AlignmentKey) -> Bool {
        lhs.bits < rhs.bits
    }

    @UnsafeLockedPointer
    private static var typeCache = TypeCache(typeIDs: [:], types: [])

    struct TypeCache {
        var typeIDs: [ObjectIdentifier: UInt]
        var types: [AlignmentID.Type]
    }

    init(id: AlignmentID.Type, axis: Axis) {
        if let bits = AlignmentKey.typeCache.typeIDs[ObjectIdentifier(id)] {
            self.bits = bits
        } else {
            let bits = UInt(AlignmentKey.typeCache.types.count)
            AlignmentKey.typeCache.types.append(id)
            AlignmentKey.typeCache.typeIDs[ObjectIdentifier(id)] = bits
            self.bits = bits
        }
    }
}
