//
//  EnvironmentConfigurableFormatter.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

// MARK: - EnvironmentConfigurableFormatter

protocol EnvironmentConfigurableFormatter: AnyObject {
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

extension DateComponentsFormatter: EnvironmentConfigurableFormatter {
    func configure(in environment: EnvironmentValues) {
        calendar = environment.calendar
    }
}

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

extension MeasurementFormatter: EnvironmentConfigurableFormatter {
    func configure(in environment: EnvironmentValues) {
        locale = environment.locale
        numberFormatter.locale = environment.locale
    }
}

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
