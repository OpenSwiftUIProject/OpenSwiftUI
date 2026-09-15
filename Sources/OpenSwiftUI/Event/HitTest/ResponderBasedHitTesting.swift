//
//  ResponderBasedHitTesting.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 4D506C1C4C6075F3B74E3FAB14E5B59E (SwiftUI?)

#if os(macOS)
import Foundation
import OpenSwiftUICore

struct ResponderBasedHitTesting: Feature {
    static var isEnabled: Bool {
        userDefaultsValue ?? bundleValue ?? featureFlagValue
    }

    private static let userDefaultsValue: Bool? = {
        let key = "org.OpenSwiftUIProject.OpenSwiftUI.ResponderBasedHitTesting"
        guard UserDefaults.standard.object(forKey: key) != nil else {
            return nil
        }
        return UserDefaults.standard.bool(forKey: key)
    }()

    private static let bundleValue: Bool? = {
        Bundle.main.bundleIdentifier == "com.apple.ScreenContinuity" ? false : nil
    }()

    fileprivate struct Key: FeatureFlagsKey {
        let domain: StaticString = "OpenSwiftUI"
        let feature: StaticString = "ResponderBasedHitTesting"
    }
    private static let featureFlagValue: Bool = {
        isFeatureEnabled(Key())
    }()
}
#endif
