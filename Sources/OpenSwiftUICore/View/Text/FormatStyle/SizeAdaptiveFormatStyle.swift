//
//  SizeAdaptiveFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP (Blocked by SystemFormatStyle)

package import Foundation

protocol SizeAdaptiveFormatStyle: FormatStyle {
    func withSizeVariant(_ sizeVariant: TextSizeVariant) -> (style: Self, exact: Bool)
}

extension FormatStyle {
    package func exactSizeVariant(_ sizeVariant: TextSizeVariant) -> (style: Self, exact: Bool) {
        guard let style = self as? any SizeAdaptiveFormatStyle else {
            return (self, sizeVariant == .regular)
        }
        let resolved = style.withSizeVariant(sizeVariant)
        return (resolved.style as! Self, resolved.exact)
    }

    package func sizeVariant(_ sizeVariant: TextSizeVariant) -> Self {
        exactSizeVariant(sizeVariant).style
    }
}

extension TextSizeVariant {
    @discardableResult
    package mutating func adjust() -> Bool {
        if rawValue != 0 {
            rawValue -= 1
        }
        return rawValue == 0
    }
}

// TODO: Add concrete conformance implementations when the matching format
// styles land:
// Date.FormatStyle
// Date.FormatStyle.Attributed
// Date.AnchoredRelativeFormatStyle
// Date.ComponentsFormatStyle
// Date.ISO8601FormatStyle
// Duration.UnitsFormatStyle
// Duration.UnitsFormatStyle.Attributed
// WhitespaceRemovingFormatStyle where A: SizeAdaptiveFormatStyle
// SystemFormatStyle.DateReference
