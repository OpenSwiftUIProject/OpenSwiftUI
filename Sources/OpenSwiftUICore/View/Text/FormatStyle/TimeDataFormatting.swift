//
//  TimeDataFormatting.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C320C90E4A458BC2E4049E0630068186 (SwiftUICore)

package import Foundation

// MARK: - TimeDataFormatting

package enum TimeDataFormatting: ResolvableStringAttributeFamily {
    package static var attribute: NSAttributedString.Key {
        .init(rawValue: "OpenSwiftUI.ResolvableTimeDataFormatting")
    }
}

extension TimeDataFormatting {
    package struct Resolvable<Source, Format>: ResolvableStringAttribute, Hashable where Source: TimeDataSourceStorage, Format: DiscreteFormatStyle, Source.Value == Format.FormatInput, Format.FormatOutput: AttributedStringConvertible {

        let source: Source
        let format: Format
        let secondsUpdateFrequencyBudget: TimeInterval
        var configuration: Configuration<Source, Format>
        var sizeVariant: TextSizeVariant

        package typealias Family = TimeDataFormatting

        package func replacingFormat<F>(
            with newFormat: F
        ) -> Resolvable<Source, F> where F: DiscreteFormatStyle, Format.FormatInput == F.FormatInput, F.FormatOutput: AttributedStringConvertible {
            Resolvable<Source, F>.makeResolvable(
                from: source,
                format: newFormat,
                secondsUpdateFrequencyBudget: secondsUpdateFrequencyBudget
            ).resolvable
        }

        package init(
            source: Source,
            format: Format,
            secondsUpdateFrequencyBudget: TimeInterval,
            sizeVariant: TextSizeVariant = .regular
        ) {
            self = Self.makeResolvable(
                from: source,
                format: format,
                secondsUpdateFrequencyBudget: secondsUpdateFrequencyBudget,
                sizeVariant: sizeVariant
            ).resolvable
        }

        private static func makeResolvable(
            from source: Source,
            format: Format,
            secondsUpdateFrequencyBudget: TimeInterval,
            sizeVariant: TextSizeVariant = .regular
        ) -> (resolvable: Resolvable<Source, Format>, exact: Bool) {
            let result = Configuration.makeConfiguration(
                from: source,
                format: format,
                sizeVariant: sizeVariant,
                secondsUpdateFrequencyBudget: secondsUpdateFrequencyBudget
            )
            return (
                Resolvable(
                    source: source,
                    format: format,
                    secondsUpdateFrequencyBudget: secondsUpdateFrequencyBudget,
                    configuration: result.configuration,
                    sizeVariant: sizeVariant
                ),
                result.exact
            )
        }

        init(
            source: Source,
            format: Format,
            secondsUpdateFrequencyBudget: TimeInterval,
            configuration: Configuration<Source, Format>,
            sizeVariant: TextSizeVariant
        ) {
            self.source = source
            self.format = format
            self.secondsUpdateFrequencyBudget = secondsUpdateFrequencyBudget
            self.configuration = configuration
            self.sizeVariant = sizeVariant
        }

        package func resolve(in context: ResolvableStringResolutionContext) -> AttributedString? {
            let isLuminanceReduced = context.environment.isLuminanceReduced
            let date: Date
            if isLuminanceReduced {
                date = context.date
            } else {
                date = context.date + Double.random(in: 0 ..< 1.0 / 30.0)
            }
            let resolved = configuration.formatAndFrequency(for: context)
            var output = resolved.format.format(source.value(for: date)).attributedString
            if let fallbackRedactionFrequency = resolved.fallbackRedactionFrequency,
               resolved.format.needsRedaction(
                   for: fallbackRedactionFrequency,
                   evaluating: source,
                   at: date
               )
            {
                output.redact(
                    for: fallbackRedactionFrequency,
                    locale: context.environment.locale
                )
            }
            let magnitude = Calendar.Component.Magnitude(1.0)
            if Format.FormatOutput.self != AttributedString.self ||
                !output.disableContentTransition(
                    for: magnitude,
                    locale: context.environment.locale
                )
            {
                disableContentTransition(
                    on: &output,
                    for: magnitude,
                    date: date,
                    isLuminanceReduced: isLuminanceReduced
                )
            }
            return output
        }

        private func disableContentTransition(
            on output: inout AttributedString,
            for magnitude: Calendar.Component.Magnitude,
            date: Date,
            isLuminanceReduced: Bool
        ) {
            guard let schedule else {
                return
            }
            let nextDate = schedule.nextEntry(
                after: date,
                mode: isLuminanceReduced ? .lowFrequency : .normal,
                limit: 60
            )
            if magnitude.interval >= nextDate.timeIntervalSince(date) {
                output.interpolationStrategy = .unanimated
            }
        }

        package var schedule: Resolvable<Source, Format>? {
            self
        }

        package var requiredFeatures: Text.ResolvedProperties.Features {
            .checkInterpolationStrategy
        }

        package func sizeVariant(
            _ sizeVariant: TextSizeVariant
        ) -> (resolvable: Resolvable<Source, Format>, exact: Bool) {
            Self.makeResolvable(
                from: source,
                format: format,
                secondsUpdateFrequencyBudget: secondsUpdateFrequencyBudget,
                sizeVariant: sizeVariant
            )
        }

        package mutating func makePlatformAttributes(
            resolver: inout PlatformAttributeResolver
        ) {
            guard var styledFormat = format as? any StyledFormatStyle else {
                return
            }
            styledFormat.makePlatformAttributes(resolver: &resolver)
            self = Self.makeResolvable(
                from: source,
                format: styledFormat as! Format,
                secondsUpdateFrequencyBudget: secondsUpdateFrequencyBudget,
                sizeVariant: sizeVariant
            ).resolvable
        }

        // TBA
        package func entries(
            from startDate: Date,
            mode: TimelineScheduleMode
        ) -> AnySequence<Date> {
            let resolved = configuration.formatAndFrequency(
                for: startDate,
                mode: mode
            )
            if let allowedFrequency = resolved.fallbackRedactionFrequency {
                return resolved.format.fallbackRedactionEntries(
                    from: startDate,
                    for: source,
                    allowedFrequency: allowedFrequency
                )
            }
            return resolved.format.complyingFormatStyleEntries(
                from: startDate,
                for: source
            )
        }

        // TBA
        package var invalidationConfiguration: ResolvableAttributeConfiguration {
            guard let representation = representation(for: .v5)
                as? any ConfigurationBasedResolvableStringAttributeRepresentation else {
                return .none
            }
            return representation.invalidationConfiguration
        }
    }

