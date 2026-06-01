//
//  UpdateFrequencyDependentFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete (Blocked by WhitespaceRemovingFormatStyle/SystemFormatStyle)

import Foundation

protocol UpdateFrequencyDependentFormatStyle: FormatStyle {
    func updateFrequency(_ frequency: TimeDataFormatting.UpdateFrequency) -> Self
}

#if canImport(Darwin)
//@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
//extension Date.FormatStyle: UpdateFrequencyDependentFormatStyle {
//    func updateFrequency(_ frequency: TimeDataFormatting.UpdateFrequency) -> Self {
//        switch frequency {
//        case .high:
//            self
//        case .second:
//            secondFraction(.omitted)
//        case .minute:
//            second(.omitted).secondFraction(.omitted)
//        }
//    }
//}
//
//@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
//extension Date.FormatStyle.Attributed: UpdateFrequencyDependentFormatStyle {
//    func updateFrequency(_ frequency: TimeDataFormatting.UpdateFrequency) -> Self {
//        switch frequency {
//        case .high:
//            self
//        case .second:
//            secondFraction(.omitted)
//        case .minute:
//            second(.omitted).secondFraction(.omitted)
//        }
//    }
//}
//
//@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
//extension Date.AnchoredRelativeFormatStyle: UpdateFrequencyDependentFormatStyle {
//    func updateFrequency(_ frequency: TimeDataFormatting.UpdateFrequency) -> Self {
//        guard frequency != .high else {
//            return self
//        }
//
//        let minimumField: Date.ComponentsFormatStyle.Field = frequency == .second ? .second : .minute
//        var style = self
//        style.allowedFields = Set(style.allowedFields.filter { field in
//            field.updateFrequencyOrder >= minimumField.updateFrequencyOrder
//        })
//        if style.allowedFields.isEmpty {
//            style.allowedFields.insert(minimumField)
//        }
//        return style
//    }
//}
//
//@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
//extension Duration.UnitsFormatStyle: UpdateFrequencyDependentFormatStyle {
//    func updateFrequency(_ frequency: TimeDataFormatting.UpdateFrequency) -> Self {
//        guard frequency != .high else {
//            return self
//        }
//
//        let minimumUnit: Duration.UnitsFormatStyle.Unit = frequency == .second ? .seconds : .minutes
//        var style = self
//        style.allowedUnits = Set(style.allowedUnits.filter { unit in
//            unit.updateFrequencyOrder >= minimumUnit.updateFrequencyOrder
//        })
//        if style.allowedUnits.isEmpty {
//            style.allowedUnits.insert(minimumUnit)
//        }
//
//        if let smallestUnit = style.allowedUnits.min(by: { lhs, rhs in
//            lhs.updateFrequencyOrder < rhs.updateFrequencyOrder
//        }) {
//            let increment = frequency.interval / smallestUnit.seconds
//            if increment.isFinite, increment > 0.0 {
//                let existingIncrement = style.fractionalPartDisplay.roundingIncrement
//                style.fractionalPartDisplay.roundingIncrement = existingIncrement.map {
//                    min($0, increment)
//                } ?? increment
//            }
//        }
//        return style
//    }
//}
//
//@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
//private extension Date.ComponentsFormatStyle.Field {
//    var updateFrequencyOrder: Int {
//        if self == .second {
//            0
//        } else if self == .minute {
//            1
//        } else if self == .hour {
//            2
//        } else if self == .day {
//            3
//        } else if self == .week {
//            4
//        } else if self == .month {
//            5
//        } else if self == .year {
//            6
//        } else {
//            0
//        }
//    }
//}
//
//@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
//private extension Duration.UnitsFormatStyle.Unit {
//    var updateFrequencyOrder: Int {
//        if self == .nanoseconds {
//            0
//        } else if self == .microseconds {
//            1
//        } else if self == .milliseconds {
//            2
//        } else if self == .seconds {
//            3
//        } else if self == .minutes {
//            4
//        } else if self == .hours {
//            5
//        } else if self == .days {
//            6
//        } else if self == .weeks {
//            7
//        } else {
//            0
//        }
//    }
//
//    var seconds: Double {
//        if self == .nanoseconds {
//            0.000000001
//        } else if self == .microseconds {
//            0.000001
//        } else if self == .milliseconds {
//            0.001
//        } else if self == .seconds {
//            1.0
//        } else if self == .minutes {
//            60.0
//        } else if self == .hours {
//            3600.0
//        } else if self == .days {
//            86400.0
//        } else if self == .weeks {
//            604800.0
//        } else {
//            0.0
//        }
//    }
//}

// TODO: Add conformance when these concrete format styles land:
// WhitespaceRemovingFormatStyle where A: UpdateFrequencyDependentFormatStyle
// SystemFormatStyle.DateReference
// SystemFormatStyle.Timer
// SystemFormatStyle.Stopwatch
#endif
