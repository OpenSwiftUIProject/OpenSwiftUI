//
//  GestureFeature.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if canImport(FeatureFlags)
import FeatureFlags
#endif

// MARK: - UnifiedHitTestingFeature

package struct UnifiedHitTestingFeature: Feature {
    package init() {
        _openSwiftUIEmptyStub()
    }

    package static var isEnabled: Bool {
        Semantics.UnifiedHitTesting.isEnabled || GestureContainerFeature.isEnabled
    }
}

// MARK: - ImprovedButtonGestureFeature

package struct ImprovedButtonGestureFeature: Feature {
    package init() {
        _openSwiftUIEmptyStub()
    }

    package static var isEnabled: Bool {
        CoreTesting.isRunning || GestureContainerFeature.isEnabled
    }
}

// MARK: - EndedGestureWaitsForActiveFeature

package struct EndedGestureWaitsForActiveFeature: Feature {
    package init() {
        _openSwiftUIEmptyStub()
    }

    package static var isEnabled: Bool {
        CoreTesting.isRunning || GestureContainerFeature.isEnabled
    }
}

// MARK: - GestureContainerFeature

package struct GestureContainerFeature: Feature {
    package init() {
        _openSwiftUIEmptyStub()
    }

    package static var isEnabled: Bool {
        if CoreTesting.isRunning {
            return isEnabledOverride ?? false
        } else if let value = EnvironmentHelper.int32(for: "OPENSWIFTUI_GESTURE_CONTAINER") {
            return value != 0
        } else {
            return _isFeatureEnabled()
        }
    }

    package static var isEnabledOverride: Bool?

    package static func _isFeatureEnabled() -> Bool {
        #if canImport(FeatureFlags)
        FeatureFlags.isFeatureEnabled(Self()) && Semantics.UnifiedHitTesting.isEnabled
        #else
        Semantics.UnifiedHitTesting.isEnabled
        #endif
    }
}

#if canImport(FeatureFlags)
extension GestureContainerFeature: FeatureFlagsKey {
    package var domain: StaticString {
        "OpenSwiftUI"
    }

    package var feature: StaticString {
        "gestureContainer"
    }
}
#endif

// MARK: - GestureRecognizerBasedEvents

package struct GestureRecognizerBasedEvents: Feature {
    package static var isEnabledForTesting: Bool = false

    package static var isEnabled: Bool {
        true
    }

    package init() {
        _openSwiftUIEmptyStub()
    }
}
