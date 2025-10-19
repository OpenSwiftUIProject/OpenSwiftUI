//
//  UserDefaultsAdditions.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

extension UserDefaults {
    package static let uiKit = UserDefaults(suiteName: "com.apple.UIKIt")

    package static let openSwiftUI = UserDefaults(suiteName: "org.OpenSwiftUIProject.OpenSwiftUI")
}
