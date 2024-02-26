//
//  Time.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

struct Time: Comparable, Hashable {
    var seconds : Double

    static func < (lhs: Time, rhs: Time) -> Bool {
        lhs.seconds < rhs.seconds
    }

    static let zero = Time(seconds: .zero)
    static let infinity = Time(seconds: .infinity)
}
