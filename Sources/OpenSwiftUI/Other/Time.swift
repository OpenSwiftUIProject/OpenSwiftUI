//
//  Time.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/16.
//  Lastest Version: iOS 15.5
//  Status: Complete

import Foundation

struct Time: Comparable, Hashable {
    var seconds : Double

    static func < (lhs: Time, rhs: Time) -> Bool {
        lhs.seconds < rhs.seconds
    }

    static var infinity: Time { Time(seconds: .infinity) }
}
