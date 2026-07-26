//
//  NSAttributedString+Extension.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation
package import UIFoundation_Private

// MARK: - NSAttributedString + Extension

extension NSAttributedString {
    package var range: NSRange {
        NSRange(location: 0, length: length)
    }

    package func firstAttribute<T>(_ type: T.Type, name: NSAttributedString.Key) -> T? {
        var result: T?
        enumerateAttribute(name, in: range) { value, _, stop in
            guard let value = value as? T else {
                return
            }
            result = value
            stop.pointee = true
        }
        return result
    }
}

extension NSAttributedString {
    package func replacingLineBreakModes(_ newMode: NSLineBreakMode) -> NSAttributedString {
        var result: NSMutableAttributedString?
        enumerateAttribute(.kitParagraphStyle, in: range) { value, range, _ in
            guard let style = value as? NSParagraphStyle,
                  style.lineBreakMode != newMode
            else {
                return
            }
            let newStyle = style.mutableCopy() as! NSMutableParagraphStyle
            newStyle.lineBreakMode = newMode
            if result == nil {
                result = mutableCopy() as? NSMutableAttributedString
            }
            guard let result else {
                return
            }
            result.addAttribute(.kitParagraphStyle, value: newStyle, range: range)
        }
        return result ?? self
    }
}

// MARK: - NSMutableAttributedString + Extension

extension NSMutableAttributedString {
    package func addUniformAttribute(_ name: NSAttributedString.Key, value: Any) {
        addAttribute(name, value: value, range: range)
    }

    package func addUniformAttributes(_ attributes: NSAttributedStringAttributes) {
        addAttributes(attributes, range: range)
    }
}

extension NSMutableAttributedString {
    /// Replaces the attributes of `range` with `attrs`, preserving the
    /// attributes that were already present.
    package func mergeAttributes(_ attrs: NSAttributedStringAttributes, in range: NSRange? = nil) {
        let range = range ?? self.range
        guard range.length != 0 else {
            return
        }
        var existing: [NSRange: NSAttributedStringAttributes] = [:]
        enumerateAttributes(in: range) { attributes, range, _ in
            existing[range] = attributes
        }
        setAttributes(attrs, range: range)
        for (range, attributes) in existing {
            addAttributes(attributes, range: range)
        }
    }
}

// MARK: - NSAttributedString.Runs

extension NSAttributedString {
    package typealias Runs = [(range: NSRange, attributes: NSAttributedStringAttributes)]

    package func runs(in range: NSRange? = nil) -> Runs {
        var runs: Runs = []
        enumerateAttributes(in: range ?? self.range) { attributes, range, _ in
            runs.append((range: range, attributes: attributes))
        }
        return runs
    }
}
