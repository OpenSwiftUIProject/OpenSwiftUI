//
//  ResolvableProgress.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 267381962A5721ACE73988C284C57A9A (SwiftUICore)

package import Foundation

// MARK: - ResolvableProgress

package struct ResolvableProgress {
    package var interval: ClosedRange<Date>
    package var countdown: Bool

    package init(interval: ClosedRange<Date>, countdown: Bool) {
        self.interval = interval
        self.countdown = countdown
    }
}

extension ResolvableProgress: ConfigurationBasedResolvableStringAttribute {
    package static var attribute = NSAttributedString.Key("OpenSwiftUI.ResolvableProgress")

    package func resolve(
        in context: ResolvableStringResolutionContext
    ) -> AttributedString? {
        let progress = interval.progress(at: context.date, countdown: countdown)
        return progress.formatted(
            FloatingPointFormatStyle<Double>.Percent()
                .rounded(rule: .toNearestOrAwayFromZero, increment: 1)
                .attributed
        )
    }

    package var invalidationConfiguration: ResolvableAttributeConfiguration {
        .timerInterval(
            interval: DateInterval(start: interval.lowerBound, end: interval.upperBound),
            countdown: countdown
        )
    }

    private enum CodingKeys: CodingKey {
        case interval
        case countdown
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        interval = try container.decode(ClosedRange<Date>.self, forKey: .interval)
        countdown = try container.decode(Bool.self, forKey: .countdown)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(interval, forKey: .interval)
        try container.encode(countdown, forKey: .countdown)
    }
}

extension ResolvableProgress: Hashable {}

extension ResolvableProgress: CustomDebugStringConvertible {
    package var debugDescription: String {
        "    ResolvableProgress(interval: \(interval.lowerBound)...\(interval.upperBound),    countdown: \(countdown))\""
    }
}
