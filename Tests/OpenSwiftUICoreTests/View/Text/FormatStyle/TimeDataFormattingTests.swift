//
//  TimeDataFormattingTests.swift
//  OpenSwiftUICoreTests

import Foundation
@_spi(Private) @testable import OpenSwiftUICore
import Testing

@Suite
struct TimeDataFormattingTests {
    fileprivate typealias Resolvable = TimeDataFormatting.Resolvable<TimeDataFormattingTestSource, TestFormat>

    @Test
    func resolvesAndSchedulesUpdates() throws {
        let resolvable = Resolvable(
            source: TimeDataFormattingTestSource(offset: 2),
            format: TestFormat(prefix: "value:"),
            secondsUpdateFrequencyBudget: 1.0
        )
        let date = Date(timeIntervalSinceReferenceDate: 10.0)
        let context = ResolvableStringResolutionContext(
            referenceDate: date,
            environment: EnvironmentValues()
        )

        let output = try #require(resolvable.resolve(in: context))
        #expect(String(output.characters) == "value:12")
        #expect(resolvable.schedule == resolvable)
        #expect(resolvable.requiredFeatures == .checkInterpolationStrategy)

        let entries = Array(
            resolvable.entries(from: date, mode: .normal).prefix(3)
        )
        let displayOffset = 1.0 / 30.0
        #expect(entries == [
            Date(timeIntervalSinceReferenceDate: 10.0),
            Date(timeIntervalSinceReferenceDate: 11.0 + displayOffset),
            Date(timeIntervalSinceReferenceDate: 12.0 + displayOffset),
        ])
    }

    @Test
    func replacingFormatUsesRegularSizeVariant() {
        let source = TimeDataFormattingTestSource(offset: 4)
        let resolvable = Resolvable(
            source: source,
            format: TestFormat(prefix: "old:"),
            secondsUpdateFrequencyBudget: 60.0,
            sizeVariant: .compact
        )

        let replaced = resolvable.replacingFormat(
            with: TestFormat(prefix: "new:")
        )

        #expect(replaced.source == source)
        #expect(replaced.format == TestFormat(prefix: "new:"))
        #expect(replaced.secondsUpdateFrequencyBudget == 60.0)
        #expect(replaced.sizeVariant == .regular)
    }

    @Test
    func sizeVariantAndIdentityIncludeAllInputs() {
        let base = Resolvable(
            source: TimeDataFormattingTestSource(offset: 0),
            format: TestFormat(prefix: "value:"),
            secondsUpdateFrequencyBudget: 1.0
        )
        let compact = base.sizeVariant(.compact)

        #expect(!compact.exact)
        #expect(compact.resolvable.sizeVariant == .compact)
        #expect(compact.resolvable != base)
        #expect(base != Resolvable(
            source: TimeDataFormattingTestSource(offset: 1),
            format: TestFormat(prefix: "value:"),
            secondsUpdateFrequencyBudget: 1.0
        ))
        #expect(base != Resolvable(
            source: TimeDataFormattingTestSource(offset: 0),
            format: TestFormat(prefix: "other:"),
            secondsUpdateFrequencyBudget: 1.0
        ))
        #expect(base != Resolvable(
            source: TimeDataFormattingTestSource(offset: 0),
            format: TestFormat(prefix: "value:"),
            secondsUpdateFrequencyBudget: 60.0
        ))
    }

    @Test
    func updateFrequencyUsesThirtyHertzHighFrequency() {
        typealias Frequency = TimeDataFormatting.UpdateFrequency

        #expect(Frequency.high.frequency == 30.0)
        #expect(Frequency.high.interval == 1.0 / 30.0)
        #expect(Frequency.high.duration == .seconds(1.0 / 30.0))
        #expect(Frequency.high.magnitude.interval == 1.0 / 30.0)
        #expect(Frequency(duration: .seconds(1.0 / 30.0)) == .high)
        #expect(Frequency(duration: .seconds(0.5)) == .second)
        #expect(Frequency(duration: .seconds(1.0)) == .second)
        #expect(Frequency(duration: .seconds(1.01)) == .minute)
        #expect(Frequency.minute < .second)
        #expect(Frequency.second < .high)
    }

    @Test
    func updateFrequencyCodableShapeMatchesSynthesizedEnumEncoding() throws {
        typealias Frequency = TimeDataFormatting.UpdateFrequency
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        #expect(try String(decoding: encoder.encode(Frequency.high), as: UTF8.self) == #"{"high":{}}"#)
        #expect(try String(decoding: encoder.encode(Frequency.second), as: UTF8.self) == #"{"second":{}}"#)
        #expect(try String(decoding: encoder.encode(Frequency.minute), as: UTF8.self) == #"{"minute":{}}"#)

        for frequency in [Frequency.high, .second, .minute] {
            let decoded = try JSONDecoder().decode(
                Frequency.self,
                from: encoder.encode(frequency)
            )
            #expect(decoded == frequency)
        }
    }

    @Test
    func reducedLuminanceUsesFrequencyDependentFormat() throws {
        let resolvable = TimeDataFormatting.Resolvable(
            source: TimeDataFormattingTestSource(offset: 0),
            format: FrequencyFormat(frequency: .high),
            secondsUpdateFrequencyBudget: 60.0
        )
        var environment = EnvironmentValues()
        environment.isLuminanceReduced = true
        let context = ResolvableStringResolutionContext(
            referenceDate: Date(timeIntervalSinceReferenceDate: 5.0),
            environment: environment
        )

        let output = try #require(resolvable.resolve(in: context))
        #expect(String(output.characters) == "minute:5")
    }

    @Test
    func codableRoundTripUsesStableInputsAndDefaultsTransientState() throws {
        let original = Resolvable(
            source: TimeDataFormattingTestSource(offset: 3),
            format: TestFormat(prefix: "value:"),
            secondsUpdateFrequencyBudget: 12.0,
            sizeVariant: .compact
        )

        let data = try JSONEncoder().encode(original)
        let object = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        #expect(Set(object.keys) == [
            "source",
            "format",
            "secondsUpdateFrequencyBudget",
        ])

        let decoded = try JSONDecoder().decode(Resolvable.self, from: data)
        #expect(decoded.source == original.source)
        #expect(decoded.format == original.format)
        #expect(decoded.secondsUpdateFrequencyBudget == 12.0)
        #expect(decoded.sizeVariant == .regular)
    }

    @Test
    func safelySerializableContainerRoundTripsDynamicType() throws {
        typealias SafeResolvable = TimeDataFormatting.Resolvable<TimeDataFormattingTestSource, TimeDataFormattingSafeFormat>
        let resolvable = SafeResolvable(
            source: TimeDataFormattingTestSource(offset: 7),
            format: TimeDataFormattingSafeFormat(prefix: "safe:"),
            secondsUpdateFrequencyBudget: 1.0
        )
        let container = try #require(
            TimeDataFormattingContainer(resolvable: resolvable)
        )

        let data = try JSONEncoder().encode(container)
        let decoded = try JSONDecoder().decode(
            TimeDataFormattingContainer.self,
            from: data
        )
        let representation = try #require(
            decoded.representation(for: .v6) as? SafeResolvable
        )

        #expect(representation == resolvable)
    }

    @Test
    func dateFormatStyleUsesCurrentDateForLegacyArchives() throws {
        let locale = Locale(identifier: "en_US_POSIX")
        let calendar = Calendar(identifier: .gregorian)
        let timeZone = try #require(TimeZone(secondsFromGMT: 3600))
        let format = Date.FormatStyle(
            date: .omitted,
            time: .omitted,
            locale: locale,
            calendar: calendar,
            timeZone: timeZone
        )
        .year()
        .month(.twoDigits)
        .day(.twoDigits)
        let resolvable = TimeDataFormatting.Resolvable(
            source: TimeDataSource<Date>.DateStorage.identity,
            format: format,
            secondsUpdateFrequencyBudget: 60.0
        )

        let current = try #require(
            Date.FormatStyle.Attributed.representation(
                of: resolvable.replacingFormat(with: format.attributedStyle),
                for: .v5
            ) as? ResolvableCurrentDate
        )
        #expect(current.dateFormat == ResolvableCurrentDate.DateFormat.template("dMYYYY"))
        #expect(current.locale == locale)
        #expect(current.calendar == calendar)
        #expect(current.timeZone == timeZone)
        #expect(
            Date.FormatStyle.representation(of: resolvable, for: .v6)
                is TimeDataFormatting.Resolvable<
                    TimeDataSource<Date>.DateStorage,
                    Date.FormatStyle
                >
        )

        let verbatim = Date.VerbatimFormatStyle(
            format: "yyyy",
            locale: locale,
            timeZone: timeZone,
            calendar: calendar
        )
        let verbatimResolvable = TimeDataFormatting.Resolvable(
            source: TimeDataSource<Date>.DateStorage.identity,
            format: verbatim,
            secondsUpdateFrequencyBudget: 60.0
        )
        let verbatimRepresentation = try #require(
            Date.VerbatimFormatStyle.representation(
                of: verbatimResolvable,
                for: .v5
            ) as? ResolvableCurrentDate
        )
        #expect(
            verbatimRepresentation.dateFormat ==
                ResolvableCurrentDate.DateFormat.format("'yyyy'")
        )
        #expect(verbatimRepresentation.locale == locale)
        #expect(verbatimRepresentation.calendar == calendar)
        #expect(verbatimRepresentation.timeZone == timeZone)
    }

    @Test
    func componentAndRelativeStylesMapToLegacyUnits() throws {
        let anchor = Date(timeIntervalSinceReferenceDate: 1000)
        #if canImport(Darwin)
        let components = Date.ComponentsFormatStyle(
            style: .narrow,
            fields: [.month, .week]
        )
        let componentResolvable = TimeDataFormatting.Resolvable(
            source: TimeDataSource<Range<Date>>.DateRangeStorage
                .dateRangeStartingAt(date: anchor),
            format: components,
            secondsUpdateFrequencyBudget: 60.0
        )
        let componentRepresentation = try #require(
            Date.ComponentsFormatStyle.representation(
                of: componentResolvable,
                for: .v5
            ) as? ResolvableAbsoluteDate
        )
        #expect(componentRepresentation.date == anchor)
        #expect(componentRepresentation.style.storage == .relative)
        #expect(
            componentRepresentation.style.unitConfiguration?.units ==
                [.month, .weekOfMonth]
        )
        #expect(componentRepresentation.style.unitConfiguration?.style == .short)
        #endif

        let relative = Date.AnchoredRelativeFormatStyle(
            anchor: anchor,
            allowedFields: [.week, .day],
            unitsStyle: .abbreviated
        )
        let relativeResolvable = TimeDataFormatting.Resolvable(
            source: TimeDataSource<Date>.DateStorage.identity,
            format: relative,
            secondsUpdateFrequencyBudget: 60.0
        )
        let relativeRepresentation = try #require(
            Date.AnchoredRelativeFormatStyle.representation(
                of: relativeResolvable,
                for: .v5
            ) as? ResolvableAbsoluteDate
        )
        #expect(relativeRepresentation.date == anchor)
        #expect(relativeRepresentation.style.storage == .relative)
        #expect(
            relativeRepresentation.style.unitConfiguration?.units ==
                [.weekOfYear, .day]
        )
        #expect(relativeRepresentation.style.unitConfiguration?.style == .full)
    }

    @Test
    func durationStylesMapToLegacyTimerAndRelativeUnits() throws {
        let anchor = Date(timeIntervalSinceReferenceDate: 2000)
        let source = TimeDataSource<Duration>.DurationStorage.durationOffset(date: anchor)
        let timeFormat = Duration.TimeFormatStyle(
            pattern: .hourMinuteSecond,
            locale: Locale(identifier: "en_US_POSIX")
        )
        let timeResolvable = TimeDataFormatting.Resolvable(
            source: source,
            format: timeFormat,
            secondsUpdateFrequencyBudget: 1.0
        )
        let timeRepresentation = try #require(
            Duration.TimeFormatStyle.representation(
                of: timeResolvable,
                for: .v5
            ) as? ResolvableAbsoluteDate
        )
        #expect(timeRepresentation.date == anchor)
        #expect(timeRepresentation.style.storage == .timer)
        #expect(
            timeRepresentation.style.unitConfiguration?.units ==
                [.hour, .minute, .second]
        )

        let unitsFormat = Duration.UnitsFormatStyle(
            allowedUnits: [.weeks, .milliseconds],
            width: .condensedAbbreviated
        )
        let unitsResolvable = TimeDataFormatting.Resolvable(
            source: source,
            format: unitsFormat,
            secondsUpdateFrequencyBudget: 60.0
        )
        let unitsRepresentation = try #require(
            Duration.UnitsFormatStyle.representation(
                of: unitsResolvable,
                for: .v5
            ) as? ResolvableAbsoluteDate
        )
        #expect(unitsRepresentation.date == anchor)
        #expect(unitsRepresentation.style.storage == .relative)
        #expect(
            unitsRepresentation.style.unitConfiguration?.units ==
                [.weekOfYear, .nanosecond]
        )
        #expect(unitsRepresentation.style.unitConfiguration?.style == .full)
    }

    @Suite("Test TimeDataFormatting schedule")
    struct ScheduleTests {
        @Test
        func lowFrequencyEntriesUseMinuteFallbackRedaction() {
            let resolvable = TimeDataFormatting.Resolvable(
                source: TimeDataFormattingTestSource(offset: 0),
                format: TestFormat(prefix: "value:"),
                secondsUpdateFrequencyBudget: 1.0
            )
            let startDate = Date(timeIntervalSinceReferenceDate: 10.0)

            let entries = Array(
                resolvable.entries(
                    from: startDate,
                    mode: .lowFrequency
                ).prefix(3)
            )

            let displayOffset = 1.0 / 30.0
            #expect(entries == [
                startDate,
                Date(timeIntervalSinceReferenceDate: 60.0 + displayOffset),
                Date(timeIntervalSinceReferenceDate: 120.0 + displayOffset),
            ])
        }
    }

    @Suite("Test AttributedString.redact API")
    struct RedactionTests {
        @Test
        func redactionUsesSemanticTimeFields() throws {
            let locale = Locale(identifier: "en_US_POSIX")
            let original = try attributedDuration()

            var highFrequency = original
            highFrequency.redact(for: .high, locale: locale)
            #expect(String(highFrequency.characters) == "12.345")

            var seconds = original
            seconds.redact(for: .second, locale: locale)
            #expect(String(seconds.characters) == "12.−−−")

            var minutes = original
            minutes.redact(for: .minute, locale: locale)
            #expect(String(minutes.characters) == "−−.−−−")
        }

        @Test
        func redactionHandlesPlainTextFractionalsAndMeasurements() throws {
            let locale = Locale(identifier: "en_US_POSIX")

            var plainText = AttributedString("A½")
            plainText.redact(for: .second, locale: locale)
            #expect(String(plainText.characters) == "A−")

            var fractionalSeconds = AttributedString("12.345")
            fractionalSeconds.dateField = .second
            fractionalSeconds.redact(for: .second, locale: locale)
            #expect(String(fractionalSeconds.characters) == "12.−−−")

            var measurement = AttributedString("twelve seconds")
            let valueRange = try #require(measurement.range(of: "twelve"))
            let unitRange = try #require(measurement.range(of: "seconds"))
            measurement[valueRange].measurement = .value
            measurement[unitRange].measurement = .unit
            measurement.redact(for: .second, locale: locale)
            #expect(String(measurement.characters) == "−−−−−− seconds")
        }

        private func attributedDuration() throws -> AttributedString {
            var value = AttributedString("12.345")
            let seconds = try #require(value.range(of: "12"))
            let milliseconds = try #require(value.range(of: "345"))
            value[seconds].durationField = .seconds
            value[milliseconds].durationField = .milliseconds
            return value
        }
    }
}