    // TBA
    struct Configuration<Source, Format>: Hashable where Source: TimeDataSourceStorage, Format: DiscreteFormatStyle, Source.Value == Format.FormatInput, Format.FormatOutput: AttributedStringConvertible {
        typealias ResolvedFormat = any DiscreteFormatStyle<Source.Value, Format.FormatOutput>

        var source: Source
        var highFrequencyFormat: ResolvedFormat
        var lowFrequencyFormat: ResolvedFormat?

        init(
            source: Source,
            highFrequencyFormat: ResolvedFormat,
            lowFrequencyFormat: ResolvedFormat?
        ) {
            self.source = source
            self.highFrequencyFormat = highFrequencyFormat
            self.lowFrequencyFormat = lowFrequencyFormat
        }

        static func makeConfiguration(
            from source: Source,
            format: Format,
            sizeVariant: TextSizeVariant,
            secondsUpdateFrequencyBudget: TimeInterval
        ) -> (configuration: Configuration<Source, Format>, exact: Bool) {
            let sizedFormat = format.exactSizeVariant(sizeVariant)
            let highFrequencyFormat: ResolvedFormat = sizedFormat.style
            let lowFrequencyFormat: ResolvedFormat?
            if let dependentFormat = sizedFormat.style as? any UpdateFrequencyDependentFormatStyle {
                let frequency = UpdateFrequency(
                    duration: .seconds(secondsUpdateFrequencyBudget)
                )
                lowFrequencyFormat = dependentFormat.updateFrequency(frequency)
                    as? ResolvedFormat
            } else {
                lowFrequencyFormat = nil
            }
            return (
                Configuration(
                    source: source,
                    highFrequencyFormat: highFrequencyFormat,
                    lowFrequencyFormat: lowFrequencyFormat
                ),
                sizedFormat.exact
            )
        }

        func formatAndFrequency(
            for context: ResolvableStringResolutionContext
        ) -> (format: ResolvedFormat, fallbackRedactionFrequency: UpdateFrequency?) {
            formatAndFrequency(
                for: context.date,
                mode: context.environment.isLuminanceReduced
                    ? .lowFrequency
                    : .normal
            )
        }

        func formatAndFrequency(
            for date: Date,
            mode: TimelineScheduleMode
        ) -> (format: ResolvedFormat, fallbackRedactionFrequency: UpdateFrequency?) {
            guard mode == .lowFrequency else {
                return (highFrequencyFormat, nil)
            }
            if let end = source.end, source.date(for: end) >= date {
                return (highFrequencyFormat, nil)
            }
            if let lowFrequencyFormat {
                return (lowFrequencyFormat, nil)
            }
            return (highFrequencyFormat, .minute)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(source)
            hasher.combine(AnyHashable(highFrequencyFormat))
            hasher.combine(lowFrequencyFormat.map { AnyHashable($0) })
        }

