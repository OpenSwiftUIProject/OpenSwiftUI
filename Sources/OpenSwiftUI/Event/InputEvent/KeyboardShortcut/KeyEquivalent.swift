//
//  KeyEquivalent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

/// Key equivalents consist of a letter, punctuation, or function key that can
/// be combined with an optional set of modifier keys to specify a keyboard
/// shortcut.
///
/// Key equivalents are used to establish keyboard shortcuts to app
/// functionality. Any key can be used as a key equivalent as long as pressing
/// it produces a single character value. Key equivalents are typically
/// initialized using a single-character string literal, with constants for
/// unprintable or hard-to-type values.
///
/// The modifier keys necessary to type a key equivalent are factored in to the
/// resulting keyboard shortcut. That is, a key equivalent whose raw value is
/// the capitalized string "A" corresponds with the keyboard shortcut
/// Command-Shift-A. The exact mapping may depend on the keyboard layout—for
/// example, a key equivalent with the character value "}" produces a shortcut
/// equivalent to Command-Shift-] on ANSI keyboards, but would produce a
/// different shortcut for keyboard layouts where punctuation characters are in
/// different locations.
@available(OpenSwiftUI_v2_0, *)
// @available(tvOS 17.0, *)
@available(watchOS, unavailable)
public struct KeyEquivalent: Sendable {
    /// Up Arrow (U+F700)
    public static let upArrow: KeyEquivalent = "\u{F700}"

    /// Down Arrow (U+F701)
    public static let downArrow: KeyEquivalent = "\u{F701}"

    /// Left Arrow (U+F702)
    public static let leftArrow: KeyEquivalent = "\u{F702}"

    /// Right Arrow (U+F703)
    public static let rightArrow: KeyEquivalent = "\u{F703}"

    /// Escape (U+001B)
    public static let escape: KeyEquivalent = "\u{001B}"

    /// Delete (U+0008)
    public static let delete: KeyEquivalent = "\u{0008}"

    /// Delete Forward (U+F728)
    public static let deleteForward: KeyEquivalent = "\u{F728}"

    /// Home (U+F729)
    public static let home: KeyEquivalent = "\u{F729}"

    /// End (U+F72B)
    public static let end: KeyEquivalent = "\u{F72B}"

    /// Page Up (U+F72C)
    public static let pageUp: KeyEquivalent = "\u{F72C}"

    /// Page Down (U+F72D)
    public static let pageDown: KeyEquivalent = "\u{F72D}"

    /// Clear (U+F739)
    public static let clear: KeyEquivalent = "\u{F739}"

    /// Tab (U+0009)
    public static let tab: KeyEquivalent = "\u{0009}"

    /// Space (U+0020)
    public static let space: KeyEquivalent = "\u{0020}"

    /// Return (U+000D)
    public static let `return`: KeyEquivalent = "\u{000D}"

    /// The character value that the key equivalent represents.
    public var character: Character

    /// Creates a new key equivalent from the given character value.
    public init(_ character: Character) {
        self.character = character
    }
}

@available(OpenSwiftUI_v5_0, *)
@available(watchOS, unavailable)
extension KeyEquivalent: Hashable {}

@available(OpenSwiftUI_v2_0, *)
// @available(tvOS 17.0, *)
@available(watchOS, unavailable)
extension KeyEquivalent: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral: Character) {
        character = extendedGraphemeClusterLiteral
    }

    public typealias ExtendedGraphemeClusterLiteralType = Character
    public typealias UnicodeScalarLiteralType = Character
}
