//
//  UnifiedHitTestingFeature.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Partial

// MARK: - UnifiedHitTestingFeature

package struct UnifiedHitTestingFeature: Feature {
    package init() {
        _openSwiftUIEmptyStub()
    }

    package static var isEnabled: Bool {
        Semantics.UnifiedHitTesting.isEnabled || GestureContainerFeature.isEnabled
    }
}

// TODO

// MARK: GestureContainerFeature [TODO]

struct GestureContainerFeature {
    static var isEnabled: Bool {
        false
    }
}
