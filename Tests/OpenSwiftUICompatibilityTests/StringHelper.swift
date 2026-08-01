//
//  StringHelper.swift
//  OpenSwiftUICompatibilityTests

import Foundation

extension String {
    package var normalizeSwiftUI: String {
        #if OPENSWIFTUI
        self
        #else
        replacingOccurrences(of: "OpenSwiftUI", with: "SwiftUI")
        #endif
    }
}
