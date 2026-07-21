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
