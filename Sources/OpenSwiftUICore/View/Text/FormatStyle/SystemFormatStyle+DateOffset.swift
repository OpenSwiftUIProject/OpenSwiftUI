//
//  SystemFormatStyle+DateOffset.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete [TBA]
//  ID: EF730B53907780A838381E1249B2F86C (SwiftUICore)

public import Foundation

#if canImport(Darwin)

// MARK: - FormatStyle + DateOffset

@available(OpenSwiftUI_v6_0, *)
extension FormatStyle where Self == SystemFormatStyle.DateOffset {
    /// Creates a format style that describes a date's offset from an anchor date.
    public static func offset(
        to anchor: Date,
        allowedFields: Set<Date.ComponentsFormatStyle.Field> = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second,
        ],
        maxFieldCount: Int = 2,
        sign: NumberFormatStyleConfiguration.SignDisplayStrategy = .automatic
    ) -> SystemFormatStyle.DateOffset {
        SystemFormatStyle.DateOffset(
            to: anchor,
            allowedFields: allowedFields,
            maxFieldCount: maxFieldCount,
            sign: sign
        )
    }
}

// MARK: - SystemFormatStyle.DateOffset

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle {
    /// A format style that describes a date's offset from an anchor date.
    public struct DateOffset: Sendable {
        private static let orderedFields: [Date.ComponentsFormatStyle.Field] = [
            .year,
            .month,
            .week,
            .day,
            .hour,
            .minute,
            .second,
        ]

        var anchor: Date
        var allowedFields: Set<Date.ComponentsFormatStyle.Field>
        var maxFieldCount: Int
        private var sign: NumberFormatStyleConfiguration.SignDisplayStrategy
        var sizeVariant: TextSizeVariant = .regular
        private var locale: Locale = .autoupdatingCurrent
        private var calendar: Calendar = .autoupdatingCurrent
        private var updateFrequency: TimeDataFormatting.UpdateFrequency = .high
        private var watchIdiom: Bool = false
        private var forceUnitsAoDStyle: Bool = false

        /// Creates a format style that describes a date's offset from an anchor date.
        public init(
            to anchor: Date,
            allowedFields: Set<Date.ComponentsFormatStyle.Field> = [
                .year,
                .month,
                .week,
                .day,
                .hour,
                .minute,
                .second,
            ],
            maxFieldCount: Int = 2,
            sign: NumberFormatStyleConfiguration.SignDisplayStrategy = .automatic
        ) {
            self.anchor = anchor
            self.allowedFields = allowedFields
            self.maxFieldCount = maxFieldCount
            self.sign = sign
        }

        /// Returns a copy of the style configured with the specified calendar.
        public func calendar(_ calendar: Calendar) -> SystemFormatStyle.DateOffset {
            var style = self
            style.calendar = calendar
            return style
        }
    }
}

