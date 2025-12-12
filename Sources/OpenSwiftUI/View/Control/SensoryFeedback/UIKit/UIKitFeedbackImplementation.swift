//
//  UIKitFeedbackImplementation.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C9541C03AF81FECFD19A57A1BB81CE81 (SwiftUI)

#if os(iOS) || os(visionOS)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - LocationBasedSensoryFeedback

protocol LocationBasedSensoryFeedback: PlatformSensoryFeedback {
    func generate(location: CGPoint)
}

// MARK: - FeedbackRequestContextWriter

private struct FeedbackRequestContextWriter<Base>: MultiViewModifier, PrimitiveViewModifier where Base: SensoryFeedbackGeneratorModifier {
    var base: Base

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let base = modifier[offset: { .of(&$0.base) }].value
        let child = {
            guard inputs.needsGeometry else {
                return base
            }
            let location = if inputs.base.interfaceIdiom.accepts(.pad) {
                Attribute(
                    FeedbackLocation(
                        position: inputs.position,
                        size: inputs.size,
                        transform: inputs.transform
                    )
                )
            } else {
                ViewGraph.current.$zeroPoint
            }
            let feedbackCache = inputs.base.feedbackCache
            let modifier = Attribute(
                ChildModifier(
                    base: base,
                    location: location,
                    feedbackCache: feedbackCache
                )
            )
            return modifier
        }()
        return Base._makeView(
            modifier: _GraphValue(child),
            inputs: inputs,
            body: body
        )
    }

    struct ChildModifier: Rule {
        @Attribute var base: Base
        @Attribute var location: CGPoint
        @Attribute var feedbackCache: AnyUIKitSensoryFeedbackCache?

        var value: Base {
            var base = base
            base.feedbackRequestContext = .init(location: WeakAttribute($location), cache: feedbackCache)
            return base
        }
    }
}

// MARK: - NotificationFeedbackImplementation

struct NotificationFeedbackImplementation: LocationBasedSensoryFeedback {
    let generator: UINotificationFeedbackGenerator

    let type: UINotificationFeedbackGenerator.FeedbackType

    func setUp() {
        generator.prepare()
    }
    
    func tearDown() {
        _openSwiftUIEmptyStub()
    }
    
    func generate() {
        preconditionFailure("Requires location.")
    }

    func generate(location: CGPoint) {
        generator.notificationOccurred(type, at: location)
    }
}

// MARK: - SelectionFeedbackImplementation

struct SelectionFeedbackImplementation: LocationBasedSensoryFeedback {
    let generator: UISelectionFeedbackGenerator

    func setUp() {
        generator.prepare()
    }

    func tearDown() {
        _openSwiftUIEmptyStub()
    }

    func generate() {
        preconditionFailure("Requires location.")
    }

    func generate(location: CGPoint) {
        generator.selectionChanged(at: location)
    }
}

// MARK: - CanvasFeedbackImplementation

struct CanvasFeedbackImplementation: LocationBasedSensoryFeedback {
    let generator: UICanvasFeedbackGenerator
    let type: SensoryFeedback.FeedbackType

    func setUp() {
        generator.prepare()
    }

    func tearDown() {
        _openSwiftUIEmptyStub()
    }

    func generate() {
        preconditionFailure("Requires location.")
    }

    func generate(location: CGPoint) {
        switch type {
        case .alignment:
            generator.alignmentOccurred(at: location)
        case .pathComplete:
            generator.pathCompleted(at: location)
        default:
            break
        }
    }
}

// MARK: - ImpactFeedbackImplementation

struct ImpactFeedbackImplementation: LocationBasedSensoryFeedback {
    let generator: UIImpactFeedbackGenerator
    var intensity: Double

    func setUp() {
        generator.prepare()
    }

    func tearDown() {
        _openSwiftUIEmptyStub()
    }

    func generate() {
        preconditionFailure("Requires location.")
    }

    func generate(location: CGPoint) {
        generator.impactOccurred(intensity: intensity, at: location)
    }
}

// MARK: - LocationBasedFeedbackAdaptor

struct LocationBasedFeedbackAdaptor: PlatformSensoryFeedback {
    var location: Attribute<CGPoint>
    var base: any LocationBasedSensoryFeedback

    func setUp() {
        base.setUp()
    }

    func tearDown() {
        base.tearDown()
    }

    func generate() {
        let currentLocation: CGPoint = Update.ensure {
            Graph.withoutUpdate {
                location.value
            }
        }
        base.generate(location: currentLocation)
    }
}

// MARK: - LocationBasedFeedbackAdaptor

private struct FeedbackLocation: Rule {
    @Attribute var position: ViewOrigin
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform

    var value: CGPoint {
        var transform = transform
        transform.appendPosition(position)
        var rect = CGRect(origin: position, size: size.value)
        rect.convert(to: .id(hostingViewCoordinateSpace), transform: transform)
        return rect.center
    }
}

// MARK: - FeedbackRequestContext

struct FeedbackRequestContext {
    var location: WeakAttribute<CGPoint>
    weak var cache: AnyUIKitSensoryFeedbackCache?

    func implementation(type: SensoryFeedback.FeedbackType) -> PlatformSensoryFeedback? {
        guard let cache,
              let feeback = cache.implementation(type: type),
              let location = location.attribute else {
            return nil
        }
        return LocationBasedFeedbackAdaptor(
            location: location,
            base: feeback
        )
    }
}

#endif
