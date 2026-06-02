//
//  String+Extension.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package import Foundation

extension String {
    package static var nsAttachment: String {
        "\u{FFFC}"
    }

    package init(_ attributedString: AttributedString) {
        self.init(attributedString.characters)
    }
}

extension Character {
    package static var nsAttachment: Character {
        Character(.nsAttachment)
    }
}

extension AttributedString {
    package var isEmpty: Bool {
        characters.isEmpty
    }

    package var isStyled: Bool {
        runs.contains { run in
            #if canImport(CoreText)
            let hasAdaptiveImageGlyph = run.adaptiveImageGlyph != nil
            #endif
            if run.font != nil {
                return true
            }
            if run.foregroundColor != nil {
                return true
            }
            if run.backgroundColor != nil {
                return true
            }
            if run.strikethroughStyle != nil {
                return true
            }
            if run.underlineStyle != nil {
                return true
            }
            if run.kern != nil {
                return true
            }
            if run.tracking != nil {
                return true
            }
            if run.baselineOffset != nil {
                return true
            }
            if run.textScale != nil {
                return true
            }
            if run.superscript != nil {
                return true
            }
            if run.privateStrikethroughColor != nil {
                return true
            }
            if run.privateUnderlineColor != nil {
                return true
            }
            if let inlinePresentationIntent = run.inlinePresentationIntent,
               !inlinePresentationIntent.intersection([
                   .emphasized,
                   .stronglyEmphasized,
                   .strikethrough,
                   .code,
               ]).isEmpty {
                return true
            }
            if run.link != nil {
                return true
            }
            #if canImport(CoreText)
            if hasAdaptiveImageGlyph {
                return true
            }
            #endif
            return false
        }
    }
}

extension NSAttributedString {
    convenience package init(openSwiftUIAttributedString attributedString: AttributedString) {
        _openSwiftUIUnimplementedFailure()
    }

    package var isDynamic: Bool {
        guard length >= 1 else { return false }
        let value = attribute(
            .updateSchedule,
            at: 0,
            effectiveRange: nil
        )
        return value != nil
    }
    
    var updateSchedule: any TimelineSchedule {
        _openSwiftUIUnimplementedFailure()
    }
}
