//
//  ResolvableCurrentDate.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 80C5342B807D2151F70A20656D8D4920 (SwiftUICore)

package import Foundation

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
    package var invalidationConfiguration: ResolvableAttributeConfiguration {
        .none
    }

    package func resolve(in context: ResolvableStringResolutionContext) -> AttributedString? {
        nil
    }

    package static let attribute = NSAttributedString.Key("SwiftUI.ResolvableCurrentDate")

}

extension ResolvableCurrentDate: Codable {}

extension ResolvableCurrentDate: Equatable {}
