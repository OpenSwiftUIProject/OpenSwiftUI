//
//  AppKitFeedbackImplementation.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS)
import AppKit
import OpenSwiftUICore

// MARK: - View + platformSensoryFeedback

extension View {
    nonisolated func platformSensoryFeedback<Base>(
        _ base: Base
    ) -> some View where Base: SensoryFeedbackGeneratorModifier {
        modifier(base)
    }
}

// MARK: - HapticFeedbackManagerImplementation

struct HapticFeedbackManagerImplementation: PlatformSensoryFeedback {
    var pattern: NSHapticFeedbackManager.FeedbackPattern

    func setUp() {
        _openSwiftUIEmptyStub()
    }

    func tearDown() {
        _openSwiftUIEmptyStub()
    }

    func generate() {
        NSHapticFeedbackManager.defaultPerformer.perform(
            pattern,
            performanceTime: .default
        )
    }
}

// MARK: - FeedbackRequestContext

struct FeedbackRequestContext {
    func implementation(type: SensoryFeedback.FeedbackType) -> (any PlatformSensoryFeedback)? {
        switch type {
        case .alignment: HapticFeedbackManagerImplementation(pattern: .alignment)
        case .levelChange: HapticFeedbackManagerImplementation(pattern: .levelChange)
        default: nil
        }
    }
}
#endif
