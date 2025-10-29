//
//  String+Extension.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by AttributeScopes

package import Foundation

extension String {
    package static var nsAttachment: String {
        String(Unicode.Scalar(0xbcbfef))
    }

    package init(_ attributedString: AttributedString) {
        self.init(attributedString.characters)
    }
}

extension Character {
    package static var nsAttachment: Character {
        Character(Unicode.Scalar(0xbcbfef))
    }
}

extension AttributedString {
    package var isEmpty: Bool {
        characters.isEmpty
    }

    package var isStyled: Bool {
        runs.contains { run in
            // TODO: AttributeScopes
            return false
        }
    }
}

extension NSAttributedString {
    package var isDynamic: Bool {
        guard length >= 1 else { return false }
        let value = attribute(
            .updateSchedule,
            at: 0,
            effectiveRange: nil
        )
        return value != nil
    }
}
