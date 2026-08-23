//
//  SystemFormatStyle+DateReference.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete [TBA]
//  ID: 0A25013825A6CD0C62E7E6395BAC0B1E (SwiftUICore)

public import Foundation

#if canImport(Darwin)

// MARK: - FormatStyle + DateReference

@available(OpenSwiftUI_v6_0, *)
extension FormatStyle where Self == SystemFormatStyle.DateReference {
    /// Creates a format style that describes a date relative to a reference date.
    public static func reference(
        to date: Date,
        allowedFields: Set<Date.ComponentsFormatStyle.Field> = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
        ],
        maxFieldCount: Int = 2,
        thresholdField: Date.ComponentsFormatStyle.Field = .day
    ) -> SystemFormatStyle.DateReference {
        SystemFormatStyle.DateReference(
            to: date,
            allowedFields: allowedFields,
            maxFieldCount: maxFieldCount,
            thresholdField: thresholdField
        )
    }
}

// MARK: - SystemFormatStyle.DateReference

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle {
    /// A format style that describes a date relative to a reference date.
    public struct DateReference: Sendable {
        private static let orderedFields: [Date.ComponentsFormatStyle.Field] = [
            .year,
            .month,
            .week,
            .day,
            .hour,
            .minute,
            .second,
        ]

        var date: Date
        var allowedFields: [Date.ComponentsFormatStyle.Field]
        var maxFieldCount: Int
        private var thresholdField: Date.ComponentsFormatStyle.Field
        var sizeVariant: TextSizeVariant = .regular
        private var locale: Locale = .autoupdatingCurrent
        private var calendar: Calendar = .autoupdatingCurrent
        var timeZone: TimeZone = .autoupdatingCurrent
        private var capitalizationContext: FormatStyleCapitalizationContext = .unknown

        /// Creates a format style that describes a date relative to a reference date.
        public init(
            to date: Date,
            allowedFields: Set<Date.ComponentsFormatStyle.Field> = [
                .year,
                .month,
                .day,
                .hour,
                .minute,
            ],
            maxFieldCount: Int = 2,
            thresholdField: Date.ComponentsFormatStyle.Field = .day
        ) {
            self.date = date
            self.allowedFields = Self.orderedFields.filter {
                allowedFields.contains($0) || $0 == thresholdField
            }
            self.maxFieldCount = maxFieldCount
            self.thresholdField = thresholdField
        }

        /// Returns a copy of the style configured with the specified calendar.
        public func calendar(_ calendar: Calendar) -> SystemFormatStyle.DateReference {
            var style = self
            style.calendar = calendar
            return style
        }
    }
}

