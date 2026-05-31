//
//  TimeDataFormatting.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: C320C90E4A458BC2E4049E0630068186 (SwiftUICore)

import Foundation

// MARK: - TimeDataFormatting

@available(OpenSwiftUI_v6_0, *)
enum TimeDataFormatting: ResolvableStringAttributeFamily {
    static var attribute: NSAttributedString.Key {
        NSAttributedString.Key("OpenSwiftUITimeDataFormatting")
    }

    static func decode(from decoder: any Decoder) throws -> (any ResolvableStringAttribute)? {
        nil
    }

    enum UpdateFrequency: Hashable, Comparable, Codable {
        case high
        case second
        case minute

        var interval: Double {
            switch self {
            case .high: 0.0
            case .second: 1.0
            case .minute: 60.0
            }
        }

        static func < (lhs: UpdateFrequency, rhs: UpdateFrequency) -> Bool {
            lhs.interval < rhs.interval
        }
    }

    struct Resolvable<Source, Format>: ResolvableStringAttribute where Source: TimeDataSourceStorage, Format: DiscreteFormatStyle, Source.Value == Format.FormatInput, Format.FormatOutput: AttributedStringConvertible {
        typealias Family = TimeDataFormatting
        typealias Schedule = Resolvable<Source, Format>
        typealias Entries = AnySequence<Date>

        let source: Source
        let format: Format
        let secondsUpdateFrequencyBudget: Double
        var configuration: Configuration<Source, Format>
        var sizeVariant: TextSizeVariant

        init(
            source: Source,
            format: Format,
            secondsUpdateFrequencyBudget: Double,
            configuration: Configuration<Source, Format>,
            sizeVariant: TextSizeVariant
        ) {
            self.source = source
            self.format = format
            self.secondsUpdateFrequencyBudget = secondsUpdateFrequencyBudget
            self.configuration = configuration
            self.sizeVariant = sizeVariant
        }

        init(
            source: Source,
            format: Format,
            secondsUpdateFrequencyBudget: Double,
            sizeVariant: TextSizeVariant = .regular
        ) {
            // TODO: makeResolvable
            let result = Configuration.makeConfiguration(
                from: source,
                format: format,
                sizeVariant: sizeVariant,
                secondsUpdateFrequencyBudget: secondsUpdateFrequencyBudget
            )
            self.source = source
            self.format = format
            self.secondsUpdateFrequencyBudget = secondsUpdateFrequencyBudget
            self.configuration = result.configuration
            self.sizeVariant = sizeVariant
        }

        static func encode(
            _ resolvable: Resolvable<Source, Format>,
            to encoder: any Encoder
        ) throws {
            _ = resolvable
            _ = encoder
        }

        func representation(
            for version: ArchivedViewInput.DeploymentVersion
        ) -> any ResolvableStringAttributeRepresentation {
            _ = version
            return self
        }

        func resolve(in context: ResolvableStringResolutionContext) -> AttributedString? {
            let value = source.value(for: context.date)
            return format.format(value).attributedString
        }

        var schedule: Schedule? {
            nil
        }

        func entries(
            from startDate: Date,
            mode: TimelineScheduleMode
        ) -> AnySequence<Date> {
            _ = startDate
            _ = mode
            return AnySequence([])
        }
    }

    // FIXME
    struct Configuration<Source, Format> where Source: TimeDataSourceStorage, Format: DiscreteFormatStyle, Source.Value == Format.FormatInput, Format.FormatOutput: AttributedStringConvertible {
        var source: Source
        var highFrequencyFormat: Format
        var lowFrequencyFormat: Format?

        init(
            source: Source,
            highFrequencyFormat: Format,
            lowFrequencyFormat: Format?
        ) {
            self.source = source
            self.highFrequencyFormat = highFrequencyFormat
            self.lowFrequencyFormat = lowFrequencyFormat
        }

        static func makeConfiguration(
            from source: Source,
            format: Format,
            sizeVariant: TextSizeVariant,
            secondsUpdateFrequencyBudget: Double
        ) -> (configuration: Configuration<Source, Format>, exact: Bool) {
            let lowFrequencyFormat: Format?
            if let dependentFormat = format as? any UpdateFrequencyDependentFormatStyle {
                let updateFrequency: UpdateFrequency
                if secondsUpdateFrequencyBudget <= UpdateFrequency.high.interval {
                    updateFrequency = .high
                } else if secondsUpdateFrequencyBudget <= UpdateFrequency.second.interval {
                    updateFrequency = .second
                } else {
                    updateFrequency = .minute
                }
                lowFrequencyFormat = dependentFormat.updateFrequency(updateFrequency) as? Format
            } else {
                lowFrequencyFormat = nil
            }
            let exact = sizeVariant == .regular
            return (
                Configuration(
                    source: source,
                    highFrequencyFormat: format,
                    lowFrequencyFormat: lowFrequencyFormat
                ),
                exact
            )
        }
    }
}
