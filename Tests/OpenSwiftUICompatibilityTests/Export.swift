//
//  Export.swift
//  OpenSwiftUICompatibilityTests


#if OPENSWIFTUI_COMPATIBILITY_TEST
@_exported import SwiftUI
let compatibilityTestEnabled = true
#else
@_exported import OpenSwiftUI
let compatibilityTestEnabled = false
#endif
