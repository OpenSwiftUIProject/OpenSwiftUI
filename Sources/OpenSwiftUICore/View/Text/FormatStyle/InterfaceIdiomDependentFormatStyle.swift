//
//  InterfaceIdiomDependentFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP (Blocked by SystemFormatStyle)

import Foundation

protocol InterfaceIdiomDependentFormatStyle: FormatStyle {
    func interfaceIdiom(_ idiom: AnyInterfaceIdiom) -> Self
}

// TODO: Add conformance when these concrete format styles land:
// SystemFormatStyle.Timer
// SystemFormatStyle.Stopwatch
