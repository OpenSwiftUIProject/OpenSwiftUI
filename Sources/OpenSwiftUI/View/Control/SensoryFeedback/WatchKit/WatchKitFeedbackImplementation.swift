//
//  WatchKitFeedbackImplementation.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(watchOS)
import WatchKit
import OpenSwiftUICore

// MARK: - View + platformSensoryFeedback

extension View {
    nonisolated func platformSensoryFeedback<Base>(
        _ base: Base
    ) -> some View where Base: SensoryFeedbackGeneratorModifier {
        modifier(base)
    }
}

// MARK: - WatchKitFeedbackImplementation

struct WatchKitFeedbackImplementation: PlatformSensoryFeedback {
    var haptic: WKHapticType

    func setUp() {
        _openSwiftUIEmptyStub()
    }

    func tearDown() {
        _openSwiftUIEmptyStub()
    }

    func generate() {
        WKInterfaceDevice.current().play(haptic)
    }
}

// MARK: - FeedbackRequestContext

struct FeedbackRequestContext {
    func implementation(type: SensoryFeedback.FeedbackType) -> (any PlatformSensoryFeedback)? {
        switch type {
        case .success: WatchKitFeedbackImplementation(haptic: .success)
        case .warning: WatchKitFeedbackImplementation(haptic: .retry)
        case .error: WatchKitFeedbackImplementation(haptic: .failure)
        case .increase: WatchKitFeedbackImplementation(haptic: .directionUp)
        case .decrease: WatchKitFeedbackImplementation(haptic: .directionDown)
        case .start: WatchKitFeedbackImplementation(haptic: .start)
        case .stop: WatchKitFeedbackImplementation(haptic: .stop)
        case .selection, .impactWeight, .impactFlexibility: WatchKitFeedbackImplementation(haptic: .click)
        default: nil
        }
    }
}
#endif
