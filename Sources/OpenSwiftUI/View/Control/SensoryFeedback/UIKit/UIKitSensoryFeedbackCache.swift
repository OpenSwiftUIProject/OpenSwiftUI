//
//  UIKitSensoryFeedbackCache.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 54085EE6CA77C60CA86318C59A381498 (SwiftUI)

#if os(iOS) || os(visionOS)

import OpenAttributeGraphShims
import OpenSwiftUICore
import UIKit

// MARK: - AnyUIKitSensoryFeedbackCache

class AnyUIKitSensoryFeedbackCache {
    func implementation(
        type: SensoryFeedback.FeedbackType
    ) -> LocationBasedSensoryFeedback? {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

// MARK: - UIKitSensoryFeedbackCache

class UIKitSensoryFeedbackCache<V>: AnyUIKitSensoryFeedbackCache where V: View {
    weak var host: _UIHostingView<V>?
    var cachedGenerators: [SensoryFeedback.FeedbackType: UIFeedbackGenerator] = [:]

    override func implementation(
        type: SensoryFeedback.FeedbackType
    ) -> LocationBasedSensoryFeedback? {
        switch type {
        case .success:
            getGenerator(type) {
                NotificationFeedbackImplementation(
                    generator: $0,
                    type: .success
                )
            } createIfNeeded: {
                UINotificationFeedbackGenerator()
            }
        case .warning:
            getGenerator(type) {
                NotificationFeedbackImplementation(
                    generator: $0,
                    type: .warning
                )
            } createIfNeeded: {
                UINotificationFeedbackGenerator()
            }
        case .error:
            getGenerator(type) {
                NotificationFeedbackImplementation(
                    generator: $0,
                    type: .error
                )
            } createIfNeeded: {
                UINotificationFeedbackGenerator()
            }
        // SwiftUI implementation Bug: introduced since iOS 17 & iOS 26.2 is still not fixed
        // FB21332474
        case /*.increase, .decrease,*/ .selection:
            getGenerator(type) {
                SelectionFeedbackImplementation(
                    generator: $0 
                )
            } createIfNeeded: {
                UISelectionFeedbackGenerator()
            }
        case .alignment, .pathComplete:
            getGenerator(type) {
                CanvasFeedbackImplementation(
                    generator: $0,
                    type: type
                )
            } createIfNeeded: {
                UICanvasFeedbackGenerator()
            }
        case let .impactWeight(weight, intensity):
            getGenerator(type) {
                ImpactFeedbackImplementation(
                    generator: $0,
                    intensity: intensity
                )
            } createIfNeeded: { () -> UIImpactFeedbackGenerator in
                switch weight {
                case .light: UIImpactFeedbackGenerator(style: .light)
                case .medium: UIImpactFeedbackGenerator(style: .medium)
                case .heavy: UIImpactFeedbackGenerator(style: .heavy)
                }
            }
        case let .impactFlexibility(flexibility, intensity):
            getGenerator(type) {
                ImpactFeedbackImplementation(
                    generator: $0,
                    intensity: intensity
                )
            } createIfNeeded: { () -> UIImpactFeedbackGenerator in
                switch flexibility {
                case .rigid: UIImpactFeedbackGenerator(style: .rigid)
                case .solid: UIImpactFeedbackGenerator(style: .medium)
                case .soft: UIImpactFeedbackGenerator(style: .soft)
                }
            }
        default: nil
        }
    }

    private func getGenerator<Generator, Feedback>(
        _ type: SensoryFeedback.FeedbackType,
        work: (Generator) -> Feedback,
        createIfNeeded: () -> Generator
    ) -> Feedback where Generator: UIFeedbackGenerator, Feedback: LocationBasedSensoryFeedback {
        let generator: Generator
        if let cachedGenerator = cachedGenerators[type] {
            generator = cachedGenerator as! Generator
        } else {
            generator = createIfNeeded()
            cachedGenerators[type] = generator
            host!.addInteraction(generator)
        }
        return work(generator)
    }
}

// MARK: - FeedbackCacheKey

private struct FeedbackCacheKey: EnvironmentKey {
    static var defaultValue: WeakBox<AnyUIKitSensoryFeedbackCache> { .init() }
}

extension CachedEnvironment.ID {
    static let feedbackCache: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    var feedbackCache: Attribute<AnyUIKitSensoryFeedbackCache?> {
        mapEnvironment(id: .feedbackCache) { $0.feedbackCache }
    }
}

extension EnvironmentValues {
    var feedbackCache: AnyUIKitSensoryFeedbackCache? {
        get { self[FeedbackCacheKey.self].base }
        set { self[FeedbackCacheKey.self] = WeakBox(newValue) }
    }
}

#endif