// MARK: - SystemFormatStyle.DateReference + FormatStyle

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle.DateReference: FormatStyle {
    public func format(_ referenceDate: Date) -> AttributedString {
        if relativeStyleInterval?.contains(referenceDate) != false {
            return relativeText(for: referenceDate)
        }
        return absoluteStyle(for: referenceDate).format(date)
    }

    public func locale(_ locale: Locale) -> SystemFormatStyle.DateReference {
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

    private var relativeStyleInterval: ClosedRange<Date>? {
        guard let thresholdIndex = allowedFields.firstIndex(of: thresholdField),
              thresholdIndex != allowedFields.startIndex
        else {
            return nil
        }
        let container = allowedFields[allowedFields.index(before: thresholdIndex)]
        guard let interval = calendar.dateInterval(
            of: component(for: container),
            for: date
        ) else {
            return nil
        }
        return interval.start.addingTimeInterval(-0.5)...interval.end.addingTimeInterval(-0.5)
    }

    private var relativeStyle: Date.AnchoredRelativeFormatStyle {
        let unitsStyle: Date.RelativeFormatStyle.UnitsStyle = switch sizeVariant {
        case .regular:
            .wide
        case .compact:
            .abbreviated
        default:
            .narrow
        }
        return Date.AnchoredRelativeFormatStyle(
            anchor: date,
            allowedFields: Set(allowedFields),
            presentation: .named,
            unitsStyle: unitsStyle,
            locale: locale,
            calendar: calendar,
            capitalizationContext: capitalizationContext
        )
    }

    private func absoluteStyle(
        for referenceDate: Date
    ) -> Date.FormatStyle.Attributed {
        var style = Date.FormatStyle(
            date: nil,
            time: nil,
            locale: locale,
            calendar: calendar,
            timeZone: timeZone,
            capitalizationContext: capitalizationContext
        )
        for field in fieldsToShowInAbsoluteStyle(for: referenceDate) {
            add(field, to: &style)
        }
        return style.attributedStyle
    }

    private func relativeText(for referenceDate: Date) -> AttributedString {
        AttributedString(relativeStyle.format(referenceDate))
    }

    private func fieldsToShowInAbsoluteStyle(
        for referenceDate: Date
    ) -> ArraySlice<Date.ComponentsFormatStyle.Field> {
        guard !allowedFields.isEmpty else {
            return []
        }
        let firstDifference = allowedFields.firstIndex { field in
            let component = component(for: field)
            return calendar.component(component, from: date) !=
                calendar.component(component, from: referenceDate)
        }
        let start = firstDifference ?? allowedFields.index(before: allowedFields.endIndex)
        return allowedFields[start...].prefix(effectiveMaximumFieldCount)
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

    private func add(
        _ field: Date.ComponentsFormatStyle.Field,
        to style: inout Date.FormatStyle
    ) {
        if field == .year {
            style = style.year(.defaultDigits)
        } else if field == .month {
            style = switch sizeVariant {
            case .regular:
                style.month(.wide)
            case .compact:
                style.month(.abbreviated)
            default:
                style.month(.twoDigits)
            }
        } else if field == .week {
            style = style.week(.defaultDigits)
        } else if field == .day {
            style = switch sizeVariant {
            case .regular:
                style.weekday(.wide).day(.defaultDigits)
            case .compact:
                style.weekday(.abbreviated).day(.defaultDigits)
            default:
                style.day(.twoDigits)
            }
        } else if field == .hour {
            style = style.hour(.defaultDigits(amPM: .abbreviated))
        } else if field == .minute {
            style = style.minute(.twoDigits)
        } else if field == .second {
            style = style.second(.twoDigits)
        }
    }
}

// MARK: - SystemFormatStyle.DateReference + DiscreteFormatStyle

@available(OpenSwiftUI_v6_0, *)
extension SystemFormatStyle.DateReference: DiscreteFormatStyle {
    public func discreteInput(before referenceDate: Date) -> Date? {
        if relativeStyleInterval?.contains(referenceDate) != false {
            return relativeStyle.discreteInput(before: referenceDate)
        }
        return adjacentAbsoluteInput(to: referenceDate, before: true)
    }

    public func discreteInput(after referenceDate: Date) -> Date? {
        if relativeStyleInterval?.contains(referenceDate) != false {
            return relativeStyle.discreteInput(after: referenceDate)
        }
        return adjacentAbsoluteInput(to: referenceDate, before: false)
    }

    public func input(before referenceDate: Date) -> Date? {
        if relativeStyleInterval?.contains(referenceDate) != false {
            return relativeStyle.input(before: referenceDate)
        }
        return discreteInput(before: referenceDate)
    }

    public func input(after referenceDate: Date) -> Date? {
        if relativeStyleInterval?.contains(referenceDate) != false {
            return relativeStyle.input(after: referenceDate)
        }
        return discreteInput(after: referenceDate)
    }

    private func adjacentAbsoluteInput(
        to referenceDate: Date,
        before: Bool
    ) -> Date? {
        let field = fieldsToShowInAbsoluteStyle(for: referenceDate).last ?? thresholdField
        guard let interval = calendar.dateInterval(
            of: component(for: field),
            for: referenceDate
        ) else {
            return nil
        }
        if before {
            return Date(
                timeIntervalSinceReferenceDate:
                    interval.start.timeIntervalSinceReferenceDate.nextDown
            )
        } else {
            return interval.end
        }
    }
}

// MARK: - SystemFormatStyle.DateReference + UpdateFrequencyDependentFormatStyle

extension SystemFormatStyle.DateReference: UpdateFrequencyDependentFormatStyle {
    package func updateFrequency(
        _ frequency: TimeDataFormatting.UpdateFrequency
    ) -> SystemFormatStyle.DateReference {
        var style = self
        style.allowedFields = allowedFields.filter {
            $0.magnitude >= frequency.magnitude
        }
        return style
    }
}

// MARK: - SystemFormatStyle.DateReference + CapitalizationContextDependentFormatStyle

extension SystemFormatStyle.DateReference: CapitalizationContextDependentFormatStyle {
    package func capitalizationContext(
        _ context: FormatStyleCapitalizationContext
    ) -> SystemFormatStyle.DateReference {
        var style = self
        if capitalizationContext == .unknown {
            style.capitalizationContext = context
        }
        return style
    }
}

// MARK: - SystemFormatStyle.DateReference + SafelySerializableDiscreteFormatStyle

extension SystemFormatStyle.DateReference: SafelySerializableDiscreteFormatStyle {
    package static func representation<Source>(
        of resolvable: TimeDataFormatting.Resolvable<Source, SystemFormatStyle.DateReference>,
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
        environment.timeZone = format.timeZone

        let style: Text.DateStyle
        if format.calendar.isDateInToday(format.date) {
            let configuration = Text.DateStyle.UnitsConfiguration(
                units: NSCalendar.Unit(Set(format.allowedFields)),
                style: .brief
            )
            style = .relative(unitConfiguration: configuration)
        } else {
            style = .date
        }
        return ResolvableAbsoluteDate(
            resolvable.source.date(for: format.date),
            style: style,
            in: environment
        )
    }
}

#endif
