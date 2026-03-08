//
//  TimelineView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A009558074DBEAE1A969E3C6E8DD1422 (SwiftUI)

public import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

#if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES
import BacklightServices
#endif

// MARK: - TimelineView

/// A view that updates according to a schedule that you provide.
///
/// A timeline view acts as a container with no appearance of its own. Instead,
/// it redraws the content it contains at scheduled points in time.
/// For example, you can update the face of an analog timer once per second:
///
///     TimelineView(.periodic(from: startDate, by: 1)) { context in
///         AnalogTimerView(date: context.date)
///     }
///
/// The closure that creates the content receives an input of type ``Context``
/// that you can use to customize the content's appearance. The context includes
/// the ``Context/date`` that triggered the update. In the example above,
/// the timeline view sends that date to an analog timer that you create so the
/// timer view knows how to draw the hands on its face.
///
/// The context also includes a ``Context/cadence-swift.property``
/// property that you can use to hide unnecessary detail. For example, you
/// can use the cadence to decide when it's appropriate to display the
/// timer's second hand:
///
///     TimelineView(.periodic(from: startDate, by: 1.0)) { context in
///         AnalogTimerView(
///             date: context.date,
///             showSeconds: context.cadence <= .seconds)
///     }
///
/// The system might use a cadence that's slower than the schedule's
/// update rate. For example, a view on watchOS might remain visible when the
/// user lowers their wrist, but update less frequently, and thus require
/// less detail.
///
/// You can define a custom schedule by creating a type that conforms to the
/// ``TimelineSchedule`` protocol, or use one of the built-in schedule types:
/// * Use an ``TimelineSchedule/everyMinute`` schedule to update at the
///   beginning of each minute.
/// * Use a ``TimelineSchedule/periodic(from:by:)`` schedule to update
///   periodically with a custom start time and interval between updates.
/// * Use an ``TimelineSchedule/explicit(_:)`` schedule when you need a finite number, or
///   irregular set of updates.
///
/// For a schedule containing only dates in the past,
/// the timeline view shows the last date in the schedule.
/// For a schedule containing only dates in the future,
/// the timeline draws its content using the current date
/// until the first scheduled date arrives.
@available(OpenSwiftUI_v3_0, *)
public struct TimelineView<Schedule, Content> where Schedule: TimelineSchedule {

    /// Information passed to a timeline view's content callback.
    ///
    /// The context includes both the ``date`` from the schedule that triggered
    /// the callback, and a ``cadence-swift.property`` that you can use
    /// to customize the appearance of your view. For example, you might choose
    /// to display the second hand of an analog clock only when the cadence is
    /// ``Cadence-swift.enum/seconds`` or faster.
    public struct Context {

        /// A rate at which timeline views can receive updates.
        ///
        /// Use the cadence presented to content in a ``TimelineView`` to hide
        /// information that updates faster than the view's current update rate.
        /// For example, you could hide the millisecond component of a digital
        /// timer when the cadence is ``seconds`` or ``minutes``.
        ///
        /// Because this enumeration conforms to the
        /// [Comparable](https://developer.apple.com/documentation/swift/comparable)
        /// protocol, you can compare cadences with relational operators.
        /// Slower cadences have higher values, so you could perform the check
        /// described above with the following comparison:
        ///
        ///     let hideMilliseconds = cadence > .live
        ///
        public enum Cadence: Comparable, Sendable {

            /// Updates the view continuously.
            case live

            /// Updates the view approximately once per second.
            case seconds

            /// Updates the view approximately once per minute.
            case minutes
        }

        /// The date from the schedule that triggered the current view update.
        ///
        /// The first time a ``TimelineView`` closure receives this date, it
        /// might be in the past. For example, if you create an
        /// ``TimelineSchedule/everyMinute`` schedule at `10:09:55`, the
        /// schedule creates entries `10:09:00`, `10:10:00`, `10:11:00`, and so
        /// on. In response, the timeline view performs an initial update
        /// immediately, at `10:09:55`, but the context contains the `10:09:00`
        /// date entry. Subsequent entries arrive at their corresponding times.
        public let date: Date

