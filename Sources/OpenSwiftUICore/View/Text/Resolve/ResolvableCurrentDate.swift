//
//  ResolvableCurrentDate.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 80C5342B807D2151F70A20656D8D4920 (SwiftUICore)

package import Foundation
#if canImport(Darwin)
package import OpenSwiftUI_SPI
#endif

// MARK: - ResolvableCurrentDate

package struct ResolvableCurrentDate {
    package enum DateFormat: Hashable, Codable {
        case format(String)
        case template(String)

        private enum CodingKeys: CodingKey {
            case format
            case template
        }

        private enum FormatCodingKeys: CodingKey {
            case _0
        }

        private enum TemplateCodingKeys: CodingKey {
            case _0
        }

        package init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guard container.allKeys.count == 1 else {
                let context = DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid number of keys found, expected one."
                )
                throw DecodingError.typeMismatch(Self.self, context)
            }
            switch container.allKeys[0] {
            case .format:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: FormatCodingKeys.self,
                    forKey: .format
                )
                self = .format(try nestedContainer.decode(String.self, forKey: ._0))
            case .template:
                let nestedContainer = try container.nestedContainer(
                    keyedBy: TemplateCodingKeys.self,
                    forKey: .template
                )
                self = .template(try nestedContainer.decode(String.self, forKey: ._0))
            }
        }

        package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .format(format):
                var nestedContainer = container.nestedContainer(
                    keyedBy: FormatCodingKeys.self,
                    forKey: .format
                )
                try nestedContainer.encode(format, forKey: ._0)
            case let .template(template):
                var nestedContainer = container.nestedContainer(
                    keyedBy: TemplateCodingKeys.self,
                    forKey: .template
                )
                try nestedContainer.encode(template, forKey: ._0)
            }
        }
    }

    package let dateFormat: DateFormat
    package let calendar: Calendar
    package let locale: Locale
    package let timeZone: TimeZone

    package init(
        dateFormat: DateFormat,
        timeZone: TimeZone?,
        in environment: EnvironmentValues
    ) {
        self.dateFormat = dateFormat
        self.calendar = environment.calendar
        self.locale = environment.locale
        self.timeZone = timeZone ?? environment.timeZone
    }
}

#if canImport(Darwin)
extension ResolvableCurrentDate: ProviderBackedResolvableStringAttribute {
    package static let attribute = NSAttributedString.Key("OpenSwiftUI.ResolvableCurrentDate")

    package var provider: BaseDateProvider? {
        switch dateFormat {
        case let .format(format):
            DateProvider(
                dateFormat: format,
                calendar: calendar,
                locale: locale,
                timeZone: timeZone
            )
        case let .template(template):
            DateProvider(
                dateFormatTemplate: template,
                calendar: calendar,
                locale: locale,
                timeZone: timeZone
            )
        }
    }

    package func resolve(
        in context: ResolvableStringResolutionContext
    ) -> AttributedString? {
        guard let provider else { return nil }
        let formattingContext = DateFormattingContext(context)
        guard let string = provider.formattedString(in: formattingContext) else {
            return nil
        }
        return AttributedString(string)
    }
}
#else
extension ResolvableCurrentDate: ConfigurationBasedResolvableStringAttribute {
    package static let attribute = NSAttributedString.Key("OpenSwiftUI.ResolvableCurrentDate")

    package var invalidationConfiguration: ResolvableAttributeConfiguration {
        .none
    }

    package func resolve(
        in context: ResolvableStringResolutionContext
    ) -> AttributedString? {
        nil
    }
}
#endif

extension ResolvableCurrentDate {
    private enum CodingKeys: CodingKey {
        case dateFormat
        case calendar
        case locale
        case timeZone
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dateFormat = try container.decode(DateFormat.self, forKey: .dateFormat)
        self.calendar = try container.decode(Calendar.self, forKey: .calendar)
        self.locale = try container.decode(Locale.self, forKey: .locale)
        self.timeZone = try container.decode(TimeZone.self, forKey: .timeZone)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dateFormat, forKey: .dateFormat)
        try container.encode(calendar, forKey: .calendar)
        try container.encode(locale, forKey: .locale)
        try container.encode(timeZone, forKey: .timeZone)
    }
}

extension ResolvableCurrentDate: Hashable {}

#if canImport(Darwin)
// MARK: - BaseDateProvider + updateConfiguration

extension BaseDateProvider {
    var updateConfiguration: ResolvableAttributeConfiguration {
        switch updateType {
        case .interval:
            return .interval(delay: updateInterval().map(Double.init(truncating:)) ?? .zero)
        case .wallClock:
            let alignment = updateWallClockAlignment
            guard !alignment.isEmpty else {
                Log.internalError("No wall clock alignment provided")
                return .none
            }
            return .wallClock(alignment: alignment)
        case .timer:
            guard let timerEndDate else {
                Log.internalError("No timer end provided")
                return .none
            }
            return .timer(end: timerEndDate)
        case .timerIntervalCountdown:
            guard let timerInterval else {
                Log.internalError("No timer interval provided")
                return .none
            }
            return .timerInterval(interval: timerInterval, countdown: true)
        case .timerIntervalCountup:
            guard let timerInterval else {
                Log.internalError("No timer interval provided")
                return .none
            }
            return .timerInterval(interval: timerInterval, countdown: false)
        default:
            return .none
        }
    }
}

// MARK: - DateFormattingContext + ResolvableStringResolutionContext

extension DateFormattingContext {
    convenience init(_ context: ResolvableStringResolutionContext) {
        self.init(
            referenceDate: context.date,
            isLuminanceReduced: context.environment.isLuminanceReduced
        )
    }
}
#endif
