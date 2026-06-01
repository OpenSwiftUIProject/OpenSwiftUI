//
//  TextFormatterTests.swift
//  OpenSwiftUICoreTests

import Foundation
@testable import OpenSwiftUICore
import Testing

struct TextFormatterTests {
    @Test
    func referenceConvertibleFormatterResolves() {
        let date = Date(timeIntervalSinceReferenceDate: 0)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let text = Text(date, formatter: formatter)
        let environment = fixedEnvironment()

        #expect(text.resolveString(in: environment) == "2001-01-01 00:00:00")
        #expect(formatter.locale == environment.locale)
        #expect(formatter.calendar == environment.calendar)
        #expect(formatter.timeZone == environment.timeZone)
    }

    @Test
    func objectFormatterResolves() {
        let number = NSNumber(value: 1234.5)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        var environment = EnvironmentValues()
        environment.locale = Locale(identifier: "fr_FR")

        let text = Text(number, formatter: formatter)
        let output = text.resolveString(in: environment)

        #expect(formatter.locale == environment.locale)
        #expect(output == formatter.string(from: number))
    }

    @Test
    func stringFormatStyleResolves() {
        let input = 1234.5
        let format = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(1))

        var environment = EnvironmentValues()
        environment.locale = Locale(identifier: "en_US_POSIX")

        let text = Text(input, format: format)

        #expect(text.resolveString(in: environment) == format.locale(environment.locale).format(input))
    }

    @Test
    func attributedStringFormatStyleResolves() {
        let text = Text(42, format: AttributedEchoStyle())

        #expect(text.resolveString(in: EnvironmentValues()) == "value 42")
    }

    @Test
    func formatStyleStorageParticipatesInEquality() {
        #expect(Text(42, format: AttributedEchoStyle()) == Text(42, format: AttributedEchoStyle()))
        #expect(Text(41, format: AttributedEchoStyle()) != Text(42, format: AttributedEchoStyle()))
    }

    private func fixedEnvironment() -> EnvironmentValues {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        var environment = EnvironmentValues()
        environment.locale = Locale(identifier: "en_US_POSIX")
        environment.calendar = calendar
        environment.timeZone = calendar.timeZone
        return environment
    }
}

private struct AttributedEchoStyle: FormatStyle, Hashable {
    func format(_ value: Int) -> AttributedString {
        AttributedString("value \(value)")
    }
}
