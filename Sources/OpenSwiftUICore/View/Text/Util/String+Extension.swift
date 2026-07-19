//
//  String+Extension.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - String + Extension

extension String {
    package static var nsAttachment: String {
        "\u{FFFC}"
    }

    package init(_ attributedString: AttributedString) {
        self.init(attributedString.characters)
    }
}

// MARK: - Character + Extension

extension Character {
    package static var nsAttachment: Character {
        Character(.nsAttachment)
    }
}

// MARK: - AttributedString + Extension

extension AttributedString {
    package var isEmpty: Bool {
        characters.isEmpty
    }
}

// MARK: - NSAttributedString.Key + Kit Extension

extension NSAttributedString.Key {
    static let kitFont: NSAttributedString.Key = .init("NSFont")

    static let kitParagraphStyle: NSAttributedString.Key = .init("NSParagraphStyle")

    static let kitForegroundColor: NSAttributedString.Key = .init("NSColor")

    static let kitBackgroundColor: NSAttributedString.Key = .init("NSBackgroundColor")

    static let kitKern: NSAttributedString.Key = .init("NSKern")

    static let kitTracking: NSAttributedString.Key = .init("CTTracking")

    static let kitStrikethroughStyle: NSAttributedString.Key = .init("NSStrikethrough")

    static let kitUnderlineStyle: NSAttributedString.Key = .init("NSUnderline")

    static let kitShadow: NSAttributedString.Key = .init("NSShadow")

    static let kitAttachment: NSAttributedString.Key = .init("NSAttachment")

    static let kitLink: NSAttributedString.Key = .init("NSLink")

    static let kitBaselineOffset: NSAttributedString.Key = .init("NSBaselineOffset")

    static let kitUnderlineColor: NSAttributedString.Key = .init("NSUnderlineColor")

    static let kitStrikethroughColor: NSAttributedString.Key = .init("NSStrikethroughColor")
}

#if canImport(CoreText)
import CoreText

extension NSAttributedString {
    func kitFont(at index: Int) -> CTFont? {
        attribute(.kitFont, at: index, effectiveRange: nil) as! CTFont?
    }
}
#endif