// MARK: - SystemFormatStyle.DateOffset + FormatStyle

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle.DateOffset: FormatStyle {
    public func format(_ referenceDate: Date) -> AttributedString {
        let duration = Duration.seconds(abs(referenceDate.timeIntervalSince(anchor)))
        let fields = applicableFields(for: referenceDate)
        let smallestField = fields.prefix(effectiveMaximumFieldCount).last ?? .second
        let body: AttributedString

        if let time = timeStyle(for: referenceDate) {
            body = time.style.format(duration)
        } else if let units = unitsStyle(for: referenceDate) {
            body = units.style.format(duration)
        } else if let components = componentsStyle(for: referenceDate) {
            body = AttributedString(components.style.format(dateRange(for: referenceDate)))
        } else {
            let fallback = Duration.UnitsFormatStyle(
                allowedUnits: [.seconds],
                width: unitWidth,
                maximumUnitCount: 1,
                zeroValueUnits: .show(length: 1),
                valueLength: nil,
                fractionalPart: .hide(rounded: .towardZero)
            )
            .attributed
            .locale(locale)
            body = fallback.format(duration)
        }

        var result = body
        let prefix = signPrefix(
            for: referenceDate,
            smallestFieldShown: smallestField
        )
        if !prefix.isEmpty {
            result = AttributedString(prefix) + result
        }
        if fields.contains(.second), updateFrequency != .high {
            result.redact(for: updateFrequency, locale: locale)
        }
        return result
    }

    public func locale(_ locale: Locale) -> SystemFormatStyle.DateOffset {
        var style = self
        style.locale = locale
        return style
    }

    private var effectiveMaximumFieldCount: Int {
        if sizeVariant.rawValue > 2 {
            max(maxFieldCount + 2 - sizeVariant.rawValue, 1)
        } else {
            maxFieldCount
        }
    }

    private var unitWidth: Duration.UnitsFormatStyle.UnitWidth {
        switch sizeVariant {
        case .regular:
            .wide
        case .compact:
            .condensedAbbreviated
        default:
            .narrow
        }
    }

    private var componentsWidth: Date.ComponentsFormatStyle.Style {
        switch sizeVariant {
        case .regular:
            .wide
        case .compact:
            .condensedAbbreviated
        default:
            .narrow
        }
    }

    private var unitsConfigurationAllowsTimeStyle: Bool {
        if effectiveMaximumFieldCount == 2 {
            return allowedFields == [.minute, .second]
        }
        if effectiveMaximumFieldCount == 3 {
            return allowedFields == [.hour, .minute, .second]
        }
        return false
    }

    private func timeStyle(
        for referenceDate: Date
    ) -> (
        style: Duration.TimeFormatStyle.Attributed,
        smallestField: Date.ComponentsFormatStyle.Field
    )? {
        guard unitsConfigurationAllowsTimeStyle else {
            return nil
        }
        let pattern: Duration.TimeFormatStyle.Pattern
        if sizeVariant.rawValue >= 2 {
            pattern = .hourMinute(
                padHourToLength: 1,
                roundSeconds: .towardZero
            )
        } else if !allowedFields.contains(.hour) ||
            abs(referenceDate.timeIntervalSince(anchor)) < 3600
        {
            pattern = .minuteSecond(
                padMinuteToLength: 1,
                roundFractionalSeconds: .towardZero
            )
        } else {
            pattern = .hourMinuteSecond(
                padHourToLength: 1,
                roundFractionalSeconds: .towardZero
            )
        }

        return (
            Duration.TimeFormatStyle(pattern: pattern)
                .locale(locale)
                .grouping(.never)
                .attributed,
            .second
        )
    }

    private func unitsStyle(
        for referenceDate: Date
    ) -> (
        style: Duration.UnitsFormatStyle.Attributed,
        largestField: Date.ComponentsFormatStyle.Field,
        smallestField: Date.ComponentsFormatStyle.Field
    )? {
        let fields = applicableFields(for: referenceDate)
            .prefix(effectiveMaximumFieldCount)
        guard let largestField = fields.first,
              let smallestField = fields.last,
              fields.allSatisfy({ $0 == .hour || $0 == .minute || $0 == .second })
        else {
            return nil
        }

        let units = Set(fields.compactMap { field -> Duration.UnitsFormatStyle.Unit? in
            if field == .hour {
                .hours
            } else if field == .minute {
                .minutes
            } else if field == .second {
                .seconds
            } else {
                nil
            }
        })
        guard !units.isEmpty else {
            return nil
        }

        return (
            Duration.UnitsFormatStyle(
                allowedUnits: units,
                width: unitWidth,
                maximumUnitCount: effectiveMaximumFieldCount,
                zeroValueUnits: .show(length: 1),
                valueLength: nil,
                fractionalPart: .hide(rounded: .towardZero)
            )
            .attributed
            .locale(locale),
            largestField,
            smallestField
        )
    }

    private func componentsStyle(
        for referenceDate: Date
    ) -> (
        style: Date.ComponentsFormatStyle,
        largestField: Date.ComponentsFormatStyle.Field,
        smallestField: Date.ComponentsFormatStyle.Field
    )? {
        let fields = applicableFields(for: referenceDate)
            .prefix(effectiveMaximumFieldCount)
        guard let largestField = fields.first,
              let smallestField = fields.last
        else {
            return nil
        }

        var style = Date.ComponentsFormatStyle(
            style: componentsWidth,
            locale: locale,
            calendar: calendar,
            fields: Set(fields)
        )
        style.isPositive = true
        return (style, largestField, smallestField)
    }

    private func dateRange(for referenceDate: Date) -> Range<Date> {
        if referenceDate < anchor {
            referenceDate..<anchor
        } else {
            anchor..<referenceDate
        }
    }

    private func component(
        for field: Date.ComponentsFormatStyle.Field
    ) -> Calendar.Component {
        if field == .year {
            .year
        } else if field == .month {
            .month
        } else if field == .week {
            allowedFields.contains(.month) ? .weekOfMonth : .weekOfYear
        } else if field == .day {
            .day
        } else if field == .hour {
            .hour
        } else if field == .minute {
            .minute
        } else {
            .second
        }
    }

    private func applicableFields(
        for referenceDate: Date
    ) -> ArraySlice<Date.ComponentsFormatStyle.Field> {
        let ordered = Self.orderedFields.filter {
            allowedFields.contains($0) && $0.magnitude >= updateFrequency.magnitude
        }
        guard !ordered.isEmpty else {
            return []
        }

        let range = dateRange(for: referenceDate)
        let components = calendar.dateComponents(
            Set(ordered.map(component(for:))),
            from: range.lowerBound,
            to: range.upperBound
        )
        let firstNonzero = ordered.firstIndex {
            (components.value(for: component(for: $0)) ?? 0) != 0
        }
        let start = firstNonzero ?? ordered.index(before: ordered.endIndex)
        return ordered[start...].prefix(effectiveMaximumFieldCount)
    }

    private func needsSign(
        for referenceDate: Date,
        smallestFieldShown: Date.ComponentsFormatStyle.Field
    ) -> Bool {
        if sign == .never {
            return false
        }
        if sign == .automatic {
            return referenceDate < anchor
        }
        if sign == .always(includingZero: true) {
            return true
        }
        guard sign == .always(includingZero: false) else {
            return false
        }
        let component = component(for: smallestFieldShown)
        let range = dateRange(for: referenceDate)
        return (calendar.dateComponents(
            [component],
            from: range.lowerBound,
            to: range.upperBound
        ).value(for: component) ?? 0) != 0
    }

    private func signPrefix(
        for referenceDate: Date,
        smallestFieldShown: Date.ComponentsFormatStyle.Field
    ) -> String {
        guard needsSign(
            for: referenceDate,
            smallestFieldShown: smallestFieldShown
        ) else {
            return ""
        }
        let value = referenceDate < anchor ? -1 : (anchor < referenceDate ? 1 : 0)
        let formatted = value.formatted(
            .number.sign(strategy: sign).locale(locale)
        )
        let unsigned = abs(value).formatted(.number.locale(locale))
        guard let numberRange = formatted.range(of: unsigned) else {
            return ""
        }
        return String(formatted[..<numberRange.lowerBound]) +
            String(formatted[numberRange.upperBound...])
    }
}

