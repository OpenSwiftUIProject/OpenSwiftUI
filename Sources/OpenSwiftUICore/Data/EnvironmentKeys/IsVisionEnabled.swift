//
//  IsVisionEnabled.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

extension EnvironmentValues {
    package var isVisionEnabled: Bool {
        get {
            #if os(macOS)
            false
            #else
            self[IsVisionEnabledKey.self]
            #endif
        }
        set { self[IsVisionEnabledKey.self] = newValue }
    }
}

package struct IsVisionEnabledKey: EnvironmentKey {
    package static let defaultValue: Bool = false
    
    package typealias Value = Bool
}
