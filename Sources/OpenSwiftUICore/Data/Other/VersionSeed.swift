//
//  VersionSeed.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

package struct VersionSeed: CustomStringConvertible {
    @inlinable
    package static var invalid: VersionSeed { VersionSeed(value: .max) }
    
    @inlinable
    package static var empty: VersionSeed { VersionSeed(value: .zero) }
    
    @inlinable
    package var isInvalid: Bool { value == VersionSeed.invalid.value }
    
    @inline(__always)
    var isEmpty: Bool { value == VersionSeed.empty.value }
    
    var value: UInt32
    
    @inlinable
    package init(nodeId: UInt32, viewSeed: UInt32) {
        self.init(value: merge32(nodeId, viewSeed))
    }
    
    @inlinable
    package init(value: UInt32) {
        self.value = value
    }
    
    @inlinable
    package func matches(_ other: VersionSeed) -> Bool {
        !isInvalid && !other.isInvalid && value == other.value
    }
    
    package mutating func merge(_ other: VersionSeed) {
        guard !isInvalid, !other.isEmpty else {
            return
        }
        guard !isEmpty, !other.isInvalid else {
            self = other
            return
        }
        value = merge32(value, other.value)
    }
    
    package mutating func mergeValue(_ other: UInt32) {
        guard !isInvalid else { return }
        guard !isEmpty else {
            value = other
            return
        }
        value = merge32(value, other)
    }

    package var description: String {
        switch value {
        case VersionSeed.empty.value: "empty"
        case VersionSeed.invalid.value: "invalid"
        default: value.description
        }
    }
}

//  ID: 1B00D77CE2C80F9C0F5A59FDEA30ED6B (RELEASE_2021)
//  ID: F99DF4753FB5F5765C388695646E450B (RELEASE_2024)
private func merge32(_ a: UInt32, _ b: UInt32) -> UInt32 {
    let a = UInt64(a)
    let b = UInt64(b)
    var c = b
    c &+= .max ^ (c &<< 32)
    c &+= a &<< 32
    c ^= (c &>> 22)
    c &+= .max ^ (c &<< 13)
    c ^= (c &>> 8)
    c &+= (c &<< 3)
    c ^= (c >> 15)
    c &+= .max ^ (c &<< 27)
    c ^= (c &>> 31)
    return UInt32(truncatingIfNeeded: c)
}
