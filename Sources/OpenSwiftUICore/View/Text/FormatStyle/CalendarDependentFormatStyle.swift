//
//  CalendarDependentFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete (Blocked by WhitespaceRemovingFormatStyle/SystemFormatStyle)
//  ID: 26D279F2E8972E56094553A13FA39915 (SwiftUICore)

package import Foundation

protocol CalendarDependentFormatStyle: FormatStyle {
    func withCalendar(_ calendar: Calendar) -> Self
}

extension FormatStyle {
    package func calendar(_ calendar: Calendar) -> Self {
        guard let style = self as? any CalendarDependentFormatStyle else {
            return self
        }
        return style.withCalendar(calendar) as! Self
    }
}

#if canImport(Darwin)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.FormatStyle: CalendarDependentFormatStyle {
    func withCalendar(_ calendar: Calendar) -> Self {
        var style = self
        style.calendar = calendar
        return style
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.VerbatimFormatStyle: CalendarDependentFormatStyle {
    func withCalendar(_ calendar: Calendar) -> Self {
        var style = self
        style.calendar = calendar
        return style
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.ComponentsFormatStyle: CalendarDependentFormatStyle {
    func withCalendar(_ calendar: Calendar) -> Self {
        self.calendar(calendar)
    }
}

@available(macOS 15, iOS 18, tvOS 18, watchOS 11, *)
extension Date.FormatStyle.Attributed: CalendarDependentFormatStyle {
    func withCalendar(_ calendar: Calendar) -> Self {
        var style = self
        style[dynamicMember: \.calendar] = calendar
        return style
    }
}

@available(macOS 15, iOS 18, tvOS 18, watchOS 11, *)
extension Date.VerbatimFormatStyle.Attributed: CalendarDependentFormatStyle {
    func withCalendar(_ calendar: Calendar) -> Self {
        var style = self
        style[dynamicMember: \.calendar] = calendar
        return style
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.AnchoredRelativeFormatStyle: CalendarDependentFormatStyle {
    func withCalendar(_ calendar: Calendar) -> Self {
        var style = self
        style.calendar = calendar
        return style
    }
}

// TODO: Add conformance when these concrete format styles land:
// WhitespaceRemovingFormatStyle where A: CalendarDependentFormatStyle
// SystemFormatStyle.DateReference
#endif
