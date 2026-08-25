//
//  ProgressView+Date.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E25B5CE50FE780022155187DDAA79ACA (SwiftUI)

public import Foundation
@_spi(Private)
import OpenSwiftUICore

// MARK: - DefaultDateProgressLabel

/// The default current value label used by a date-relative progress view.
@available(OpenSwiftUI_v4_0, *)
public struct DefaultDateProgressLabel: View {
    var interval: ClosedRange<Date>
    var countdown: Bool

    public var body: some View {
        Text(
            timerInterval: interval,
            countsDown: countdown
        )
    }
}

@available(*, unavailable)
extension DefaultDateProgressLabel: Sendable {}

// MARK: - Date-Relative Initializers

@available(OpenSwiftUI_v4_0, *)
extension ProgressView {
    /// Creates a progress view that displays progress over a date interval.
    nonisolated public init(
        timerInterval: ClosedRange<Date>,
        countsDown: Bool = true,
        @ViewBuilder label: () -> Label,
        @ViewBuilder currentValueLabel: () -> CurrentValueLabel
    ) {
        base = .custom(
            CustomProgressView(
                interval: timerInterval,
                countdown: countsDown,
                label: label(),
                currentValueLabel: currentValueLabel()
            )
        )
    }
}

@_spi(_)
@available(OpenSwiftUI_v4_0, *)
extension ProgressView {
    @available(*, deprecated, renamed: "init(timerInterval:countsDown:label:currentValueLabel:)")
    nonisolated public init(
        interval: ClosedRange<Date>,
        countdown: Bool = true,
        @ViewBuilder label: () -> Label,
        @ViewBuilder currentValueLabel: () -> CurrentValueLabel
    ) {
        self.init(
            timerInterval: interval,
            countsDown: countdown,
            label: label,
            currentValueLabel: currentValueLabel
        )
    }
}

@available(OpenSwiftUI_v4_0, *)
extension ProgressView where CurrentValueLabel == DefaultDateProgressLabel {
    /// Creates a progress view that displays progress over a date interval and
    /// uses the default current value label.
    nonisolated public init(
        timerInterval: ClosedRange<Date>,
        countsDown: Bool = true,
        @ViewBuilder label: () -> Label
    ) {
        base = .custom(
            CustomProgressView(
                interval: timerInterval,
                countdown: countsDown,
                label: label(),
                currentValueLabel: DefaultDateProgressLabel(
                    interval: timerInterval,
                    countdown: countsDown
                )
            )
        )
    }
}

@_spi(_)
@available(OpenSwiftUI_v4_0, *)
extension ProgressView where CurrentValueLabel == DefaultDateProgressLabel {
    @_spi(_)
    @available(*, deprecated, renamed: "init(timerInterval:countsDown:label:)")
    nonisolated public init(
        interval: ClosedRange<Date>,
        countdown: Bool = true,
        @ViewBuilder label: () -> Label
    ) {
        self.init(
            timerInterval: interval,
            countsDown: countdown,
            label: label
        )
    }
}

@available(OpenSwiftUI_v4_0, *)
extension ProgressView where Label == EmptyView, CurrentValueLabel == DefaultDateProgressLabel {
    /// Creates an unlabeled progress view that displays progress over a date
    /// interval and uses the default current value label.
    nonisolated public init(
        timerInterval: ClosedRange<Date>,
        countsDown: Bool = true
    ) {
        base = .custom(
            CustomProgressView(
                interval: timerInterval,
                countdown: countsDown,
                label: nil,
                currentValueLabel: DefaultDateProgressLabel(
                    interval: timerInterval,
                    countdown: countsDown
                )
            )
        )
    }
}

@_spi(_)
@available(OpenSwiftUI_v4_0, *)
extension ProgressView where Label == EmptyView, CurrentValueLabel == DefaultDateProgressLabel {
    @_spi(_)
    @available(*, deprecated, renamed: "init(timerInterval:countsDown:)")
    nonisolated public init(
        interval: ClosedRange<Date>,
        countdown: Bool = true
    ) {
        self.init(
            timerInterval: interval,
            countsDown: countdown
        )
    }
}

// MARK: - TimelineProgressViewExtendedBase

protocol TimelineProgressViewExtendedBase: View {
    associatedtype ExtendedState: Codable

    init(fractionCompleted: Double, tint: Color?, extendedState: ExtendedState)
}

// MARK: - TimelineProgressViewBase

protocol TimelineProgressViewBase: TimelineProgressViewExtendedBase where ExtendedState == _TimelineProgressViewBaseEmptyState {
    init(fractionCompleted: Double, tint: Color?)
}