        static func == (
            lhs: Configuration<Source, Format>,
            rhs: Configuration<Source, Format>
        ) -> Bool {
            lhs.source == rhs.source &&
                AnyHashable(lhs.highFrequencyFormat) == AnyHashable(rhs.highFrequencyFormat) &&
                lhs.lowFrequencyFormat.map { AnyHashable($0) } ==
                    rhs.lowFrequencyFormat.map { AnyHashable($0) }
        }
    }

    fileprivate enum EntriesState {
        case start(Date)
        case previous(Date)
        case done

        mutating func next(_ nextEntry: (Date) -> Date?) -> Date? {
            let previous: Date
            switch self {
            case let .start(date), let .previous(date):
                previous = date
            case .done:
                return nil
            }
            guard let candidate = nextEntry(previous) else {
                self = .done
                return nil
            }
            let next = candidate > previous ? candidate : previous.nextUp
            self = .previous(next)
            return next
        }
    }

    fileprivate struct ComplyingFormatStyleEntries<Source, Format>: Sequence, IteratorProtocol where Source: TimeDataSourceStorage, Format: DiscreteFormatStyle, Source.Value == Format.FormatInput {
        var state: EntriesState
        let source: Source
        let format: Format

        mutating func next() -> Date? {
            state.next(nextEntry(for:))
        }

        func nextEntry(for date: Date) -> Date? {
            source.withValue(for: date) { value in
                format.discreteInput(after: value)
            }
        }
    }

    fileprivate struct FallbackRedactionEntries<Source, Format>: Sequence, IteratorProtocol where Source: TimeDataSourceStorage, Format: DiscreteFormatStyle, Source.Value == Format.FormatInput {
        var state: EntriesState
        let source: Source
        let format: Format
        let allowedFrequency: UpdateFrequency

        mutating func next() -> Date? {
            state.next(nextEntry(for:))
        }

        func nextEntry(for date: Date) -> Date? {
            let allowedDate = date.addingTimeInterval(allowedFrequency.interval)
            guard let formatDate = source.withValue(for: date, call: {
                format.discreteInput(after: $0)
            }), formatDate > date else {
                return allowedDate
            }
            return Swift.min(formatDate, allowedDate)
        }
    }
}

extension DiscreteFormatStyle {
    func needsRedaction<Source>(
        for frequency: TimeDataFormatting.UpdateFrequency,
        evaluating source: Source,
        at date: Date
    ) -> Bool where Source: TimeDataSourceStorage, FormatInput == Source.Value {
        guard frequency != .high else {
            return false
        }
        let value = source.value(for: date)
        guard let next = discreteInput(after: value),
              let previous = discreteInput(before: next)
        else {
            return false
        }
        let interval = source.date(for: next).timeIntervalSince(source.date(for: previous))
        return interval < frequency.interval
    }

    // TBA
    func fallbackRedactionEntries<Source>(
        from startDate: Date,
        for source: Source,
        allowedFrequency: TimeDataFormatting.UpdateFrequency
    ) -> AnySequence<Date> where Source: TimeDataSourceStorage, FormatInput == Source.Value {
        AnySequence(
            TimeDataFormatting.FallbackRedactionEntries(
                state: .start(startDate),
                source: source,
                format: self,
                allowedFrequency: allowedFrequency
            )
        )
    }

    // TBA
    func complyingFormatStyleEntries<Source>(
        from startDate: Date,
        for source: Source
    ) -> AnySequence<Date> where Source: TimeDataSourceStorage, FormatInput == Source.Value {
        AnySequence(
            TimeDataFormatting.ComplyingFormatStyleEntries(
                state: .start(startDate),
                source: source,
                format: self
            )
        )
    }
}

// MARK: - AttributedString + TimeDataFormatting