struct TimeDataFormattingTestSource: TimeDataSourceStorage {
    var offset: Int

    func value(for date: Date) -> Int {
        Int(date.timeIntervalSinceReferenceDate.rounded(.down)) + offset
    }

    func date(for value: Int) -> Date {
        Date(timeIntervalSinceReferenceDate: TimeInterval(value - offset))
    }

    func round(
        _ value: Int,
        _ rule: FloatingPointRoundingRule,
        toMultipleOf multiple: Double
    ) -> Int {
        guard multiple != 0.0 else {
            return value
        }
        return Int((Double(value) / multiple).rounded(rule) * multiple)
    }

    func convergesToZero(_ value: Int) -> Bool {
        value == 0
    }
}

private struct TestFormat: DiscreteFormatStyle, Codable, Hashable {
    var prefix: String

    func format(_ value: Int) -> String {
        "\(prefix)\(value)"
    }

    func discreteInput(before input: Int) -> Int? {
        input - 1
    }

    func discreteInput(after input: Int) -> Int? {
        input + 1
    }
}

private struct FrequencyFormat: DiscreteFormatStyle, Hashable,
    UpdateFrequencyDependentFormatStyle
{
    var frequency: TimeDataFormatting.UpdateFrequency

    func format(_ value: Int) -> String {
        "\(frequency):\(value)"
    }

    func discreteInput(before input: Int) -> Int? {
        input - 1
    }

    func discreteInput(after input: Int) -> Int? {
        input + 1
    }

    func updateFrequency(
        _ frequency: TimeDataFormatting.UpdateFrequency
    ) -> FrequencyFormat {
        FrequencyFormat(frequency: frequency)
    }
}

struct TimeDataFormattingSafeFormat: SafelySerializableDiscreteFormatStyle, Codable,
    Hashable
{
    var prefix: String

    func format(_ value: Int) -> String {
        "\(prefix)\(value)"
    }

    func discreteInput(before input: Int) -> Int? {
        input - 1
    }

    func discreteInput(after input: Int) -> Int? {
        input + 1
    }

    static func representation<Source>(
        of resolvable: TimeDataFormatting.Resolvable<Source, TimeDataFormattingSafeFormat>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation where Source: TimeDataSourceStorage, Source.Value == Int {
        _ = version
        return resolvable
    }
}
