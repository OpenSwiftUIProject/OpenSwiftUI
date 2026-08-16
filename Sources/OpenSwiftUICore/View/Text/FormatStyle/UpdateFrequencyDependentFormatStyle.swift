//
//  UpdateFrequencyDependentFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 74D4881E07CAAC047E60006F74D2CBA5 (SwiftUICore)

package import Foundation

extension TimeDataFormatting {
    package enum UpdateFrequency: Codable, Hashable, Comparable {
        case high
        case second
        case minute

        package init(duration: Duration) {
            if Duration.seconds(1.0 / 30.0) < duration {
                self = Duration.seconds(1.0) < duration ? .minute : .second
            } else {
                self = .high
            }
        }

        package var frequency: Double {
            switch self {
            case .high: 30.0
            case .second: 1.0
            case .minute: 1.0 / 60.0
            }
        }

        package var interval: TimeInterval {
            1.0 / frequency
        }

        package var magnitude: Calendar.Component.Magnitude {
            .init(interval)
        }

        package var duration: Duration {
            .seconds(interval)
        }

        package static func < (lhs: UpdateFrequency, rhs: UpdateFrequency) -> Bool {
            lhs.frequency < rhs.frequency
        }

        private enum CodingKeys: String, CodingKey {
            case high
            case second
            case minute
        }

        private enum HighCodingKeys: CodingKey {}

        private enum SecondCodingKeys: CodingKey {}

        private enum MinuteCodingKeys: CodingKey {}

        package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .high:
                _ = container.nestedContainer(
                    keyedBy: HighCodingKeys.self,
                    forKey: .high
                )
            case .second:
                _ = container.nestedContainer(
                    keyedBy: SecondCodingKeys.self,
                    forKey: .second
                )
            case .minute:
                _ = container.nestedContainer(
                    keyedBy: MinuteCodingKeys.self,
                    forKey: .minute
                )
            }
        }

        package init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let keys = container.allKeys
            guard keys.count == 1 else {
                throw DecodingError.typeMismatch(
                    Self.self,
                    .init(
                        codingPath: container.codingPath,
                        debugDescription: "Invalid number of keys found, expected one."
                    )
                )
            }
            switch keys[0] {
            case .high:
                _ = try container.nestedContainer(
                    keyedBy: HighCodingKeys.self,
                    forKey: .high
                )
                self = .high
            case .second:
                _ = try container.nestedContainer(
                    keyedBy: SecondCodingKeys.self,
                    forKey: .second
                )
                self = .second
            case .minute:
                _ = try container.nestedContainer(
                    keyedBy: MinuteCodingKeys.self,
                    forKey: .minute
                )
                self = .minute
            }
        }
    }
}

package protocol UpdateFrequencyDependentFormatStyle: FormatStyle {
    func updateFrequency(_ frequency: TimeDataFormatting.UpdateFrequency) -> Self
}

#if canImport(Darwin)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.FormatStyle: UpdateFrequencyDependentFormatStyle {
    package func updateFrequency(_ frequency: TimeDataFormatting.UpdateFrequency) -> Self {
        switch frequency {
        case .high:
            self
        case .second:
            secondFraction(.omitted)
        case .minute:
            second(.omitted).secondFraction(.omitted)
        }
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
extension Date.FormatStyle.Attributed: UpdateFrequencyDependentFormatStyle {
    package func updateFrequency(_ frequency: TimeDataFormatting.UpdateFrequency) -> Self {
        switch frequency {
        case .high:
            self
        case .second:
            secondFraction(.omitted)
        case .minute:
            second(.omitted).secondFraction(.omitted)
        }
    }
}

extension WhitespaceRemovingFormatStyle: UpdateFrequencyDependentFormatStyle
    where Format: UpdateFrequencyDependentFormatStyle
{
    package func updateFrequency(
        _ frequency: TimeDataFormatting.UpdateFrequency
    ) -> WhitespaceRemovingFormatStyle<Format, Key> {
        var style = self
        style.base = base.updateFrequency(frequency)
        return style
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
extension Date.AnchoredRelativeFormatStyle: UpdateFrequencyDependentFormatStyle {
    package func updateFrequency(_ frequency: TimeDataFormatting.UpdateFrequency) -> Self {
        guard frequency != .high else {
            return self
        }
        var style = self
        style.allowedFields.subtract(
            style.allowedFields.filter { $0.magnitude < frequency.magnitude }
        )
        if style.allowedFields.isEmpty {
            style.allowedFields.insert(frequency == .second ? .second : .minute)
        }
        return style
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Duration.UnitsFormatStyle: UpdateFrequencyDependentFormatStyle {
    package func updateFrequency(_ frequency: TimeDataFormatting.UpdateFrequency) -> Self {
        guard frequency != .high else {
            return self
        }
        var style = self
        style.allowedUnits.subtract(
            style.allowedUnits.filter { $0.magnitude < frequency.magnitude }
        )
        let minimumUnit = style.allowedUnits.min { $0.magnitude < $1.magnitude }
        let fallbackUnit: Duration.UnitsFormatStyle.Unit =
            frequency == .second ? .seconds : .minutes
        if minimumUnit == nil {
            style.allowedUnits.insert(fallbackUnit)
        }
        let smallestUnit = minimumUnit ?? fallbackUnit
        let increment = frequency.magnitude.ratio(to: smallestUnit.magnitude)
        if let roundingIncrement = style.fractionalPartDisplay.roundingIncrement {
            style.fractionalPartDisplay.roundingIncrement = min(roundingIncrement, increment)
        }
        let maximumLength = Int(log10(1.0 / increment))
        style.fractionalPartDisplay.maximumLength = min(
            style.fractionalPartDisplay.maximumLength,
            maximumLength
        )
        style.fractionalPartDisplay.minimumLength = min(
            style.fractionalPartDisplay.minimumLength,
            style.fractionalPartDisplay.maximumLength
        )
        return style
    }
}
#endif
