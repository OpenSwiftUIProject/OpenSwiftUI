//
//  TimeDataFormatting+Configuration.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C193EFCD6B7A8429DFC7DBCDA0FADAF6 (SwiftUICore)

import Foundation

// MARK: - MixedAoDFrequencyFormatInitializer

private protocol MixedAoDFrequencyFormatInitializer<FormatInput, FormatOutput> {
    associatedtype FormatInput
    associatedtype FormatOutput

    func alwaysOnDisplayFormat(
        secondsUpdateFrequencyBudget: TimeInterval,
        sizeVariant: TextSizeVariant
    ) -> (
        style: any DiscreteFormatStyle<FormatInput, FormatOutput>,
        exact: Bool
    )
}

// MARK: - TimeDataFormatting.Configuration

extension TimeDataFormatting {
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
            let alwaysOnDisplayFormat = format.alwaysOnDisplayFormat(
                source: source,
                secondsUpdateFrequencyBudget: secondsUpdateFrequencyBudget,
                sizeVariant: sizeVariant
            )
            return (
                Configuration(
                    source: source,
                    highFrequencyFormat: format.paused(accordingTo: source),
                    lowFrequencyFormat: alwaysOnDisplayFormat?.style
                ),
                sizedFormat.exact || (alwaysOnDisplayFormat?.exact ?? false)
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
            highFrequencyFormat.hash(into: &hasher)
            lowFrequencyFormat?.hash(into: &hasher)
        }

