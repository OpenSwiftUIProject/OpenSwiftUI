//
//  ResolvableCurrentDate.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 80C5342B807D2151F70A20656D8D4920 (SwiftUICore)

package import Foundation
package import OpenSwiftUI_SPI

// MARK: - ResolvableCurrentDate

package struct ResolvableCurrentDate {
    package enum DateFormat: Equatable, Codable {
        case format(String)
        case template(String)
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

extension ResolvableCurrentDate: ConfigurationBasedResolvableStringAttribute {
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

    package var invalidationConfiguration: ResolvableAttributeConfiguration {
        provider?.updateConfiguration ?? .none
    }
}

extension ResolvableCurrentDate: Equatable {}

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
