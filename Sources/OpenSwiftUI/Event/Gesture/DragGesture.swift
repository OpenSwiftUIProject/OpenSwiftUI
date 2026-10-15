//
//  DragGesture.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 686AE3220CDF86066434C733931F13C8 (SwiftUI)

public import Foundation
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - DragGesture

/// A gesture that follows a touch or pointer as it moves across a view.
///
/// A drag gesture starts after the touch or pointer moves at least
/// ``minimumDistance`` points from the location where it went down. After it
/// starts, the gesture produces a new ``Value`` each time the location
/// changes. The gesture ends when the touch lifts or the mouse button is
/// released.
///
/// To recognize a drag gesture on a view, create and configure the gesture,
/// and then add it to the view with the ``View/gesture(_:including:)``
/// modifier. Use ``Gesture/onChanged(_:)`` to react to each update and
/// ``Gesture/onEnded(_:)`` to react when the drag finishes. To keep
/// temporary state that resets when the gesture ends, use
/// ``Gesture/updating(_:body:)`` with a ``GestureState`` property.
///
/// The following code lets people move a ``Circle``. The circle follows the
/// drag while it is in progress, and keeps its new position after the drag
/// ends:
///
///     struct DraggableCircle: View {
///         @State private var position: CGSize = .zero
///         @GestureState private var dragOffset: CGSize = .zero
///
///         var drag: some Gesture {
///             DragGesture()
///                 .updating($dragOffset) { value, state, _ in
///                     state = value.translation
///                 }
///                 .onEnded { value in
///                     position.width += value.translation.width
///                     position.height += value.translation.height
///                 }
///         }
///
///         var body: some View {
///             Circle()
///                 .fill(dragOffset == .zero ? Color.blue : Color.green)
///                 .frame(width: 100, height: 100)
///                 .offset(
///                     x: position.width + dragOffset.width,
///                     y: position.height + dragOffset.height
///                 )
///                 .gesture(drag)
///         }
///     }
///
/// The gesture reports locations in its ``coordinateSpace``. By default, this
/// is the local coordinate space of the view that has the gesture.
@available(OpenSwiftUI_v1_0, *)
@available(tvOS, unavailable) // @_spi_available(tvOS, introduced: 18.0)
public struct DragGesture: PrimitiveGesture, PubliclyPrimitiveGesture, Gesture {

    /// The attributes of a drag gesture.
    ///
    /// The gesture creates a value for each change of the drag. All locations
    /// are in the coordinate space of the gesture.
    public struct Value: Equatable, Sendable {
        /// The time of the event that created this value.
        public var time: Date

        /// The location of the current event.
        public var location: CGPoint

        /// The location of the event that started the drag.
        public var startLocation: CGPoint

        /// The distance from the start location to the current location.
        ///
        /// This value is equal to `location - startLocation`.
        public var translation: CGSize {
            location - startLocation
        }

        /// The current speed of the drag, in points per second.
        @_alwaysEmitIntoClient
        public var velocity: CGSize {
            let predicted = predictedEndLocation
            return CGSize(
                width: 4.0 * (predicted.x - location.x),
                height: 4.0 * (predicted.y - location.y)
            )
        }

        /// An estimate of where the drag stops if it stops now.
        ///
        /// The estimate uses the current ``velocity`` of the drag.
        public var predictedEndLocation: CGPoint {
            location + _velocity.valuePerSecond * 0.25
        }

        /// An estimate of the total ``translation`` if the drag stops now.
        ///
        /// The estimate uses the current ``velocity`` of the drag.
        public var predictedEndTranslation: CGSize {
            translation + _velocity.valuePerSecond * 0.25
        }

        var _velocity: _Velocity<CGSize>

        var platform = Platform()

        struct Platform: Equatable {}
    }

    /// The minimum distance, in points, that the touch or pointer must move
    /// before the gesture starts.
    public var minimumDistance: CGFloat

    /// The coordinate space in which the gesture reports locations.
    public var coordinateSpace: CoordinateSpace

    var allowedDirections: _EventDirections = .all