        /// The rate at which the timeline updates the view.
        ///
        /// Use this value to hide information that updates faster than the
        /// view's current update rate. For example, you could hide the
        /// millisecond component of a digital timer when the cadence is
        /// anything slower than ``Cadence-swift.enum/live``.
        ///
        /// Because the ``Cadence-swift.enum`` enumeration conforms to the
        /// [Comparable](https://developer.apple.com/documentation/swift/comparable)
        /// protocol, you can compare cadences with relational operators.
        /// Slower cadences have higher values, so you could perform the check
        /// described above with the following comparison:
        ///
        ///     let hideMilliseconds = cadence > .live
        ///
        public let cadence: Cadence

        #if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES
        let invalidationAction: TimelineInvalidationAction
        #endif
    }

    var schedule: Schedule

    var content: (Context) -> Content
}

@available(*, unavailable)
extension TimelineView: Sendable {}

@available(*, unavailable)
extension TimelineView.Context: Sendable {}

/// Information passed to a timeline view's content callback.
///
/// The context includes both the date from the schedule that triggered
/// the callback, and a cadence that you can use to customize the appearance of
/// your view. For example, you might choose to display the second hand of an
/// analog clock only when the cadence is
/// ``TimelineView/Context/Cadence-swift.enum/seconds`` or faster.
///
/// > Note: This type alias uses a specific concrete instance of
/// ``TimelineView/Context`` that all timeline views can use.
/// It does this to prevent introducing an unnecessary generic parameter
/// dependency on the context type.
@available(OpenSwiftUI_v3_0, *)
public typealias TimelineViewDefaultContext = TimelineView<EveryMinuteTimelineSchedule, Never>.Context

// MARK: - TimelineView + View [WIP]

@available(OpenSwiftUI_v3_0, *)
extension TimelineView: View, PrimitiveView, UnaryView where Content: View {

    public typealias Body = Never

    /// Creates a new timeline view that uses the given schedule.
    ///
    /// - Parameters:
    ///   - schedule: A schedule that produces a sequence of dates that
    ///     indicate the instances when the view should update.
    ///     Use a type that conforms to ``TimelineSchedule``, like
    ///     ``TimelineSchedule/everyMinute``, or a custom timeline schedule
    ///     that you define.
    ///   - content: A closure that generates view content at the moments
    ///     indicated by the schedule. The closure takes an input of type
    ///     ``TimelineViewDefaultContext`` that includes the date from the schedule that
    ///     prompted the update, as well as a ``Context/Cadence-swift.enum``
    ///     value that the view can use to customize its appearance.
    @_alwaysEmitIntoClient
    nonisolated public init(
        _ schedule: Schedule,
        @ViewBuilder content: @escaping (TimelineViewDefaultContext) -> Content
    ) {
        self.init(schedule) { (context: Context) -> Content in
            content(unsafeBitCast(context, to: TimelineViewDefaultContext.self))
        }
    }

