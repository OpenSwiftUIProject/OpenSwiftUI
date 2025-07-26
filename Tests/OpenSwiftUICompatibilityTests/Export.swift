//
//  Export.swift
//  OpenSwiftUICompatibilityTests

#if OPENSWIFTUI
@_exported import OpenSwiftUI
let compatibilityTestEnabled = false
#else
@_exported import SwiftUI
let compatibilityTestEnabled = true
#endif