extension AttributedString {
    package mutating func redact(
        for frequency: TimeDataFormatting.UpdateFrequency,
        locale: Locale
    ) {
        guard frequency != .high else {
            return
        }
        if runs.count == 1,
           self.measurement == nil,
           self.durationField == nil,
           self.dateField == nil
        {
            redactNumbers(in: startIndex ..< endIndex)
            return
        }
        let hasMeasurement = runs.contains { $0.measurement != nil }
        func redact(_ range: Range<AttributedString.Index>) {
            if hasMeasurement {
                if self[range].measurement == .value {
                    self.redact(range)
                }
            } else {
                redactNumbers(in: range)
            }
        }
        lazy var localeUsesDecimalSystem = locale.numberingSystem == Locale.NumberingSystem("latn")
        for run in runs.reversed() {
            guard let magnitude = magnitude(
                of: run,
                locale: locale,
                localeUsesDecimalSystem: localeUsesDecimalSystem
            ) else {
                redact(run.range)
                continue
            }

            if magnitude.general < frequency.magnitude {
                redact(run.range)
            } else if let fractionals = magnitude.fractionals,
                      (fractionals.magnitude ?? .zero) < frequency.magnitude {
                redact(fractionals.range)
            }
        }
    }

    fileprivate mutating func disableContentTransition(
        for magnitude: Calendar.Component.Magnitude,
        locale: Locale
    ) -> Bool {
        var foundMagnitude = false
        lazy var localeUsesDecimalSystem =
            locale.numberingSystem == Locale.NumberingSystem("latn")
        for run in runs {
            guard let runMagnitude = self.magnitude(
                of: run,
                locale: locale,
                localeUsesDecimalSystem: localeUsesDecimalSystem
            ) else {
                continue
            }
            foundMagnitude = true
            if magnitude < runMagnitude.general {
                guard let fractionals = runMagnitude.fractionals else {
                    continue
                }
                guard magnitude >= (fractionals.magnitude ?? .zero) else {
                    continue
                }
                self[fractionals.range].interpolationStrategy = .unanimated
            } else {
                self[run.range].interpolationStrategy = .unanimated
            }
        }
        return foundMagnitude
    }

    func magnitude(
        of run: AttributedString.Runs.Run,
        locale: Locale,
        localeUsesDecimalSystem: Bool
    ) -> (
        general: Calendar.Component.Magnitude,
        fractionals: (
            range: Range<AttributedString.Index>,
            magnitude: Calendar.Component.Magnitude?
        )?
    )? {
        let general: Calendar.Component.Magnitude
        if let durationField = run.durationField {
            general = durationField.magnitude
        } else if let dateField = run.dateField {
            general = dateField.magnitude
        } else {
            return nil
        }

        lazy var decimalSeparatorRange: Range<AttributedString.Index>? = {
            guard let decimalSeparator = locale.decimalSeparator else {
                return nil
            }
            return self[run.range].characters.firstRange(of: decimalSeparator)
        }()
        guard let decimalSeparatorRange else {
            return (general, nil)
        }

        let fractionalRange = decimalSeparatorRange.upperBound ..< run.range.upperBound
        let fractionalMagnitude: Calendar.Component.Magnitude?
        if localeUsesDecimalSystem {
            var magnitude = general
            for _ in 0 ..< self[fractionalRange].characters.count {
                magnitude.decrementByOrderOfMagnitude()
            }
            fractionalMagnitude = magnitude
        } else {
            fractionalMagnitude = nil
        }
        return (general, (fractionalRange, fractionalMagnitude))
    }

    private mutating func redactNumbers(in range: Range<AttributedString.Index>) {
        for index in self[range].characters.indices.reversed()
            where characters[index].isNumber
        {
            characters[index] = "−"
        }
    }

    private mutating func redact(_ range: Range<AttributedString.Index>) {
        for index in self[range].characters.indices.reversed() {
            characters[index] = "−"
        }
    }
}

extension AttributeScopes.FoundationAttributes.DateFieldAttribute.Field {
    var magnitude: Calendar.Component.Magnitude {
        let interval: TimeInterval
        if self == .era {
            interval = 63_072_000_000.0
        } else if self == .year || self == .relatedGregorianYear {
            interval = 31_536_000.0
        } else if self == .quarter {
            interval = 7_776_000.0
        } else if self == .month {
            interval = 2_592_000.0
        } else if self == .weekOfYear || self == .weekOfMonth || self == .weekdayOrdinal {
            interval = 604_800.0
        } else if self == .weekday || self == .day || self == .dayOfYear {
            interval = 86400.0
        } else if self == .amPM {
            interval = 43200.0
        } else if self == .hour {
            interval = 3600.0
        } else if self == .minute {
            interval = 60.0
        } else if self == .second {
            interval = 1.0
        } else if self == .secondFraction {
            interval = 0.001
        } else {
            return .max
        }
        return .init(interval)
    }
}

