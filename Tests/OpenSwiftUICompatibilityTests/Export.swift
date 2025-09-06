//
//  Export.swift
//  OpenSwiftUICompatibilityTests

#if OPENSWIFTUI
@_exported import OpenObservation
@_exported import OpenSwiftUI
let compatibilityTestEnabled = false
#else
@_exported import Observation
@_exported import SwiftUI
let compatibilityTestEnabled = true
#endif