extension TimelineProgressViewBase {
    init(fractionCompleted: Double, tint: Color?, extendedState: ExtendedState) {
        self.init(fractionCompleted: fractionCompleted, tint: tint)
    }
}

// MARK: - _TimelineProgressViewBaseEmptyState

struct _TimelineProgressViewBaseEmptyState: Codable {}

// MARK: - TimelineProgressView

struct TimelineProgressView<Base>: View where Base: TimelineProgressViewExtendedBase {
    var interval: ClosedRange<Date>
    var updateStyle: TimelineProgressViewUpdateStyle
    var countdown: Bool
    var tint: Color?
    var isCircular: Bool
    var extendedState: Base.ExtendedState

    var body: some View {
        ConditionallyArchivableTimelineProgressView(
            interval: interval,
            updateStyle: updateStyle,
            countdown: countdown,
            tint: tint,
            isCircular: isCircular,
            extendedState: extendedState
        )
    }

    struct ArchivableTimelineProgressView: _ArchivableView {
        var interval: ClosedRange<Date>
        var updateStyle: TimelineProgressViewUpdateStyle
        var countdown: Bool
        var resolvedTint: Color.Resolved?
        var extendedState: Base.ExtendedState

        var body: some View {
            FinalTimelineProgressView(
                interval: interval,
                updateStyle: updateStyle,
                countdown: countdown,
                tint: resolvedTint.map(Color.init),
                extendedState: extendedState
            )
        }
    }

    private struct ConditionallyArchivableTimelineProgressView: ConditionallyArchivableView {
        var interval: ClosedRange<Date>
        var updateStyle: TimelineProgressViewUpdateStyle
        var countdown: Bool
        var tint: Color?
        var isCircular: Bool
        var extendedState: Base.ExtendedState

        var body: some View {
            FinalTimelineProgressView(
                interval: interval,
                updateStyle: updateStyle,
                countdown: countdown,
                tint: tint,
                extendedState: extendedState
            )
        }

        var archivedBody: some View {
            EnvironmentReader { environment in
                ArchivableTimelineProgressView(
                    interval: interval,
                    updateStyle: updateStyle,
                    countdown: countdown,
                    resolvedTint: tint?.resolve(in: environment),
                    extendedState: extendedState
                )
            }
            .fixedSize(horizontal: false, vertical: !isCircular)
        }
    }

    private struct FinalTimelineProgressView: View {
        var interval: ClosedRange<Date>
        var updateStyle: TimelineProgressViewUpdateStyle
        var countdown: Bool
        var tint: Color?
        var extendedState: Base.ExtendedState

        @ViewBuilder
        var body: some View {
            TimelineView(
                ProgressViewSchedule(
                    interval: interval,
                    updateStyle: updateStyle
                )
            ) { context in
                Base(
                    fractionCompleted: interval.progress(
                        at: context.date,
                        countdown: countdown
                    ),
                    tint: tint,
                    extendedState: extendedState
                )
            }
        }
    }
}

// MARK: - TimelineProgressViewUpdateStyle

enum TimelineProgressViewUpdateStyle: Codable, Hashable {
    case `default`
    case onTheSecond
}

// MARK: - ProgressViewSchedule

@available(OpenSwiftUI_v3_0, *)
struct ProgressViewSchedule: TimelineSchedule {
    var interval: ClosedRange<Date>
    var updateStyle: TimelineProgressViewUpdateStyle

    func entries(
        from _: Date,
        mode: TimelineScheduleMode
    ) -> AnyIterator<Date> {
        let entries: AnySequence<Date>
        switch mode {
        case .normal:
            switch updateStyle {
            case .default:
                entries = AnySequence(
                    AnimationTimelineSchedule()
                        .entries(from: interval.lowerBound, mode: mode)
                )
            case .onTheSecond:
                entries = AnySequence(
                    PeriodicTimelineSchedule(from: interval.lowerBound, by: 1)
                        .entries(from: interval.lowerBound, mode: mode)
                )
            }
        case .lowFrequency:
            let calendar = Calendar.current
            let second = calendar.component(.second, from: interval.upperBound)
            let alignedStart = calendar.nextDate(
                after: interval.lowerBound,
                matching: DateComponents(second: second, nanosecond: 0),
                matchingPolicy: .nextTime,
                repeatedTimePolicy: .first,
                direction: .backward
            ) ?? interval.lowerBound
            entries = AnySequence(
                PeriodicTimelineSchedule(from: alignedStart, by: 60)
                    .entries(from: alignedStart, mode: mode)
            )
        }
        var iterator = entries.makeIterator()
        return AnyIterator {
            guard let date = iterator.next() else {
                return nil
            }
            if date > interval.upperBound, Date.now >= interval.upperBound {
                return .distantFuture
            }
            return date
        }
    }
}
