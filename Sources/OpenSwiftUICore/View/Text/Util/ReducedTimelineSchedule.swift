//
//  ReducedTimelineSchedule.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - ReducedTimelineSchedule

struct ReducedTimelineSchedule<T1, T2> where T1: TimelineSchedule, T2: TimelineSchedule {
    let t1: T1
    let t2: T2

    func entries(
        from startDate: Date,
        mode: TimelineScheduleMode
    ) -> ReducedSequence<T1.Entries, T2.Entries> {
        t1.entries(from: startDate, mode: mode).reduced(
            with: t2.entries(from: startDate, mode: mode)
        )
    }
}

extension ReducedTimelineSchedule: TimelineSchedule {}

extension ReducedTimelineSchedule: Equatable where T1: Equatable, T2: Equatable {}

extension TimelineSchedule {
    func reduced<S>(with schedule: S) -> ReducedTimelineSchedule<Self, S> where S: TimelineSchedule {
        ReducedTimelineSchedule(t1: self, t2: schedule)
    }
}

// MARK: - ReducedSequence

struct ReducedSequence<S1, S2>: Sequence where S1: Sequence, S2: Sequence, S1.Element: Comparable, S1.Element == S2.Element {
    struct Iterator: IteratorProtocol {
        var s1: S1.Iterator
        var s2: S2.Iterator

        init(s1: S1.Iterator, s2: S2.Iterator) {
            self.s1 = s1
            self.s2 = s2
        }

        mutating func next() -> S1.Element? {
            var s1 = self.s1
            var s2 = self.s2
            switch (s1.next(), s2.next()) {
            case let (element1?, element2?):
                if element2 < element1 {
                    self.s2 = s2
                    return element2
                }
                self.s1 = s1
                if element1 == element2 {
                    self.s2 = s2
                }
                return element1
            case let (element1?, nil):
                self.s1 = s1
                return element1
            case let (nil, element2?):
                self.s2 = s2
                return element2
            case (nil, nil):
                return nil
            }
        }
    }

    let s1: S1
    let s2: S2

    func makeIterator() -> Iterator {
        Iterator(s1: s1.makeIterator(), s2: s2.makeIterator())
    }
}

extension Sequence where Element: Comparable {
    func reduced<S>(with sequence: S) -> ReducedSequence<Self, S> where S: Sequence, Element == S.Element {
        ReducedSequence(s1: self, s2: sequence)
    }
}

// MARK: - ResolvableStringAttribute + Schedule

extension ResolvableStringAttribute {
    func reduceSchedule<S>(with schedule: S) -> any TimelineSchedule where S: TimelineSchedule {
        guard let ownSchedule = self.schedule else {
            return schedule
        }
        return schedule.reduced(with: ownSchedule)
    }
}

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
        enumerateAttribute(.resolvableTextSegment, in: range) { value, range, _ in
            guard let value = value as? ResolvableTextSegmentAttribute.Value,
                  let resolvable = attribute(
                      value.resolvableAttributeKey,
                      at: range.location,
                      effectiveRange: nil
                  ) as? any ResolvableStringAttribute else {
                return
            }
            if let currentSchedule = schedule {
                schedule = resolvable.reduceSchedule(with: currentSchedule)
            } else {
                schedule = resolvable.schedule
            }
        }
        if let schedule {
            addAttribute(.updateSchedule, value: schedule, range: range)
        } else {
            removeAttribute(.updateSchedule, range: range)
        }
        return schedule
    }
}
