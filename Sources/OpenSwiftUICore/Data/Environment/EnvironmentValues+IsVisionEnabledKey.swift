//
//  EnvironmentValues+IsVisionEnabledKey.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

extension EnvironmentValues {
    package var isVisionEnabled: Bool {
        get { false }
        set { self[IsVisionEnabledKey.self] = newValue }
    }
}

package struct IsVisionEnabledKey: EnvironmentKey {
    package static let defaultValue: Bool = false
    
    package typealias Value = Bool
}
