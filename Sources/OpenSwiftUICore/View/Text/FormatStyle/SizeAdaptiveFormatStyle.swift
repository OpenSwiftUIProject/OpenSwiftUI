//
//  SizeAdaptiveFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: CA37E3C3F7F1C6899F053124F23A58BF (SwiftUICore)

package import Foundation

private protocol SizeAdaptiveFormatStyle: FormatStyle {
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

#if canImport(Darwin)

// MARK: - Date.FormatStyle + SizeAdaptiveFormatStyle

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
private let dateFormatStyleFieldRemovals: [
    (Date.FormatStyle) -> Date.FormatStyle
] = [
    { $0.era(.omitted) },
    { $0.quarter(.omitted) },
    { $0.week(.omitted) },
    { $0.dayOfYear(.omitted) },
    { $0.secondFraction(.omitted) },
    { $0.weekday(.omitted) },
    { $0.timeZone(.omitted) },
    { $0.second(.omitted) },
    { $0.minute(.omitted) },
    { $0.hour(.omitted) },
    { $0.day(.omitted) },
    { $0.month(.omitted) },
    { $0.year(.omitted) },
]

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.FormatStyle: SizeAdaptiveFormatStyle {
    fileprivate func withSizeVariant(
        _ sizeVariant: TextSizeVariant
    ) -> (style: Date.FormatStyle, exact: Bool) {
        Self.adapt(
            self,
            to: sizeVariant,
            fieldRemovals: dateFormatStyleFieldRemovals,
            addEra: { $0.era(.abbreviated) },
            removeEra: { $0.era(.omitted) },
            addYear: { $0.year(.defaultDigits) },
            removeYear: { $0.year(.omitted) }
        )
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.FormatStyle {
    fileprivate static func adapt<Style>(
        _ style: Style,
        to sizeVariant: TextSizeVariant,
        fieldRemovals: [(Style) -> Style],
        addEra: (Style) -> Style,
        removeEra: (Style) -> Style,
        addYear: (Style) -> Style,
        removeYear: (Style) -> Style
    ) -> (style: Style, exact: Bool) where Style: Equatable {
        guard sizeVariant != .regular else {
            return (style, true)
        }

        let emptyStyle = fieldRemovals.reduce(style) { style, removal in
            removal(style)
        }
        var currentStyle = style
        if style != emptyStyle,
           removeEra(addEra(style)) == emptyStyle,
           removeYear(addYear(style)) == emptyStyle
        {
            currentStyle = removeEra(style)
        }

        var remainingVariant = sizeVariant
        for removal in fieldRemovals {
            let nextStyle = removal(currentStyle)
            guard nextStyle != emptyStyle else {
                return (currentStyle, false)
            }
            guard nextStyle != currentStyle else {
                continue
            }
            currentStyle = nextStyle
            if remainingVariant.adjust() {
                return (currentStyle, true)
            }
        }
        return (currentStyle, false)
    }
}

// MARK: - Date.FormatStyle.Attributed + SizeAdaptiveFormatStyle

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
private let attributedDateFormatStyleFieldRemovals: [
    (Date.FormatStyle.Attributed) -> Date.FormatStyle.Attributed
] = [
    { $0.era(.omitted) },
    { $0.quarter(.omitted) },
    { $0.week(.omitted) },
    { $0.dayOfYear(.omitted) },
    { $0.secondFraction(.omitted) },
    { $0.weekday(.omitted) },
    { $0.timeZone(.omitted) },
    { $0.second(.omitted) },
    { $0.minute(.omitted) },
    { $0.hour(.omitted) },
    { $0.day(.omitted) },
    { $0.month(.omitted) },
    { $0.year(.omitted) },
]

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
extension Date.FormatStyle.Attributed: SizeAdaptiveFormatStyle {
    fileprivate func withSizeVariant(
        _ sizeVariant: TextSizeVariant
    ) -> (style: Date.FormatStyle.Attributed, exact: Bool) {
        Date.FormatStyle.adapt(
            self,
            to: sizeVariant,
            fieldRemovals: attributedDateFormatStyleFieldRemovals,
            addEra: { $0.era(.abbreviated) },
            removeEra: { $0.era(.omitted) },
            addYear: { $0.year(.defaultDigits) },
            removeYear: { $0.year(.omitted) }
        )
    }
}

#endif

// MARK: - WhitespaceRemovingFormatStyle + SizeAdaptiveFormatStyle

extension WhitespaceRemovingFormatStyle: SizeAdaptiveFormatStyle where Format: SizeAdaptiveFormatStyle {
    fileprivate func withSizeVariant(
        _ sizeVariant: TextSizeVariant
    ) -> (style: WhitespaceRemovingFormatStyle<Format, Key>, exact: Bool) {
        let resolved = base.withSizeVariant(sizeVariant)
        var style = self
        style.base = resolved.style
        return (style, resolved.exact)
    }
}

#if canImport(Darwin)

// MARK: - Date.ISO8601FormatStyle + SizeAdaptiveFormatStyle

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.ISO8601FormatStyle: SizeAdaptiveFormatStyle {
    fileprivate func withSizeVariant(
        _ sizeVariant: TextSizeVariant
    ) -> (style: Date.ISO8601FormatStyle, exact: Bool) {
        guard sizeVariant != .regular else {
            return (self, true)
        }
        let style = dateSeparator(.omitted)
            .timeSeparator(.omitted)
            .timeZoneSeparator(.omitted)
        return (style, sizeVariant == .compact && style != self)
    }
}

// MARK: - Date.ComponentsFormatStyle + SizeAdaptiveFormatStyle

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.ComponentsFormatStyle: SizeAdaptiveFormatStyle {
    fileprivate func withSizeVariant(
        _ sizeVariant: TextSizeVariant
    ) -> (style: Date.ComponentsFormatStyle, exact: Bool) {
        var style = self
        var remainingVariant = sizeVariant
        while remainingVariant != .regular {
            guard let nextStyle = style.style.nextSmaller else {
                return (style, false)
            }
            style.style = nextStyle
            if remainingVariant.adjust() {
                return (style, true)
            }
        }
        return (style, true)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.ComponentsFormatStyle.Style {
    fileprivate var nextSmaller: Date.ComponentsFormatStyle.Style? {
        if self == .spellOut {
            .wide
        } else if self == .wide {
            .condensedAbbreviated
        } else if self == .condensedAbbreviated || self == .abbreviated {
            .narrow
        } else {
            nil
        }
    }
}

// MARK: - Duration.UnitsFormatStyle + SizeAdaptiveFormatStyle

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Duration.UnitsFormatStyle: SizeAdaptiveFormatStyle {
    fileprivate func withSizeVariant(
        _ sizeVariant: TextSizeVariant
    ) -> (style: Duration.UnitsFormatStyle, exact: Bool) {
        var style = self
        var remainingVariant = sizeVariant
        while remainingVariant != .regular {
            if let nextWidth = style.unitWidth.nextSmaller {
                style.unitWidth = nextWidth
                if remainingVariant.adjust() {
                    return (style, true)
                }
                continue
            }

            if style.fractionalPartDisplay.maximumLength >= 1 {
                style.fractionalPartDisplay.maximumLength = 0
                if remainingVariant.adjust() {
                    return (style, true)
                }
            }

            let maximumUnitCount = min(
                style.maximumUnitCount ?? .max,
                style.allowedUnits.count
            )
            guard remainingVariant.rawValue < maximumUnitCount else {
                style.maximumUnitCount = 1
                return (style, false)
            }
            style.maximumUnitCount = maximumUnitCount - remainingVariant.rawValue
            return (style, true)
        }
        return (style, true)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Duration.UnitsFormatStyle.UnitWidth {
    fileprivate var nextSmaller: Duration.UnitsFormatStyle.UnitWidth? {
        if self == .wide {
            .condensedAbbreviated
        } else if self == .abbreviated || self == .condensedAbbreviated {
            .narrow
        } else {
            nil
        }
    }
}

// MARK: - Duration.UnitsFormatStyle.Attributed + SizeAdaptiveFormatStyle

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Duration.UnitsFormatStyle.Attributed: SizeAdaptiveFormatStyle {
    fileprivate func withSizeVariant(
        _ sizeVariant: TextSizeVariant
    ) -> (style: Duration.UnitsFormatStyle.Attributed, exact: Bool) {
        var style = self
        var remainingVariant = sizeVariant
        while remainingVariant != .regular {
            if let nextWidth = style.unitWidth.nextSmaller {
                style.unitWidth = nextWidth
                if remainingVariant.adjust() {
                    return (style, true)
                }
                continue
            }

            if style.fractionalPartDisplay.maximumLength >= 1 {
                style.fractionalPartDisplay.maximumLength = 0
                if remainingVariant.adjust() {
                    return (style, true)
                }
            }

            let maximumUnitCount = min(
                style.maximumUnitCount ?? .max,
                style.allowedUnits.count
            )
            guard remainingVariant.rawValue < maximumUnitCount else {
                style.maximumUnitCount = 1
                return (style, false)
            }
            style.maximumUnitCount = maximumUnitCount - remainingVariant.rawValue
            return (style, true)
        }
        return (style, true)
    }
}

// MARK: - Date.AnchoredRelativeFormatStyle + SizeAdaptiveFormatStyle

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
extension Date.AnchoredRelativeFormatStyle: SizeAdaptiveFormatStyle {
    fileprivate func withSizeVariant(
        _ sizeVariant: TextSizeVariant
    ) -> (style: Date.AnchoredRelativeFormatStyle, exact: Bool) {
        var style = self
        var remainingVariant = sizeVariant
        while remainingVariant != .regular {
            guard let nextStyle = style.unitsStyle.nextSmaller else {
                return (style, false)
            }
            style.unitsStyle = nextStyle
            if remainingVariant.adjust() {
                return (style, true)
            }
        }
        return (style, true)
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
extension Date.RelativeFormatStyle.UnitsStyle {
    fileprivate var nextSmaller: Date.RelativeFormatStyle.UnitsStyle? {
        if self == .spellOut {
            .wide
        } else if self == .wide {
            .abbreviated
        } else if self == .abbreviated {
            .narrow
        } else {
            nil
        }
    }
}

#endif

// MARK: - SystemFormatStyle.Stopwatch + SizeAdaptiveFormatStyle

extension SystemFormatStyle.Stopwatch: SizeAdaptiveFormatStyle {
    fileprivate func withSizeVariant(
        _ sizeVariant: TextSizeVariant
    ) -> (style: SystemFormatStyle.Stopwatch, exact: Bool) {
        let resolved = base.withSizeVariant(sizeVariant)
        return (
            SystemFormatStyle.Stopwatch(base: resolved.style),
            resolved.style.sizeVariant.rawValue < 6
        )
    }
}

// MARK: - SystemFormatStyle.Timer + SizeAdaptiveFormatStyle

extension SystemFormatStyle.Timer: SizeAdaptiveFormatStyle {
    fileprivate func withSizeVariant(
        _ sizeVariant: TextSizeVariant
    ) -> (style: SystemFormatStyle.Timer, exact: Bool) {
        var style = self
        style.sizeVariant.rawValue += sizeVariant.rawValue

        let originalSizeVariant = self.sizeVariant.rawValue
        let expectedFieldCountReduction =
            sizeVariant.rawValue - max(originalSizeVariant - 2, 0)
        guard style.sizeVariant.rawValue >= 3 else {
            return (style, true)
        }

        let originalMaximumFieldCount = if originalSizeVariant >= 3 {
            max(maxFieldCount + 2 - originalSizeVariant, 1)
        } else {
            maxFieldCount
        }
        let maximumFieldCount = max(
            style.maxFieldCount + 2 - style.sizeVariant.rawValue,
            1
        )
        return (
            style,
            originalMaximumFieldCount - maximumFieldCount ==
                expectedFieldCountReduction
        )
    }
}

// MARK: - SystemFormatStyle.DateOffset + SizeAdaptiveFormatStyle

#if canImport(Darwin)

extension SystemFormatStyle.DateOffset: SizeAdaptiveFormatStyle {
    fileprivate func withSizeVariant(
        _ sizeVariant: TextSizeVariant
    ) -> (style: SystemFormatStyle.DateOffset, exact: Bool) {
        var style = self
        style.sizeVariant.rawValue += sizeVariant.rawValue

        let originalSizeVariant = self.sizeVariant.rawValue
        let expectedFieldCountReduction =
            sizeVariant.rawValue - max(originalSizeVariant - 2, 0)
        guard style.sizeVariant.rawValue >= 3 else {
            return (style, true)
        }

        let originalMaximumFieldCount = if originalSizeVariant >= 3 {
            max(maxFieldCount + 2 - originalSizeVariant, 1)
        } else {
            maxFieldCount
        }
        let maximumFieldCount = max(
            style.maxFieldCount + 2 - style.sizeVariant.rawValue,
            1
        )
        return (
            style,
            originalMaximumFieldCount - maximumFieldCount ==
                expectedFieldCountReduction
        )
    }
}

// MARK: - SystemFormatStyle.DateReference + SizeAdaptiveFormatStyle

extension SystemFormatStyle.DateReference: SizeAdaptiveFormatStyle {
    fileprivate func withSizeVariant(
        _ sizeVariant: TextSizeVariant
    ) -> (style: SystemFormatStyle.DateReference, exact: Bool) {
        var style = self
        style.sizeVariant.rawValue += sizeVariant.rawValue

        let originalSizeVariant = self.sizeVariant.rawValue
        let expectedFieldCountReduction =
            sizeVariant.rawValue - max(originalSizeVariant - 2, 0)
        guard style.sizeVariant.rawValue >= 3 else {
            return (style, true)
        }

        let originalMaximumFieldCount = if originalSizeVariant >= 3 {
            max(maxFieldCount + 2 - originalSizeVariant, 1)
        } else {
            maxFieldCount
        }
        let maximumFieldCount = max(
            style.maxFieldCount + 2 - style.sizeVariant.rawValue,
            1
        )
        return (
            style,
            originalMaximumFieldCount - maximumFieldCount ==
                expectedFieldCountReduction
        )
    }
}

#endif
