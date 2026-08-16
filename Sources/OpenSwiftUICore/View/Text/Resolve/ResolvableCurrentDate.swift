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

#if canImport(Darwin)
extension DateFormattingContext {
    convenience init(_ context: ResolvableStringResolutionContext) {
        self.init(
            referenceDate: context.date,
            isLuminanceReduced: context.environment.isLuminanceReduced
        )
    }
}
#endif

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
    package static let attribute = NSAttributedString.Key("SwiftUI.ResolvableCurrentDate")

    #if canImport(Darwin)
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
    #else
    package var invalidationConfiguration: ResolvableAttributeConfiguration {
        .wallClock(alignment: .second)
    }
    #endif

    package func resolve(
        in context: ResolvableStringResolutionContext
    ) -> AttributedString? {
        #if canImport(Darwin)
        let formattingContext = DateFormattingContext(context)
        guard let string = provider?.formattedString(in: formattingContext) else {
            return nil
        }
        return AttributedString(string)
        #else
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        switch dateFormat {
        case let .format(format):
            formatter.dateFormat = format
        case let .template(template):
            formatter.setLocalizedDateFormatFromTemplate(template)
        }
        return AttributedString(formatter.string(from: context.date))
        #endif
    }
}

#if canImport(Darwin)
extension ResolvableCurrentDate: ProviderBackedResolvableStringAttribute {}
#endif

extension ResolvableCurrentDate: Codable {}

extension ResolvableCurrentDate: Equatable {}
