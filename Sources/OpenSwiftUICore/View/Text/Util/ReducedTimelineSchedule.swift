//
//  ReducedTimelineSchedule.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package import Foundation

// TODO: ReducedTimelineSchedule

// MARK: - NSAttributedString + Extension

extension NSAttributedString {
    package var isDynamic: Bool {
        guard length >= 1 else { return false }
        let value = attribute(
            .updateSchedule,
            at: 0,
            effectiveRange: nil
        )
        return value != nil
    }

    var updateSchedule: any TimelineSchedule {
        guard length >= 1,
              let schedule = attribute(
                  .updateSchedule,
                  at: 0,
                  effectiveRange: nil
              ) as? any TimelineSchedule
        else {
            return ExplicitTimelineSchedule([])
        }
        return schedule
    }
}

extension NSMutableAttributedString {

    /// Returns the schedule on which the receiver needs to be resolved again.
    ///
    /// When `recalculate` is false the cached ``NSAttributedString/Key/updateSchedule``
    /// attribute is read back; otherwise the schedule is recomputed from the
    /// resolvable text segments and the cached attribute is refreshed.
    package func resolveUpdateSchedule(recalculate: Bool) -> (any TimelineSchedule)? {
        guard length >= 1 else {
            return nil
        }
        guard recalculate else {
            return attribute(.updateSchedule, at: 0, effectiveRange: nil) as? any TimelineSchedule
        }
        var schedule: (any TimelineSchedule)?
        enumerateAttribute(.resolvableTextSegment, in: range) { value, _, _ in
            guard value != nil else {
                return
            }
            // TODO: ResolvableTextSegmentAttribute
            _openSwiftUIUnimplementedWarning()
            schedule = nil
        }
        if let schedule {
            addAttribute(.updateSchedule, value: schedule, range: range)
        } else {
            removeAttribute(.updateSchedule, range: range)
        }
        return schedule
    }
}