        static func == (
            lhs: Configuration<Source, Format>,
            rhs: Configuration<Source, Format>
        ) -> Bool {
            func equals<T: Equatable>(lhs: T, rhs: Any) -> Bool {
                guard let rhs = rhs as? T else {
                    return false
                }
                return lhs == rhs
            }

            guard equals(
                lhs: lhs.highFrequencyFormat,
                rhs: rhs.highFrequencyFormat
            ) else {
                return false
            }
            switch (lhs.lowFrequencyFormat, rhs.lowFrequencyFormat) {
            case let (lhs?, rhs?):
                return equals(lhs: lhs, rhs: rhs)
            case (nil, nil):
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - PausedFormatStyle

private struct PausedFormatStyle<Source, Format>: DiscreteFormatStyle where Source: TimeDataSourceStorage, Format: DiscreteFormatStyle, Source.Value == Format.FormatInput {
    var source: Source
    var base: Format

    var endDate: Date? {
        source.end.map { source.date(for: $0) }
    }

    func format(_ input: Source.Value) -> Format.FormatOutput {
        guard let end = source.end,
              source.date(for: input) > source.date(for: end) else {
            return base.format(input)
        }
        return base.format(end)
    }

    func discreteInput(before input: Source.Value) -> Source.Value? {
        let previous = base.discreteInput(before: input)
        guard let endDate else {
            return previous
        }
        guard source.date(for: input) < endDate else {
            return source.end
        }
        guard let previous else {
            return nil
        }
        return source.date(for: previous) > endDate
            ? previous
            : source.end
    }

    func discreteInput(after input: Source.Value) -> Source.Value? {
        let next = base.discreteInput(after: input)
        guard let endDate else {
            return next
        }
        guard source.date(for: input) < endDate else {
            return nil
        }
        guard let next else {
            return source.end
        }
        return source.date(for: next) < endDate ? next : source.end
    }

    func input(before input: Source.Value) -> Source.Value? {
        base.input(before: input)
    }

    func input(after input: Source.Value) -> Source.Value? {
        base.input(after: input)
    }
}

// MARK: - MixedFormatStyle

private struct MixedFormatStyle<Format>: DiscreteFormatStyle where Format: DiscreteFormatStyle, Format.FormatInput: Comparable, Format.FormatInput: Decodable, Format.FormatInput: Encodable, Format.FormatInput: Hashable {
    var preferred: Format
    var transition: TimeDataFormatting.FormatTransition<Format.FormatInput>
    var fallback: Format

    func base(for input: Format.FormatInput) -> Format {
        transition.range.contains(input) ? preferred : fallback
    }

    func effectiveInput(
        for input: Format.FormatInput
    ) -> Format.FormatInput {
        if input > transition.range.upperBound,
           input < transition.handoff {
            return transition.handoff
        }
        if input < transition.range.lowerBound,
           input > transition.handoff {
            return transition.handoff
        }
        return input
    }

    func format(_ input: Format.FormatInput) -> Format.FormatOutput {
        let input = effectiveInput(for: input)
        return base(for: input).format(input)
    }

    func discreteInput(
        before input: Format.FormatInput
    ) -> Format.FormatInput? {
        let input = effectiveInput(for: input)
        let result = base(for: input).discreteInput(before: input)
        if input > transition.range.upperBound {
            guard let result else {
                return transition.range.upperBound
            }
            guard result >= transition.handoff else {
                return transition.range.upperBound
            }
            return max(result, transition.range.upperBound)
        }
        if input > transition.range.lowerBound {
            let boundary = preferred.input(before: transition.range.lowerBound)
            switch (result, boundary) {
            case let (result?, boundary?):
                return max(result, boundary)
            case let (result?, nil):
                return result
            case let (nil, boundary?):
                return boundary
            case (nil, nil):
                return nil
            }
        }
        return result
    }

    func discreteInput(
        after input: Format.FormatInput
    ) -> Format.FormatInput? {
        let input = effectiveInput(for: input)
        let result = base(for: input).discreteInput(after: input)
        if input < transition.range.lowerBound {
            guard let result else {
                return transition.range.lowerBound
            }
            guard result <= transition.handoff else {
                return transition.range.lowerBound
            }
            return min(result, transition.range.lowerBound)
        }
        if input < transition.range.upperBound {
            let boundary = preferred.input(after: transition.range.upperBound)
            switch (result, boundary) {
            case let (result?, boundary?):
                return min(result, boundary)
            case let (result?, nil):
                return result
            case let (nil, boundary?):
                return boundary
            case (nil, nil):
                return nil
            }
        }
        return result
    }

    func input(before input: Format.FormatInput) -> Format.FormatInput? {
        let input = effectiveInput(for: input)
        return base(for: input).input(before: input)
    }

    func input(after input: Format.FormatInput) -> Format.FormatInput? {
        let input = effectiveInput(for: input)
        return base(for: input).input(after: input)
    }
}

// MARK: - _MixedAoDFrequencyFormatInitializer

private struct _MixedAoDFrequencyFormatInitializer<Base> where Base: DiscreteFormatStyle {
    let base: Base
    typealias FormatInput = Base.FormatInput
    typealias FormatOutput = Base.FormatOutput
}

extension _MixedAoDFrequencyFormatInitializer: MixedAoDFrequencyFormatInitializer where Base: UpdateFrequencyDependentFormatStyle, FormatInput: Comparable, FormatInput: Decodable, FormatInput: Encodable, FormatInput: Hashable {

    func alwaysOnDisplayFormat(
        secondsUpdateFrequencyBudget: TimeInterval,
        sizeVariant: TextSizeVariant
    ) -> (
        style: any DiscreteFormatStyle<FormatInput, FormatOutput>,
        exact: Bool
    ) {
        let fallback = base.updateFrequency(.minute).exactSizeVariant(sizeVariant)
        guard secondsUpdateFrequencyBudget >= 60.0 else {
            return fallback
        }
        guard let variablePrecisionFormat = base as? any VariablePrecisionDiscreteFormatStyle<FormatInput> else {
            return fallback
        }
        let transition = variablePrecisionFormat.precisionTransition
        let preferred = base.updateFrequency(.second).exactSizeVariant(sizeVariant)
        return (
            MixedFormatStyle(
                preferred: preferred.style,
                transition: transition,
                fallback: fallback.style
            ),
            fallback.exact || preferred.exact
        )
    }
}

// MARK: - DiscreteFormatStyle Extension

extension DiscreteFormatStyle {
    fileprivate func alwaysOnDisplayFormat<Source>(
        source: Source,
        secondsUpdateFrequencyBudget: TimeInterval,
        sizeVariant: TextSizeVariant
    ) -> (
        style: any DiscreteFormatStyle<FormatInput, FormatOutput>,
        exact: Bool
    )? where Source: TimeDataSourceStorage, Source.Value == FormatInput {
        if let initializer = _MixedAoDFrequencyFormatInitializer(base: self) as? any MixedAoDFrequencyFormatInitializer<FormatInput, FormatOutput> {
            let result = initializer.alwaysOnDisplayFormat(
                secondsUpdateFrequencyBudget: secondsUpdateFrequencyBudget,
                sizeVariant: sizeVariant
            )
            return (
                result.style.paused(accordingTo: source),
                result.exact
            )
        } else if let format = self as? any UpdateFrequencyDependentFormatStyle {
            let (style, exact) = format
                .updateFrequency(.minute)
                .exactSizeVariant(sizeVariant) as! (Self, Bool)
            return (
                style.paused(accordingTo: source),
                exact
            )
        } else {
            return nil
        }
    }

    fileprivate func paused<Source>(
        accordingTo source: Source
    ) -> any DiscreteFormatStyle<FormatInput, FormatOutput>
        where Source: TimeDataSourceStorage, Source.Value == FormatInput
    {
        guard source.end != nil else {
            return self
        }
        return PausedFormatStyle(source: source, base: self)
    }
}
