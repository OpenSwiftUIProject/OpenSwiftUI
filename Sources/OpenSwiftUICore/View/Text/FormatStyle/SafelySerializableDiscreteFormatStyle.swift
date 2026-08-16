//
//  SafelySerializableDiscreteFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: FC3C28D5644C47C09D015ECEE0BA5601 (SwiftUICore)

package import Foundation

package protocol SafelySerializableDiscreteFormatStyle: DiscreteFormatStyle where FormatOutput: AttributedStringConvertible {
    static func representation<S>(
        of resolvable: TimeDataFormatting.Resolvable<S, Self>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where S: TimeDataSourceStorage, S.Value == FormatInput
}

// MARK: - Date.FormatStyle

extension Date.FormatStyle: SafelySerializableDiscreteFormatStyle {
    package static func representation<S>(
        of resolvable: TimeDataFormatting.Resolvable<S, Date.FormatStyle>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where S: TimeDataSourceStorage, S.Value == Date
    {
        guard version <= .v5 else {
            return resolvable
        }
        return Date.FormatStyle.Attributed.representation(
            of: resolvable.replacingFormat(with: resolvable.format.attributedStyle),
            for: version
        )
    }
}

extension Date.FormatStyle.Attributed: SafelySerializableDiscreteFormatStyle {
    package static func representation<S>(
        of resolvable: TimeDataFormatting.Resolvable<S, Date.FormatStyle.Attributed>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where S: TimeDataSourceStorage, S.Value == Date
    {
        guard version <= .v5 else {
            return resolvable
        }
        let format = resolvable.format
        var environment = EnvironmentValues()
        environment.locale = format[dynamicMember: \.locale]
        environment.calendar = format[dynamicMember: \.calendar]
        environment.timeZone = format[dynamicMember: \.timeZone]
        return ResolvableCurrentDate(
            dateFormat: .template(format.template()),
            timeZone: format[dynamicMember: \.timeZone],
            in: environment
        )
    }
}

// MARK: - Date.VerbatimFormatStyle

extension Date.VerbatimFormatStyle: SafelySerializableDiscreteFormatStyle {
    package static func representation<S>(
        of resolvable: TimeDataFormatting.Resolvable<S, Date.VerbatimFormatStyle>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where S: TimeDataSourceStorage, S.Value == Date
    {
        guard version <= .v5 else {
            return resolvable
        }
        return Date.VerbatimFormatStyle.Attributed.representation(
            of: resolvable.replacingFormat(with: resolvable.format.attributedStyle),
            for: version
        )
    }
}

extension Date.VerbatimFormatStyle.Attributed: SafelySerializableDiscreteFormatStyle {
    package static func representation<S>(
        of resolvable: TimeDataFormatting.Resolvable<S, Date.VerbatimFormatStyle.Attributed>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where S: TimeDataSourceStorage, S.Value == Date
    {
        guard version <= .v5 else {
            return resolvable
        }
        let format = resolvable.format
        var environment = EnvironmentValues()
        if let locale = format[dynamicMember: \.locale] {
            environment.locale = locale
        }
        environment.calendar = format[dynamicMember: \.calendar]
        environment.timeZone = format[dynamicMember: \.timeZone]
        return ResolvableCurrentDate(
            dateFormat: .format(format.formatPattern),
            timeZone: format[dynamicMember: \.timeZone],
            in: environment
        )
    }
}

// MARK: - Date.ComponentsFormatStyle

extension Date.ComponentsFormatStyle: SafelySerializableDiscreteFormatStyle {
    package static func representation<S>(
        of resolvable: TimeDataFormatting.Resolvable<S, Date.ComponentsFormatStyle>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where S: TimeDataSourceStorage, S.Value == Range<Date>
    {
        guard version <= .v5 else {
            return resolvable
        }
        let format = resolvable.format
        var environment = EnvironmentValues()
        environment.locale = format.locale
        environment.calendar = format.calendar

        let anchor = resolvable.source
            .value(for: Date(timeIntervalSinceReferenceDate: -.infinity))
            .upperBound
        let timeDuration = Date.ComponentsFormatStyle.timeDuration
            .calendar(format.calendar)
            .locale(format.locale)
        if format == timeDuration {
            return ResolvableAbsoluteDate(anchor, style: .timer, in: environment)
        }
        let fields = format.fields ?? [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second,
        ]
        let configuration = Text.DateStyle.UnitsConfiguration(
            units: NSCalendar.Unit(fields),
            style: format.style.unitsConfigurationStyle
        )
        return ResolvableAbsoluteDate(
            anchor,
            style: .relative(unitConfiguration: configuration),
            in: environment
        )
    }
}

// MARK: - Date.AnchoredRelativeFormatStyle

extension Date.AnchoredRelativeFormatStyle: SafelySerializableDiscreteFormatStyle {
    package static func representation<S>(
        of resolvable: TimeDataFormatting.Resolvable<S, Date.AnchoredRelativeFormatStyle>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where S: TimeDataSourceStorage, S.Value == Date
    {
        guard version <= .v5 else {
            return resolvable
        }
        let format = resolvable.format
        var environment = EnvironmentValues()
        environment.locale = format.locale
        environment.calendar = format.calendar
        let configuration = Text.DateStyle.UnitsConfiguration(
            units: NSCalendar.Unit(format.allowedFields),
            style: format.unitsStyle.unitsConfigurationStyle
        )
        return ResolvableAbsoluteDate(
            format.anchor,
            style: .relative(unitConfiguration: configuration),
            in: environment
        )
    }
}

// MARK: - Duration.TimeFormatStyle

extension Duration.TimeFormatStyle: SafelySerializableDiscreteFormatStyle {
    package static func representation<S>(
        of resolvable: TimeDataFormatting.Resolvable<S, Duration.TimeFormatStyle>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where S: TimeDataSourceStorage, S.Value == Duration
    {
        guard version <= .v5 else {
            return resolvable
        }
        return Duration.TimeFormatStyle.Attributed.representation(
            of: resolvable.replacingFormat(with: resolvable.format.attributed),
            for: version
        )
    }
}

extension Duration.TimeFormatStyle.Attributed: SafelySerializableDiscreteFormatStyle {
    package static func representation<S>(
        of resolvable: TimeDataFormatting.Resolvable<S, Duration.TimeFormatStyle.Attributed>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where S: TimeDataSourceStorage, S.Value == Duration
    {
        guard version <= .v5 else {
            return resolvable
        }
        let format = resolvable.format
        var environment = EnvironmentValues()
        environment.locale = format[dynamicMember: \.locale]

        let sample = Duration.seconds(3600)
        let sampleString = String(format.format(sample).characters)
        let hourMinuteSecond = sample.formatted(
            .time(pattern: .hourMinuteSecond).locale(environment.locale)
        )
        let minuteSecond = sample.formatted(
            .time(pattern: .minuteSecond).locale(environment.locale)
        )
        let units: NSCalendar.Unit
        if sampleString.contains(hourMinuteSecond) {
            units = [.hour, .minute, .second]
        } else if sampleString.contains(minuteSecond) {
            units = [.minute, .second]
        } else {
            units = [.hour, .minute]
        }
        return ResolvableAbsoluteDate(
            resolvable.source.date(for: .zero),
            style: .timer(units: units),
            in: environment
        )
    }
}

// MARK: - Duration.UnitsFormatStyle

extension Duration.UnitsFormatStyle: SafelySerializableDiscreteFormatStyle {
    package static func representation<S>(
        of resolvable: TimeDataFormatting.Resolvable<S, Duration.UnitsFormatStyle>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where S: TimeDataSourceStorage, S.Value == Duration
    {
        guard version <= .v5 else {
            return resolvable
        }
        return Duration.UnitsFormatStyle.Attributed.representation(
            of: resolvable.replacingFormat(with: resolvable.format.attributed),
            for: version
        )
    }
}

extension Duration.UnitsFormatStyle.Attributed: SafelySerializableDiscreteFormatStyle {
    package static func representation<S>(
        of resolvable: TimeDataFormatting.Resolvable<S, Duration.UnitsFormatStyle.Attributed>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where S: TimeDataSourceStorage, S.Value == Duration
    {
        guard version <= .v5 else {
            return resolvable
        }
        let format = resolvable.format
        var environment = EnvironmentValues()
        environment.locale = format[dynamicMember: \.locale]
        let configuration = Text.DateStyle.UnitsConfiguration(
            units: NSCalendar.Unit(format.allowedUnits),
            style: format.unitWidth.unitsConfigurationStyle
        )
        return ResolvableAbsoluteDate(
            resolvable.source.date(for: .zero),
            style: .relative(unitConfiguration: configuration),
            in: environment
        )
    }
}

// MARK: - Legacy representation helpers

extension Date.ComponentsFormatStyle.Style {
    var unitsConfigurationStyle: Text.DateStyle.UnitsConfiguration.Style {
        if self == .narrow {
            .short
        } else if self == .abbreviated || self == .condensedAbbreviated {
            .brief
        } else {
            .full
        }
    }
}

extension Date.RelativeFormatStyle.UnitsStyle {
    var unitsConfigurationStyle: Text.DateStyle.UnitsConfiguration.Style {
        if self == .narrow {
            .short
        } else if self == .abbreviated {
            .full
        } else {
            .brief
        }
    }
}

extension Duration.UnitsFormatStyle.UnitWidth {
    var unitsConfigurationStyle: Text.DateStyle.UnitsConfiguration.Style {
        if self == .narrow {
            .short
        } else if self == .abbreviated {
            .brief
        } else if self == .condensedAbbreviated {
            .full
        } else {
            .brief
        }
    }
}

extension Date.FormatStyle.Attributed {
    fileprivate func template() -> String {
        let omitted = era(.omitted)
            .quarter(.omitted)
            .week(.omitted)
            .dayOfYear(.omitted)
            .secondFraction(.omitted)
            .weekday(.omitted)
            .timeZone(.omitted)
            .second(.omitted)
            .minute(.omitted)
            .hour(.omitted)
            .day(.omitted)
            .month(.omitted)
            .year(.omitted)
        if self != omitted,
           era(.abbreviated).era(.omitted) == omitted,
           year(.defaultDigits).year(.omitted) == omitted
        {
            return "jmmdMY"
        }

        var template = ""
        if self != era(.omitted) {
            template += "G"
        }
        if self != quarter(.omitted) {
            template += "QQQ"
        }
        if self != week(.omitted) {
            template += "w"
        }
        if self != dayOfYear(.omitted) {
            template += "D"
        }
        if self != secondFraction(.omitted) {
            template += "S"
        }
        if self != weekday(.omitted) {
            template += "EEE"
        }
        if self != timeZone(.omitted) {
            template += "v"
        }
        if self != second(.omitted) {
            template += "ss"
        }
        if self != minute(.omitted) {
            template += "mm"
        }
        if self != hour(.omitted) {
            template += "j"
        }
        if self != day(.omitted) {
            template += "d"
        }
        if self != month(.omitted) {
            template += "M"
        }
        if self != year(.omitted) {
            template += "YYYY"
        }
        return template
    }
}

extension Date.VerbatimFormatStyle.Attributed {
    fileprivate struct CodableRepresentation: Decodable {
        struct Base: Decodable {
            var formatPattern: String
        }

        var base: Base
    }

    fileprivate var formatPattern: String {
        guard let data = try? JSONEncoder().encode(self),
              let representation = try? JSONDecoder().decode(
                  CodableRepresentation.self,
                  from: data
              )
        else {
            return "yyyy-MM-dd HH:mm:ssXXX"
        }
        return representation.base.formatPattern
    }
}
