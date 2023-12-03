//
//  AnyAccessibilityValueType.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/2.
//  Lastest Version: iOS 15.5
//  Status: Complete

enum AnyAccessibilityValueType: UInt, Codable {
    case int
    case double
    case bool
    case string
//    case disclosure
//    case toggle
//    case slider
//    case stepper
//    case progress
    case boundedNumber
//    case headingLevel
    case number
}
