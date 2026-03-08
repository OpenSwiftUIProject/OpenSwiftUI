//
//  ResolvableAbsoluteDate.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package import Foundation

// MARK: - ResolvableAbsoluteDate

package struct ResolvableAbsoluteDate {
    package var date: Date
    package let style: Text.DateStyle
    package let calendar: Calendar
    package let locale: Locale
    package let timeZone: TimeZone

    package init(
        _ date: Date,
        style: Text.DateStyle,
        in environment: EnvironmentValues
    ) {
        self.date = date
        self.style = style
        self.calendar = environment.calendar
        self.locale = environment.locale
        self.timeZone = environment.timeZone
    }
}

extension ResolvableAbsoluteDate: ConfigurationBasedResolvableStringAttributeRepresentation {
    package static func decode(
        from decoder: any Decoder
    ) throws -> (any ResolvableStringAttribute)? {
        _openSwiftUIUnimplementedFailure()
    }

    package static let attribute: NSAttributedString.Key = .init("OpenSwiftUI.ResolvableAbsoluteDate")

    package var invalidationConfiguration: ResolvableAttributeConfiguration {
        _openSwiftUIUnimplementedFailure()
    }

    package func encode(to encoder: any Encoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    package init(from decoder: any Decoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ResolvableAbsoluteDate: Equatable {
    package static func == (a: ResolvableAbsoluteDate, b: ResolvableAbsoluteDate) -> Bool {
        a.date == b.date &&
        a.style == b.style &&
        a.calendar == b.calendar &&
        a.locale == b.locale &&
        a.timeZone == b.timeZone
    }
}
