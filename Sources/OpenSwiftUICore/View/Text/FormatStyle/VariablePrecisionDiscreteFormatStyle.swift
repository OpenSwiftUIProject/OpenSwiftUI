//
//  VariablePrecisionDiscreteFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 82861E6D5DC13850BF3EE0F1AE6295D9 (SwiftUICore)

package import Foundation

package protocol VariablePrecisionDiscreteFormatStyle<FormatInput>: DiscreteFormatStyle where FormatInput: Comparable, FormatInput: Decodable, FormatInput: Encodable, FormatInput: Hashable {
    var precisionTransition: TimeDataFormatting.FormatTransition<FormatInput> { get }
}

extension TimeDataFormatting {
    package struct FormatTransition<FormatInput>: Codable, Hashable where FormatInput: Comparable, FormatInput: Decodable, FormatInput: Encodable, FormatInput: Hashable {
        var range: ClosedRange<FormatInput>
        var handoff: FormatInput

        private enum CodingKeys: CodingKey {
            case range
            case handoff
        }

        package static func == (a: Self, b: Self) -> Bool {
            a.range == b.range && a.handoff == b.handoff
        }

        package func hash(into hasher: inout Hasher) {
            hasher.combine(range)
            hasher.combine(handoff)
        }

        package func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(range, forKey: .range)
            try container.encode(handoff, forKey: .handoff)
        }

        package init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            range = try container.decode(ClosedRange<FormatInput>.self, forKey: .range)
            handoff = try container.decode(FormatInput.self, forKey: .handoff)
        }
    }
}

extension AnyInterfaceIdiom {
    package func reducedLuminanceBudget(
        for updateFrequency: TimeDataFormatting.UpdateFrequency
    ) -> TimeInterval {
        switch updateFrequency {
        case .high:
            return 0.0
        case .second:
            switch self {
            case .complication:
                return 0.0
            case .widget:
                return 60.0
            case .watch:
                return 60.0
            default:
                return 60.0
            }
        case .minute:
            return .infinity
        }
    }
}
