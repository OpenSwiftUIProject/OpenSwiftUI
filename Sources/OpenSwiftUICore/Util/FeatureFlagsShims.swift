//
//  FeatureFlagsShims.swift
//  OpenSwiftUICore
//
//  Status: Complete

#if OPENSWIFTUI_LINK_FEATUREFLAGS
package import FeatureFlags
#endif

#if OPENSWIFTUI_LINK_FEATUREFLAGS
/// Identifies a feature flag by its domain and feature name.
package protocol FeatureFlagsKey: FeatureFlags.FeatureFlagsKey {}
#else
/// Identifies a feature flag by its domain and feature name.
package protocol FeatureFlagsKey {
    /// The domain that owns the feature, such as `"OpenSwiftUI"`.
    var domain: StaticString { get }

    /// The feature name within the domain.
    var feature: StaticString { get }
}
#endif

/// Returns whether the feature identified by a key is enabled.
///
/// When `OPENSWIFTUI_LINK_FEATUREFLAGS` is enabled, queries the key's domain
/// in the system FeatureFlags framework. If an `"OpenSwiftUI"` lookup returns
/// `false`, also checks the same feature in `"SwiftUI"`. A `true` result in
/// either domain enables the feature. An OpenSwiftUI flag cannot disable a
/// feature enabled by SwiftUI.
///
/// The SwiftUI feature flag configuration is stored at
/// `/System/Library/FeatureFlags/Domain/SwiftUI.plist`.
///
/// Returns `false` when `OPENSWIFTUI_LINK_FEATUREFLAGS` is disabled.
package func isFeatureEnabled(_ key: any FeatureFlagsKey) -> Bool {
    #if OPENSWIFTUI_LINK_FEATUREFLAGS
    /// Reuses an OpenSwiftUI feature name in the SwiftUI domain.
    struct SwiftUICompatibilityKey: FeatureFlagsKey {
        /// Creates a compatibility key only for the `"OpenSwiftUI"` domain.
        init?<Key>(_ key: Key) where Key: FeatureFlagsKey {
            guard key.domain.description == "OpenSwiftUI" else { return nil }
            self.feature = key.feature
        }

        var domain: StaticString { "SwiftUI" }
        let feature: StaticString
    }

    if let compatibilityKey = SwiftUICompatibilityKey(key) {
        return FeatureFlags.isFeatureEnabled(key) || FeatureFlags.isFeatureEnabled(compatibilityKey)
    } else {
        return FeatureFlags.isFeatureEnabled(key)
    }
    #else
    // TODO: Provide a platform implementation when FeatureFlags framework is not avaiable
    _openSwiftUIPlatformUnimplementedWarning()
    return false
    #endif
}
