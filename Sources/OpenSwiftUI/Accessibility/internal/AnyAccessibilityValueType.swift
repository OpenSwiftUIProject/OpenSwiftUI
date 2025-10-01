//
//  AnyAccessibilityValueType.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Complete

enum AnyAccessibilityValueType: UInt, Codable {
    case int
    case double
    case bool
    case string
//    case disclosure
//    case toggle
    case slider
//    case stepper
//    case progress
    case boundedNumber
//    case headingLevel
    case number
}
