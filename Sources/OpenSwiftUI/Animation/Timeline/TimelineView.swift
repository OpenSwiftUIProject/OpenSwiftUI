//
//  TimelineView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: A009558074DBEAE1A969E3C6E8DD1422 (SwiftUI)

public import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

@available(OpenSwiftUI_v3_0, *)
public struct TimelineView<Schedule, Content> where Schedule: TimelineSchedule {
    public struct Context {
        public enum Cadence: Comparable, Sendable {
            case live
            case seconds
            case minutes
        }

        public let date: Date
        public let cadence: Cadence
        // TODO: let invalidationAction: TimelineInvalidationAction
    }

    var schedule: Schedule

    var content: (Context) -> Content
}

@available(*, unavailable)
extension TimelineView: Sendable {}

@available(*, unavailable)
extension TimelineView.Context: Sendable {}

@available(OpenSwiftUI_v3_0, *)
public typealias TimelineViewDefaultContext = TimelineView<EveryMinuteTimelineSchedule, Never>.Context

@available(OpenSwiftUI_v3_0, *)
extension TimelineView: View, PrimitiveView, UnaryView where Content: View {
    public typealias Body = Never

    @_alwaysEmitIntoClient
    nonisolated public init(
        _ schedule: Schedule,
        @ViewBuilder content: @escaping (TimelineViewDefaultContext) -> Content
    ) {
        self.init(schedule) { (context: Context) -> Content in
            content(unsafeBitCast(context, to: TimelineViewDefaultContext.self))
        }
    }

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
        view: _GraphValue<TimelineView<Schedule, Content>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }

    private struct UpdateFilter: StatefulRule, AsyncAttribute {
        @Attribute var view: TimelineView
        @Attribute var schedule: Schedule
        @Attribute var phase: _GraphInputs.Phase
        @Attribute var time: Time
        @WeakAttribute var referenceDate: (Date?)?
//        var id: TimelineIdentifier
//        @Attribute var frameSpecifier: BLSAlwaysOnFrameSpecifier?
//        @Attribute var fidelity: BLSUpdateFidelity
//        @Attribute var invalidationHandler: TimelineInvalidationAction
        var hadFrameSpecifier: Bool
        var resetSeed: UInt32
        var iterator: Schedule.Entries.Iterator?
        var currentTime: Double
        var nextTime: Double
        var cadence: Context.Cadence

        init(
            view: Attribute<TimelineView>,
            schedule: Attribute<Schedule>,
            phase: Attribute<_GraphInputs.Phase>,
            time: Attribute<Time>,
            referenceDate: WeakAttribute<Date?>,
//            id: TimelineIdentifier,
//            frameSpecifier: Attribute<BLSAlwaysOnFrameSpecifier?>,
//            fidelity: Attribute<BLSUpdateFidelity>,
//            invalidationHandler: Attribute<TimelineInvalidationAction>,
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
//            self.id = id
//            self._frameSpecifier = frameSpecifier
//            self._fidelity = fidelity
//            self._invalidationHandler = invalidationHandler
            self.hadFrameSpecifier = hadFrameSpecifier
            self.resetSeed = resetSeed
            self.iterator = iterator
            self.currentTime = currentTime
            self.nextTime = nextTime
            self.cadence = cadence
        }

        typealias Value = Content

        func updateValue() {
            // TODO
        }
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