// MARK: - SystemFormatStyle.DateOffset + DiscreteFormatStyle

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle.DateOffset: DiscreteFormatStyle {
    public func discreteInput(before referenceDate: Date) -> Date? {
        adjacentInput(to: referenceDate, direction: -1)
    }

    public func discreteInput(after referenceDate: Date) -> Date? {
        adjacentInput(to: referenceDate, direction: 1)
    }

    public func input(before referenceDate: Date) -> Date? {
        discreteInput(before: referenceDate)
    }

    public func input(after referenceDate: Date) -> Date? {
        discreteInput(after: referenceDate)
    }

    private func adjacentInput(to referenceDate: Date, direction: Int) -> Date? {
        let smallestField = applicableFields(for: referenceDate).last ?? .second
        return calendar.date(
            byAdding: component(for: smallestField),
            value: direction,
            to: referenceDate
        )
    }
}

// MARK: - SystemFormatStyle.DateOffset + UpdateFrequencyDependentFormatStyle

extension SystemFormatStyle.DateOffset: UpdateFrequencyDependentFormatStyle {
    package func updateFrequency(
        _ frequency: TimeDataFormatting.UpdateFrequency
    ) -> SystemFormatStyle.DateOffset {
        var style = self
        style.updateFrequency = frequency
        return style
    }
}

// MARK: - SystemFormatStyle.DateOffset + SafelySerializableDiscreteFormatStyle

extension SystemFormatStyle.DateOffset: SafelySerializableDiscreteFormatStyle {
    package static func representation<Source>(
        of resolvable: TimeDataFormatting.Resolvable<Source, SystemFormatStyle.DateOffset>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where Source: TimeDataSourceStorage, Source.Value == Date
    {
        guard version <= .v5 else {
            return resolvable
        }
        let format = resolvable.format
        var environment = EnvironmentValues()
        environment.locale = format.locale
        environment.calendar = format.calendar
        let configuration = Text.DateStyle.UnitsConfiguration(
            units: NSCalendar.Unit(format.allowedFields),
            style: format.unitWidth.unitsConfigurationStyle
        )
        let style = Text.DateStyle(
            storage: .offset,
            unitConfiguration: configuration
        )
        return ResolvableAbsoluteDate(
            resolvable.source.date(for: format.anchor),
            style: style,
            in: environment
        )
    }
}

// MARK: - SystemFormatStyle.DateOffset + InterfaceIdiomDependentFormatStyle

extension SystemFormatStyle.DateOffset: InterfaceIdiomDependentFormatStyle {
    package func interfaceIdiom(
        _ idiom: AnyInterfaceIdiom
    ) -> SystemFormatStyle.DateOffset {
        var style = self
        style.watchIdiom = idiom.accepts(ComplicationInterfaceIdiom.self) ||
            idiom.accepts(WatchInterfaceIdiom.self)
        return style
    }
}

#endif
