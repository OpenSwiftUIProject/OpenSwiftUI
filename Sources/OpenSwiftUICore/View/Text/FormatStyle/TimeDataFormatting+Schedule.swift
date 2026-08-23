//
//  TimeDataFormatting+Schedule.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: CC08465156E6A078543AE4CF0DC49A81 (SwiftUICore)

package import Foundation

// MARK: - TimeDataFormatting.Resolvable + TimelineSchedule

extension TimeDataFormatting.Resolvable: TimelineSchedule {
    package func entries(
        from startDate: Date,
        mode: Mode
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
        } else {
            return resolved.format.complyingFormatStyleEntries(
                from: startDate,
                for: source
            )
        }
    }
}

// MARK: - DiscreteFormatStyle Extension

extension DiscreteFormatStyle {
    fileprivate func fallbackRedactionEntries<Source>(
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

    fileprivate func complyingFormatStyleEntries<Source>(
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

// MARK: - Schedule Entries

extension TimeDataFormatting {
    fileprivate enum EntriesState {
        case start(Date)
        case previous(Date)
        case done

        mutating func next(_ nextEntry: (Date) -> Date?) -> Date? {
            switch self {
            case let .start(date):
                self = .previous(date)
                return date
            case let .previous(previous):
                guard let next = nextEntry(previous) else {
                    self = .done
                    return nil
                }
                self = .previous(next)
                let interval = 1.0 / 30.0
                return next.timeIntervalSince(previous) > interval
                    ? next + interval
                    : next
            case .done:
                return nil
            }
        }
    }

    fileprivate struct ComplyingFormatStyleEntries<Source, Format>: Sequence, IteratorProtocol where Source: TimeDataSourceStorage, Format: DiscreteFormatStyle, Source.Value == Format.FormatInput {
        var state: EntriesState
        let source: Source
        let format: Format

        init(state: EntriesState, source: Source, format: Format) {
            self.state = state
            self.source = source
            self.format = format
        }

        mutating func next() -> Date? {
            state.next(nextEntry(for:))
        }

        func nextEntry(for date: Date) -> Date? {
            source.withValue(for: date) { value in
                format.discreteInput(after: value)
            }.map { next in
                next <= date ? date.nextUp : next
            }
        }
    }

    fileprivate struct FallbackRedactionEntries<Source, Format>: Sequence, IteratorProtocol where Source: TimeDataSourceStorage, Format: DiscreteFormatStyle, Source.Value == Format.FormatInput {
        var state: EntriesState
        let source: Source
        let format: Format
        let allowedFrequency: UpdateFrequency

        init(state: EntriesState, source: Source, format: Format, allowedFrequency: UpdateFrequency) {
            self.state = state
            self.source = source
            self.format = format
            self.allowedFrequency = allowedFrequency
        }

        mutating func next() -> Date? {
            state.next(nextEntry(for:))
        }

        func nextEntry(for date: Date) -> Date? {
            let next: Date?
            if format.needsRedaction(
                for: allowedFrequency,
                evaluating: source,
                at: date
            ) {
                let allowedDate = date.addingTimeInterval(allowedFrequency.interval)
                next = source.withValue(for: allowedDate) { value in
                    let rounded = source.round(
                        value,
                        .down,
                        toMultipleOf: allowedFrequency.interval
                    )
                    guard source.convergesToZero(rounded) else {
                        return rounded
                    }
                    if let next = format.discreteInput(after: rounded) {
                        return next
                    }
                    guard let previous = format.discreteInput(before: rounded) else {
                        return nil
                    }
                    return format.input(after: previous)
                }
            } else {
                next = source.withValue(for: date) { value in
                    format.discreteInput(after: value)
                }
            }
            return next.map { next in
                next <= date ? date.nextUp : next
            }
        }
    }
}
