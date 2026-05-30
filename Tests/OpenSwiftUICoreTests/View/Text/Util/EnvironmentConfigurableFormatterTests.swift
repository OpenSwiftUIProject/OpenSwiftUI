//
//  EnvironmentConfigurableFormatterTests.swift
//  OpenSwiftUICoreTests

import Foundation
@testable import OpenSwiftUICore
import Testing

struct EnvironmentConfigurableFormatterTests {
    @Test
    func dateFormatterConfigureAppliesEnvironmentValues() {
        let env = makeEnvironmentValues()

        let formatter = DateFormatter()
        formatter.configure(in: env)
        #expect(formatter.locale == env.locale)
        #expect(formatter.calendar == env.calendar)
        #expect(formatter.timeZone == env.timeZone)
    }

    @Test
    func iso8601DateFormatterConfigureAppliesEnvironmentValues() {
        let env = makeEnvironmentValues()

        let formatter = ISO8601DateFormatter()
        formatter.configure(in: env)
        #expect(formatter.timeZone == env.timeZone)
    }

    #if canImport(Darwin)
    @Test
    func dateComponentsFormatterConfigureAppliesEnvironmentValues() {
        let env = makeEnvironmentValues()

        let formatter = DateComponentsFormatter()
        formatter.configure(in: env)
        #expect(formatter.calendar == env.calendar)
    }
    #endif

    @Test
    func dateIntervalFormatterConfigureAppliesEnvironmentValues() {
        let env = makeEnvironmentValues()

        let formatter = DateIntervalFormatter()
        formatter.configure(in: env)
        #expect(formatter.calendar == env.calendar)
        #expect(formatter.locale == env.locale)
        #expect(formatter.timeZone == env.timeZone)
    }

    @Test
    func numberFormatterConfigureAppliesEnvironmentValues() {
        let env = makeEnvironmentValues()

        let formatter = NumberFormatter()
        formatter.configure(in: env)
        #expect(formatter.locale == env.locale)
    }

    #if canImport(Darwin)
    @Test
    func measurementFormatterConfigureAppliesEnvironmentValues() {
        let env = makeEnvironmentValues()

        let formatter = MeasurementFormatter()
        formatter.configure(in: env)
        #expect(formatter.locale == env.locale)
        #expect(formatter.numberFormatter.locale == env.locale)
    }
    #endif

    @Test
    func massFormatterConfigureAppliesEnvironmentValues() {
        let env = makeEnvironmentValues()

        let formatter = MassFormatter()
        formatter.configure(in: env)
        #expect(formatter.numberFormatter.locale == env.locale)
    }

    @Test
    func lengthFormatterConfigureAppliesEnvironmentValues() {
        let env = makeEnvironmentValues()

        let formatter = LengthFormatter()
        formatter.configure(in: env)
        #expect(formatter.numberFormatter.locale == env.locale)
    }

    @Test
    func energyFormatterConfigureAppliesEnvironmentValues() {
        let env = makeEnvironmentValues()

        let formatter = EnergyFormatter()
        formatter.configure(in: env)
        #expect(formatter.numberFormatter.locale == env.locale)
    }

    private func makeEnvironmentValues() -> EnvironmentValues {
        let locale = Locale(identifier: "fr_FR")
        var calendar = Calendar(identifier: .buddhist)
        calendar.timeZone = TimeZone(secondsFromGMT: 9 * 3600)!
        let timeZone = TimeZone(secondsFromGMT: 5 * 3600)!

        var environment = EnvironmentValues()
        environment.locale = locale
        environment.calendar = calendar
        environment.timeZone = timeZone
        return environment
    }
}
