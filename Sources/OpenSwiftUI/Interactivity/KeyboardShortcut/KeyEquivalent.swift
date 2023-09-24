//
//  KeyEquivalent.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/24.
//  Lastest Version: iOS 15.5
//  Status: Complete

import Foundation

@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct KeyEquivalent {
    public static let upArrow: KeyEquivalent = "\u{F700}"
    public static let downArrow: KeyEquivalent = "\u{F701}"
    public static let leftArrow: KeyEquivalent = "\u{F702}"
    public static let rightArrow: KeyEquivalent = "\u{F703}"
    public static let escape: KeyEquivalent = "\u{001B}"
    public static let delete: KeyEquivalent = "\u{0008}"
    public static let deleteForward: KeyEquivalent = "\u{F728}"
    public static let home: KeyEquivalent = "\u{F729}"
    public static let end: KeyEquivalent = "\u{F72B}"
    public static let pageUp: KeyEquivalent = "\u{F72C}"
    public static let pageDown: KeyEquivalent = "\u{F72D}"
    public static let clear: KeyEquivalent = "\u{F739}"
    public static let tab: KeyEquivalent = "\u{0009}"
    public static let space: KeyEquivalent = "\u{0020}"
    public static let `return`: KeyEquivalent = "\u{000D}"

    public var character: Character
    public init(_ character: Character) {
        self.character = character
    }
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension KeyEquivalent: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral: Character) {
        character = extendedGraphemeClusterLiteral
    }

    public typealias ExtendedGraphemeClusterLiteralType = Character
    public typealias UnicodeScalarLiteralType = Character
}
