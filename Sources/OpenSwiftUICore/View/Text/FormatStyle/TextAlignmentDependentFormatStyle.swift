//
//  TextAlignmentDependentFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete (Blocked by SystemFormatStyle)

import Foundation

protocol TextAlignmentDependentFormatStyle: FormatStyle {
    func textAlignment(_ alignment: TextAlignment) -> Self
}

// TODO: Add conformance when these concrete format styles land:
// SystemFormatStyle.Timer
// SystemFormatStyle.Stopwatch
