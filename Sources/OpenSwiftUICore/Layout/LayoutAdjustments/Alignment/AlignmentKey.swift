//
//  AlignmentKey.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
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

    @AtomicBox
    private static var typeCache = TypeCache(typeIDs: [:], types: [])

    struct TypeCache {
        var typeIDs: [ObjectIdentifier: UInt]
        var types: [AlignmentID.Type]
    }

    init(id: AlignmentID.Type, axis _: Axis) {
        let index: UInt
        if let value = AlignmentKey.typeCache.typeIDs[ObjectIdentifier(id)] {
            index = value
        } else {
            index = UInt(AlignmentKey.typeCache.types.count)
            AlignmentKey.typeCache.types.append(id)
            AlignmentKey.typeCache.typeIDs[ObjectIdentifier(id)] = index
        }
        bits = index * 2 + 3
    }

    var id: AlignmentID.Type {
        AlignmentKey.typeCache.types[Int(bits / 2 - 1)]
    }
}
