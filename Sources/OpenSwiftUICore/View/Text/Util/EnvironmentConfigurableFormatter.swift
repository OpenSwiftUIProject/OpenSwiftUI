//
//  EnvironmentConfigurableFormatter.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

// MARK: - EnvironmentConfigurableFormatter

/// A formatter that can apply text-related environment values before use.
///
/// OpenSwiftUI calls this hook for Foundation formatters whose output depends
/// on environment-provided formatting state, such as locale, calendar, or time
/// zone. Conforming formatters update only the environment-dependent properties
/// they support.
///
/// - Note: Some Foundation formatter types are only available on Apple
///   platforms.
protocol EnvironmentConfigurableFormatter: AnyObject {
    /// Updates the formatter with values from the current environment.
    ///
    /// - Parameter environment: The environment values that should influence
    ///   the formatter's output.
    func configure(in environment: EnvironmentValues)
}

// MARK: - DateFormatter + EnvironmentConfigurableFormatter

extension DateFormatter: EnvironmentConfigurableFormatter {
    func configure(in environment: EnvironmentValues) {
        locale = environment.locale
        calendar = environment.calendar
        timeZone = environment.timeZone
    }
}

// MARK: - ISO8601DateFormatter + EnvironmentConfigurableFormatter

extension ISO8601DateFormatter: EnvironmentConfigurableFormatter {
    func configure(in environment: EnvironmentValues) {
        timeZone = environment.timeZone
    }
}

// MARK: - DateComponentsFormatter + EnvironmentConfigurableFormatter

#if canImport(Darwin)
extension DateComponentsFormatter: EnvironmentConfigurableFormatter {
    func configure(in environment: EnvironmentValues) {
        calendar = environment.calendar
    }
}
#endif

// MARK: - DateIntervalFormatter + EnvironmentConfigurableFormatter

extension DateIntervalFormatter: EnvironmentConfigurableFormatter {
    func configure(in environment: EnvironmentValues) {
        calendar = environment.calendar
        locale = environment.locale
        timeZone = environment.timeZone
    }
}

// MARK: - NumberFormatter + EnvironmentConfigurableFormatter

extension NumberFormatter: EnvironmentConfigurableFormatter {
    func configure(in environment: EnvironmentValues) {
        locale = environment.locale
    }
}

// MARK: - MeasurementFormatter + EnvironmentConfigurableFormatter

#if canImport(Darwin)
extension MeasurementFormatter: EnvironmentConfigurableFormatter {
    func configure(in environment: EnvironmentValues) {
        locale = environment.locale
        numberFormatter.locale = environment.locale
    }
}
#endif

// MARK: - MassFormatter + EnvironmentConfigurableFormatter

extension MassFormatter: EnvironmentConfigurableFormatter {
    func configure(in environment: EnvironmentValues) {
        numberFormatter.locale = environment.locale
    }
}

// MARK: - LengthFormatter + EnvironmentConfigurableFormatter

extension LengthFormatter: EnvironmentConfigurableFormatter {
    func configure(in environment: EnvironmentValues) {
        numberFormatter.locale = environment.locale
    }
}

// MARK: - EnergyFormatter + EnvironmentConfigurableFormatter

extension EnergyFormatter: EnvironmentConfigurableFormatter {
    func configure(in environment: EnvironmentValues) {
        numberFormatter.locale = environment.locale
    }
}