extension AttributeScopes.FoundationAttributes.DurationFieldAttribute.Field {
    var magnitude: Calendar.Component.Magnitude {
        let interval: TimeInterval
        if self == .weeks {
            interval = 604_800.0
        } else if self == .days {
            interval = 86400.0
        } else if self == .hours {
            interval = 3600.0
        } else if self == .minutes {
            interval = 60.0
        } else if self == .seconds {
            interval = 1.0
        } else if self == .microseconds {
            interval = 0.000_001
        } else if self == .milliseconds {
            interval = 0.001
        } else if self == .nanoseconds {
            interval = 0.000_000_001
        } else {
            return .max
        }
        return .init(interval)
    }
}

// MARK: - TimeDataFormattingContainer

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
public struct TimeDataFormattingContainer: Codable {
    private let resolvable: any SafelyCodableResolvable

    package init?(resolvable: Any) {
        guard let resolvable = resolvable as? any SafelyCodableResolvable else {
            return nil
        }
        self.resolvable = resolvable
    }

    public init(from decoder: any Decoder) throws {
        let value = try TimeDataFormatting.decode(from: decoder)
        guard let resolvable = value as? any SafelyCodableResolvable else {
            throw DecodingError.typeMismatch(
                (any SafelyCodableResolvable).self,
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected TimeDataFormatting.Resolvable in this context to conform to SafelyCodableResolvable.self"
                )
            )
        }
        self.resolvable = resolvable
    }

    public func encode(to encoder: any Encoder) throws {
        try resolvable.serialize(to: encoder)
    }

    public var text: Text {
        resolvable.makeText()
    }

    package func representation(
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation {
        resolvable.representation(for: version)
    }
}

@_spi(Private)
@available(*, unavailable)
extension TimeDataFormattingContainer: Sendable {}

// MARK: - TimeDataFormatting + Codable

private protocol SafelyCodableResolvable: Codable, ResolvableStringAttribute {
    func makeText() -> Text
    func serialize(to encoder: any Encoder) throws
    func _representation(
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
}


private struct SafelyCodableRequirement: CodableRequirement {
    static func checkedCodableType(
        _ type: Any.Type
    ) -> (any (Decodable & Encodable).Type)? {
        type as? any SafelyCodableResolvable.Type
    }
}

extension TimeDataFormatting.Resolvable: Codable {
    private enum CodingKeys: String, CodingKey {
        case source
        case format
        case secondsUpdateFrequencyBudget
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let source = try container.decode(Source.self, forKey: .source)
        let format = try container.decode(Format.self, forKey: .format)
        let secondsUpdateFrequencyBudget = try container.decode(
            TimeInterval.self,
            forKey: .secondsUpdateFrequencyBudget
        )
        let result = TimeDataFormatting.Configuration<Source, Format>.makeConfiguration(
            from: source,
            format: format,
            sizeVariant: .regular,
            secondsUpdateFrequencyBudget: secondsUpdateFrequencyBudget
        )
        self.source = source
        self.format = format
        self.secondsUpdateFrequencyBudget = secondsUpdateFrequencyBudget
        self.configuration = result.configuration
        self.sizeVariant = .regular
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
        try container.encode(format, forKey: .format)
        try container.encode(
            secondsUpdateFrequencyBudget,
            forKey: .secondsUpdateFrequencyBudget
        )
    }
}

extension TimeDataFormatting {
    package static func decode(
        from decoder: any Decoder
    ) throws -> (any ResolvableStringAttribute)? {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(AnyCodable<SafelyCodableRequirement>.self).value
        guard let value = value as? any SafelyCodableResolvable else {
            throw DecodingError.typeMismatch(
                type(of: value),
                .init(
                    codingPath: [],
                    debugDescription: "AnyDecodable decoded different type than expected"
                )
            )
        }
        return value
    }
}

extension TimeDataFormatting.Resolvable {
    package static func encode(
        _ resolvable: TimeDataFormatting.Resolvable<Source, Format>,
        to encoder: any Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        try container.encode(
            AnyCodable<SafelyCodableRequirement>(resolvable)
        )
    }
}

extension TimeDataFormatting.Resolvable {
    package func representation(
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation {
        guard let resolvable = self as? any SafelyCodableResolvable else {
            return self
        }
        return resolvable._representation(for: version)
    }
}

extension TimeDataFormatting.Resolvable: SafelyCodableResolvable where Format: SafelySerializableDiscreteFormatStyle {
    fileprivate func makeText() -> Text {
        Text(
            source: source,
            format: format,
            reducedLuminanceBudget: secondsUpdateFrequencyBudget
        )
    }

    fileprivate func serialize(to encoder: any Encoder) throws {
        try Self.encode(self, to: encoder)
    }

    fileprivate func _representation(
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation {
        Format.representation(of: self, for: version)
    }
}
