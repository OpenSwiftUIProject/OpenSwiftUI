//
//  TimeZoneDependentFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete (Blocked by WhitespaceRemovingFormatStyle/SystemFormatStyle)
//  ID: CB8B6A6747C7DA30909815F805FD2B45 (SwiftUICore)

public import Foundation

private protocol TimeZoneDependentFormatStyle: FormatStyle {
    func withTimeZone(_ timeZone: TimeZone) -> Self
}

extension FormatStyle {
    package func timeZone(_ timeZone: TimeZone) -> Self {
        guard let style = self as? any TimeZoneDependentFormatStyle else {
            return self
        }
        return style.withTimeZone(timeZone) as! Self
    }
}

#if canImport(Darwin)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.FormatStyle: TimeZoneDependentFormatStyle {
    func withTimeZone(_ timeZone: TimeZone) -> Self {
        var style = self
        style.timeZone = timeZone
        return style
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.VerbatimFormatStyle: TimeZoneDependentFormatStyle {
    func withTimeZone(_ timeZone: TimeZone) -> Self {
        var style = self
        style.timeZone = timeZone
        return style
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.ISO8601FormatStyle: TimeZoneDependentFormatStyle {
    func withTimeZone(_ timeZone: TimeZone) -> Self {
        var style = self
        style.timeZone = timeZone
        return style
    }
}

@available(macOS 15, iOS 18, tvOS 18, watchOS 11, *)
extension Date.FormatStyle.Attributed: TimeZoneDependentFormatStyle {
    func withTimeZone(_ timeZone: TimeZone) -> Self {
        var style = self
        style[dynamicMember: \.timeZone] = timeZone
        return style
    }
}

// extension WhitespaceRemovingFormatStyle: TimeZoneDependentFormatStyle where A: TimeZoneDependentFormatStyle {}

@available(macOS 15, iOS 18, tvOS 18, watchOS 11, *)
extension Date.VerbatimFormatStyle.Attributed: TimeZoneDependentFormatStyle {
    func withTimeZone(_ timeZone: TimeZone) -> Self {
        var style = self
        style[dynamicMember: \.timeZone] = timeZone
        return style
    }
}

// extension SystemFormatStyle.DateReference: TimeZoneDependentFormatStyle {}

#endif