    /// Creates a drag gesture with a minimum distance and a coordinate space.
    ///
    /// - Parameters:
    ///   - minimumDistance: The minimum distance, in points, that the touch
    ///     or pointer must move before the gesture starts. The default is
    ///     `10`.
    ///   - coordinateSpace: The coordinate space in which the gesture
    ///     reports locations. The default is ``CoordinateSpace/local``.
    @available(*, deprecated, message: "use overload that accepts a CoordinateSpaceProtocol instead")
    @_disfavoredOverload
    public init(minimumDistance: CGFloat = 10, coordinateSpace: CoordinateSpace = .local) {
        self.minimumDistance = minimumDistance
        self.coordinateSpace = coordinateSpace
    }

    /// Creates a drag gesture with a minimum distance and a coordinate space.
    ///
    /// - Parameters:
    ///   - minimumDistance: The minimum distance, in points, that the touch
    ///     or pointer must move before the gesture starts. The default is
    ///     `10`.
    ///   - coordinateSpace: The coordinate space in which the gesture
    ///     reports locations. The default is ``CoordinateSpaceProtocol/local``.
    @available(OpenSwiftUI_v5_0, *)
    public init(minimumDistance: CGFloat = 10, coordinateSpace: some CoordinateSpaceProtocol = .local) {
        self.minimumDistance = minimumDistance
        self.coordinateSpace = coordinateSpace.coordinateSpace
    }

    init(
        minimumDistance: CGFloat,
        coordinateSpace: some CoordinateSpaceProtocol,
        allowedDirections: _EventDirections
    ) {
        self.minimumDistance = minimumDistance
        self.coordinateSpace = coordinateSpace.coordinateSpace
        self.allowedDirections = allowedDirections
    }

    nonisolated public static func _makeGesture(
        gesture: _GraphValue<DragGesture>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<DragGesture.Value> {
        makeGesture(gesture: gesture, inputs: inputs)
    }

    package var internalBody: some Gesture<Value> {
        // FIXME: SwiftUI maps DragGesture3D on visionOS.
        SpatialDragGesture(
            minimumDistance: minimumDistance,
            coordinateSpace: coordinateSpace,
            allowedDirections: allowedDirections
        )
        .category(.drag, includeChildren: false)
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension DragGesture: Sendable {}

// MARK: - SpatialDragGesture

#if os(macOS)
private typealias DragEvent = MouseEvent
#else
private typealias DragEvent = TouchEvent
#endif

@available(tvOS, unavailable)
private struct SpatialDragGesture: Gesture {
    struct StateType: GestureStateProtocol {
        var start: DragEvent?
        var value: DragGesture.Value?
        var sampler: VelocitySampler<AnimatablePair<CGFloat, CGFloat>>

        init() {
            start = nil
            value = nil
            sampler = VelocitySampler()
        }
    }

    var minimumDistance: CGFloat
    var coordinateSpace: CoordinateSpace
    var allowedDirections: _EventDirections

    var body: some Gesture<DragGesture.Value> {
        StateType.gesture(
            content: EventListener<DragEvent>()
                .eventFilter(forType: MouseEvent.self) { event in
                    event.button == .primary
                }
                .coordinateSpace(coordinateSpace)
        ) { state, phase in
            self.phase(state: &state, event: phase)
        }
        .dependency(.pausedUntilFailed)
    }

    func phase(
        state: inout StateType,
        event: GesturePhase<DragEvent>
    ) -> GesturePhase<DragGesture.Value> {
        switch event {
        case .possible:
            guard !allowedDirections.isEmpty else {
                return .failed
            }
            return .possible(state.value)
        case let .active(currentEvent), let .ended(currentEvent):
            let start = state.start ?? currentEvent
            state.start = start
            let location = currentEvent.location
            state.sampler.addSample(
                AnimatablePair(location.x, location.y),
                time: currentEvent.timestamp
            )
            let value = DragGesture.Value(
                time: Date(timeIntervalSinceReferenceDate: currentEvent.timestamp.seconds),
                location: location,
                startLocation: start.location,
                _velocity: state.sampler.velocity.map { velocity in
                    CGSize(width: velocity.first, height: velocity.second)
                }
            )
            if state.value == nil, minimumDistance > 0 {
                let translation = start.globalLocation - currentEvent.globalLocation
                guard Double(minimumDistance) <= translation.magnitude,
                      translation.withinRange(axes: allowedDirections, rangeCosine: 0.5)
                else {
                    return event.isEnded ? .failed : .possible(state.value)
                }
            }
            state.value = value
            return event.withValue(value)
        case .failed:
            return .failed
        }
    }
}