    /// Creates a new timeline view that uses the given schedule.
    ///
    /// - Parameters:
    ///   - schedule: A schedule that produces a sequence of dates that
    ///     indicate the instances when the view should update.
    ///     Use a type that conforms to ``TimelineSchedule``, like
    ///     ``TimelineSchedule/everyMinute``, or a custom timeline schedule
    ///     that you define.
    ///   - content: A closure that generates view content at the moments
    ///     indicated by the schedule. The closure takes an input of type
    ///     ``Context`` that includes the date from the schedule that
    ///     prompted the update, as well as a ``Context/Cadence-swift.enum``
    ///     value that the view can use to customize its appearance.
    @available(*, deprecated, message: "Use TimelineViewDefaultContext for the type of the context parameter passed into TimelineView's content closure to resolve this warning. The new version of this initializer, using TimelineViewDefaultContext, improves compilation performance by using an independent generic type signature, which helps avoid unintended cyclical type dependencies.")
    @_disfavoredOverload
    nonisolated public init(
        _ schedule: Schedule,
        @ViewBuilder content: @escaping (Context) -> Content
    ) {
        self.schedule = schedule
        self.content = content
    }

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        #if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES
        let id = TimelineIdentifier()
        let filter = UpdateFilter(
            view: view.value,
            schedule: view.value[offset: { .of(&$0.schedule) }],
            phase: inputs.viewPhase,
            time: inputs.time,
            referenceDate: inputs.referenceDate,
            id: id,
            frameSpecifier: inputs.base.alwaysOnFrameSpecifier,
            fidelity: inputs.base.updateFidelity,
            invalidationHandler: inputs.base.alwaysOnInvalidationAction,
            hadFrameSpecifier: false,
            resetSeed: .zero,
            currentTime: -.infinity,
            nextTime: .infinity,
            cadence: .live
        )
        let filterView = _GraphValue<Content>(filter)
        var outputs = Content.makeDebuggableView(view: filterView, inputs: inputs)
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: AlwaysOnTimelinesKey.self,
            transform: Attribute(
                AlwaysOnTimelinePreferenceWriter(
                    id: id,
                    schedule: view.value.unsafeBitCast(to: Schedule.self)
                )
            )
        )
        return outputs
        #else
        let filter = UpdateFilter(
            view: view.value,
            schedule: view.value[offset: { .of(&$0.schedule) }],
            phase: inputs.viewPhase,
            time: inputs.time,
            referenceDate: inputs.base.referenceDate,
            resetSeed: .zero,
            currentTime: -.infinity,
            nextTime: .infinity,
            cadence: .live
        )
        let filterView = _GraphValue<Content>(filter)
        let outputs = Content.makeDebuggableView(view: filterView, inputs: inputs)
        return outputs
        #endif
    }

    private struct UpdateFilter: StatefulRule, AsyncAttribute {
        @Attribute var view: TimelineView
        @Attribute var schedule: Schedule
        @Attribute var phase: _GraphInputs.Phase
        @Attribute var time: Time
        @WeakAttribute var referenceDate: (Date?)?
        #if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES
        var id: TimelineIdentifier
        @Attribute var frameSpecifier: BLSAlwaysOnFrameSpecifier?
        @Attribute var fidelity: BLSUpdateFidelity
        @Attribute var invalidationHandler: TimelineInvalidationAction
        var hadFrameSpecifier: Bool
        #endif
        var resetSeed: UInt32
        var iterator: Schedule.Entries.Iterator?
        var currentTime: Double
        var nextTime: Double
        var cadence: Context.Cadence

        #if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES
        init(
            view: Attribute<TimelineView>,
            schedule: Attribute<Schedule>,
            phase: Attribute<_GraphInputs.Phase>,
            time: Attribute<Time>,
            referenceDate: WeakAttribute<Date?>,
            id: TimelineIdentifier,
            frameSpecifier: Attribute<BLSAlwaysOnFrameSpecifier?>,
            fidelity: Attribute<BLSUpdateFidelity>,
            invalidationHandler: Attribute<TimelineInvalidationAction>,
            hadFrameSpecifier: Bool,
            resetSeed: UInt32,
            iterator: Schedule.Entries.Iterator? = nil,
            currentTime: Double,
            nextTime: Double,
            cadence: Context.Cadence
        ) {
            self._view = view
            self._schedule = schedule
            self._phase = phase
            self._time = time
            self._referenceDate = referenceDate
            self.id = id
            self._frameSpecifier = frameSpecifier
            self._fidelity = fidelity
            self._invalidationHandler = invalidationHandler
            self.hadFrameSpecifier = hadFrameSpecifier
            self.resetSeed = resetSeed
            self.iterator = iterator
            self.currentTime = currentTime
            self.nextTime = nextTime
            self.cadence = cadence
        }
        #else
        init(
            view: Attribute<TimelineView>,
            schedule: Attribute<Schedule>,
            phase: Attribute<_GraphInputs.Phase>,
            time: Attribute<Time>,
            referenceDate: WeakAttribute<Date?>,
            resetSeed: UInt32,
            iterator: Schedule.Entries.Iterator? = nil,
            currentTime: Double,
            nextTime: Double,
            cadence: Context.Cadence
        ) {
            self._view = view
            self._schedule = schedule
            self._phase = phase
            self._time = time
            self._referenceDate = referenceDate
            self.resetSeed = resetSeed
            self.iterator = iterator
            self.currentTime = currentTime
            self.nextTime = nextTime
            self.cadence = cadence
        }
        #endif

        typealias Value = Content

        mutating func updateValue() {
            let previousCurrentTime = currentTime
            if phase.resetSeed != resetSeed {
                resetSeed = phase.resetSeed
                iterator = nil
                currentTime = -.infinity
                nextTime = .infinity
                #if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES
                hadFrameSpecifier = false
                #endif
            }
            var (_, scheduleChanged) = $schedule.changedValue()
            let (_, viewChanged) = $view.changedValue()
            var changed = viewChanged
            let (referenceDate, referenceDateChanged) = $referenceDate?.changedValue() ?? (nil, false)
            #if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES
            let (frameSpecifier, frameSpecifierChanged) = $frameSpecifier.changedValue()
            let (fidelity, fidelityChanged) = $fidelity.changedValue()
            if frameSpecifierChanged || !hasValue {
                if (frameSpecifier != nil) != hadFrameSpecifier {
                    iterator = nil
                    hadFrameSpecifier = frameSpecifier != nil
                }
            }
            if fidelityChanged {
                changed = true
                scheduleChanged = true
            }
            #endif
            let refDate = referenceDate ?? Date()
            let currentReferenceTime = refDate.timeIntervalSinceReferenceDate
            if scheduleChanged || iterator == nil || referenceDateChanged {
                #if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES
                var mode = TimelineScheduleMode.normal
                if frameSpecifier != nil {
                    mode = .lowFrequency
                }
                #else
                let mode = TimelineScheduleMode.normal
                #endif
                nextTime = .infinity
                if referenceDate == nil {
                    let schedule = view.schedule
                    let entries = schedule.entries(from: refDate, mode: mode)
                    iterator = entries.makeIterator()
                    if let next = iterator?.next() {
                        currentTime = next.timeIntervalSinceReferenceDate
                        if let next = iterator?.next() {
                            nextTime = next.timeIntervalSinceReferenceDate
                        }
                    }
                } else {
                    currentTime = currentReferenceTime
                }
            }
            #if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES
            if let frameSpecifier {
                if updateFromBacklightServices(frameSpecifier: frameSpecifier) {
                    scheduleChanged = true
                }
            } else {
                while nextTime <= currentReferenceTime, let next = iterator?.next() {
                    currentTime = nextTime
                    nextTime = next.timeIntervalSinceReferenceDate
                }
            }
            #else
            while nextTime <= currentReferenceTime, let next = iterator?.next() {
                currentTime = nextTime
                nextTime = next.timeIntervalSinceReferenceDate
            }
            #endif
            if !currentTime.isFinite {
                currentTime = currentReferenceTime
            }
            if currentTime != previousCurrentTime || changed || AnyAttribute.currentWasModified || !hasValue {
                let date = Date(timeIntervalSinceReferenceDate: currentTime)
                #if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES
                let cadence: TimelineView<PeriodicTimelineSchedule, Never>.Context.Cadence = switch fidelity {
                case .unspecified, .never, .minutes: .minutes
                case .seconds: .seconds
                case .milliseconds: .live
                @unknown default: .minutes
                }
                let context: TimelineView<PeriodicTimelineSchedule, Never>.Context = .init(
                    date: date,
                    cadence: cadence,
                    invalidationAction: invalidationHandler
                )
                #else
                let context: TimelineView<PeriodicTimelineSchedule, Never>.Context = .init(
                    date: date,
                    cadence: .live
                )
                #endif
                value = withObservation {
                    $view.syncMainIfReferences { timelineView in
                        timelineView.content(unsafeBitCast(context, to: Context.self))
                    }
                }
            }
            if nextTime != .infinity {
                let interval = nextTime - currentReferenceTime
                let viewGraph = ViewGraph.current
                let nextUpdateTime = interval + time
                viewGraph.nextUpdate.views.at(nextUpdateTime)
            }
        }

        #if (os(iOS) || os(visionOS)) && OPENSWIFTUI_LINK_BACKLIGHTSERVICES
        mutating func updateFromBacklightServices(frameSpecifier: BLSAlwaysOnFrameSpecifier) -> Bool {
            let entrySpecifier = frameSpecifier.entrySpecifier(forTimelineIdentifier: id)
            if let entrySpecifier {
                let presentationTime = entrySpecifier.timelineEntry.presentationTime
                currentTime = presentationTime.timeIntervalSinceReferenceDate
                nextTime = .infinity
            }
            return entrySpecifier != nil
        }
        #endif
    }
}

extension TimelineView where Content: View {
    @available(OpenSwiftUI_v4_4, *)
    @usableFromInline
    @_disfavoredOverload
    init(
        _ schedule: Schedule,
        @ViewBuilder content: @escaping (TimelineView<PeriodicTimelineSchedule, Never>.Context) -> Content
    ) {
        self.init(schedule) { (context: Context) -> Content in
            content(unsafeBitCast(context, to: TimelineView<PeriodicTimelineSchedule, Never>.Context.self))
        }
    }
}
