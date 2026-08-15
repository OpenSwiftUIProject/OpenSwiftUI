//
//  TimeDataFormatting.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: C320C90E4A458BC2E4049E0630068186 (SwiftUICore)

package import Foundation

// MARK: - TimeDataFormatting

@available(OpenSwiftUI_v6_0, *)
package enum TimeDataFormatting: ResolvableStringAttributeFamily {
    package static var attribute: NSAttributedString.Key {
        NSAttributedString.Key("OpenSwiftUITimeDataFormatting")
    }

    package static func decode(from decoder: any Decoder) throws -> (any ResolvableStringAttribute)? {
        let value = try decoder.singleValueContainer().decode(
            AnyCodable<SafelyCodableRequirement>.self
        )
        return value.value as? any ResolvableStringAttribute
    }

    enum UpdateFrequency: Hashable, Comparable, Codable, Sendable {
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

        package static func encode(
            _ resolvable: Resolvable<Source, Format>,
            to encoder: any Encoder
        ) throws {
            guard let resolvable = resolvable as? any SafelyCodableResolvable else {
                throw EncodingError.invalidValue(
                    resolvable,
                    EncodingError.Context(
                        codingPath: encoder.codingPath,
                        debugDescription: "The time-data format is not safely codable."
                    )
                )
            }
            try resolvable.serialize(to: encoder)
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
        guard let resolvable = try TimeDataFormatting.decode(from: decoder) as? any SafelyCodableResolvable else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "The decoded value is not a safely codable time-data format."
                )
            )
        }
        self.resolvable = resolvable
    }

    public func encode(to encoder: any Encoder) throws {
        try resolvable.serialize(to: encoder)
    }

    package var text: Text {
        resolvable.makeText()
    }

    package func representation(
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation {
        resolvable._representation(for: version)
    }

    package static var attribute: NSAttributedString.Key {
        TimeDataFormatting.attribute
    }
}

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
    ) -> (any Codable.Type)? {
        guard type is any SafelyCodableResolvable.Type else {
            return nil
        }
        return type as? any Codable.Type
    }
}

extension TimeDataFormatting.Resolvable: Codable where Format: SafelySerializableDiscreteFormatStyle {
    private enum CodingKeys: String, CodingKey {
        case source
        case format
        case secondsUpdateFrequencyBudget
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let source = try container.decode(Source.self, forKey: .source)
        let format = try container.decode(Format.self, forKey: .format)
        let budget = try container.decode(Double.self, forKey: .secondsUpdateFrequencyBudget)
        self.init(
            source: source,
            format: format,
            secondsUpdateFrequencyBudget: budget
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
        try container.encode(format, forKey: .format)
        try container.encode(
            secondsUpdateFrequencyBudget,
            forKey: .secondsUpdateFrequencyBudget
        )
    }
}

extension TimeDataFormatting.Resolvable: SafelyCodableResolvable where Format: SafelySerializableDiscreteFormatStyle {
    fileprivate func makeText() -> Text {
        Text(
            anyTextStorage: TimeDataFormattingStorage(
                source: source,
                format: format,
                reducedLuminanceBudget: secondsUpdateFrequencyBudget
            )
        )
    }

    fileprivate func serialize(to encoder: any Encoder) throws {
        try AnyCodable<SafelyCodableRequirement>(self).encode(to: encoder)
    }

    fileprivate func _representation(
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation {
        Format.representation(of: self, for: version)
    }
}
