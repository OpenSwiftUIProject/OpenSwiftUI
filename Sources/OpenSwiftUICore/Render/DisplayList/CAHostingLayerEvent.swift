//
//  CAHostingLayerEvent.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 2095A85BBACBB369317EE0CF616E6EA7 (SwiftUICore)

@_spiOnly public import OpenCoreGraphicsShims

// MARK: - CAHostingLayerEvent

@_spi(ForUIKitOnly)
@_spi(ForAppKitOnly)
@available(OpenSwiftUI_v6_0, *)
public struct CAHostingLayerEvent {
    let _resolve: (inout Context) -> [Resolved]

    // MARK: - MouseButton

    public struct MouseButton: Hashable {
        let value: MouseEvent.Button

        public static let primary = MouseButton(value: .primary)

        public static let secondary = MouseButton(value: .secondary)

        public func hash(into hasher: inout Hasher) {
            hasher.combine(value.rawValue)
        }
    }

    // MARK: - Resolved

    struct Resolved {
        let sequence: Int
        let event: any EventType
    }

    // MARK: - Context

    struct Context {
        let referenceInstant: ContinuousClock.Instant
        fileprivate var mouseTracker: MouseTracker

        init(referenceInstant: ContinuousClock.Instant) {
            self.referenceInstant = referenceInstant
            self.mouseTracker = MouseTracker()
        }
    }

    // MARK: - Factory Methods

    public static func mousePressed(
        button: MouseButton,
        location: CGPoint,
        instant: ContinuousClock.Instant
    ) -> CAHostingLayerEvent {
        CAHostingLayerEvent { context in
            let oldResolved: Resolved?
            if let existingSequence = context.mouseTracker.current[button] {
                let event = MouseEvent(
                    timestamp: Time(seconds: Double(context.referenceInstant.duration(to: instant))),
                    button: button.value,
                    phase: .failed,
                    location: .zero,
                    globalLocation: location,
                    modifiers: []
                )
                oldResolved = Resolved(sequence: existingSequence, event: event)
            } else {
                oldResolved = nil
            }
            let sequence = context.mouseTracker.nextSequence()
            context.mouseTracker.current[button] = sequence
            context.mouseTracker.buttons.insert(button)
            let event = MouseEvent(
                timestamp: Time(seconds: Double(context.referenceInstant.duration(to: instant))),
                button: button.value,
                phase: .began,
                location: .zero,
                globalLocation: location,
                modifiers: []
            )
            let newResolved = Resolved(sequence: sequence, event: event)
            if let oldResolved {
                return [oldResolved, newResolved]
            } else {
                return [newResolved]
            }
        }
    }

    public static func mouseLifted(
        button: MouseButton,
        location: CGPoint,
        instant: ContinuousClock.Instant
    ) -> CAHostingLayerEvent {
        CAHostingLayerEvent { context in
            guard let sequence = context.mouseTracker.current[button] else {
                return []
            }
            let event = MouseEvent(
                timestamp: Time(seconds: Double(context.referenceInstant.duration(to: instant))),
                button: button.value,
                phase: .ended,
                location: .zero,
                globalLocation: location,
                modifiers: []
            )
            let result = [Resolved(sequence: sequence, event: event)]
            context.mouseTracker.current.removeValue(forKey: button)
            context.mouseTracker.buttons.remove(button)
            return result
        }
    }

    public static func mouseDragged(
        location: CGPoint,
        instant: ContinuousClock.Instant
    ) -> CAHostingLayerEvent {
        CAHostingLayerEvent { context in
            return context.mouseTracker.buttons.map { button in
                let sequence = context.mouseTracker.current[button]!
                let event = MouseEvent(
                    timestamp: Time(seconds: Double(context.referenceInstant.duration(to: instant))),
                    button: button.value,
                    phase: .active,
                    location: .zero,
                    globalLocation: location,
                    modifiers: []
                )
                return Resolved(sequence: sequence, event: event)
            }
        }
    }
}

// MARK: - Sendable

@_spi(ForUIKitOnly)
@_spi(ForAppKitOnly)
@available(*, unavailable)
extension CAHostingLayerEvent: Sendable {}

@_spi(ForUIKitOnly)
@_spi(ForAppKitOnly)
@available(*, unavailable)
extension CAHostingLayerEvent.MouseButton: Sendable {}

// MARK: - MouseTracker

private struct MouseTracker {
    var current: [CAHostingLayerEvent.MouseButton: Int]
    private var last: Int
    var buttons: Set<CAHostingLayerEvent.MouseButton>

    init() {
        self.current = [:]
        self.last = 1000
        self.buttons = []
    }

    @inline(__always)
    mutating func nextSequence() -> Int {
        last += 1
        return last
    }
}
