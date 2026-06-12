//
//  SpatialTapGesture.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 4CBCFA1A8492A311E8B21AE224C33BFC (SwiftUI)

@_spi(ForOpenSwiftUIOnly) public import OpenSwiftUICore
import OpenAttributeGraphShims

// MARK: - SpatialTapGesture

/// A gesture that recognizes one or more taps and reports their location.
///
/// To recognize a tap gesture on a view, create and configure the gesture, and
/// then add it to the view using the ``View/gesture(_:including:)`` modifier.
/// The following code adds a tap gesture to a ``Circle`` that toggles the color
/// of the circle based on the tap location:
///
///     struct TapGestureView: View {
///         @State private var location: CGPoint = .zero
///
///         var tap: some Gesture {
///             SpatialTapGesture()
///                 .onEnded { event in
///                     self.location = event.location
///                  }
///         }
///
///         var body: some View {
///             Circle()
///                 .fill(self.location.y > 50 ? Color.blue : Color.red)
///                 .frame(width: 100, height: 100, alignment: .center)
///                 .gesture(tap)
///         }
///     }
@available(OpenSwiftUI_v4_0, *)
@_spi_available(tvOS, introduced: 17.0)
public struct SpatialTapGesture: PrimitiveGesture, Gesture {
    private struct Phase: Rule {
        @Attribute var phase: GesturePhase<TappableSpatialEvent>

        typealias Value = GesturePhase<SpatialTapGesture.Value>

        var value: GesturePhase<SpatialTapGesture.Value> {
            phase.map { event in
                SpatialTapGesture.Value(location: event.location)
            }
        }
    }

    private struct Child: Rule {
        @Attribute var gesture: SpatialTapGesture

        var value: some Gesture<TappableSpatialEvent> {
            SingleTapGesture<TappableSpatialEvent>()
                .repeatCount(gesture.count)
                .coordinateSpace(gesture.coordinateSpace)
                .requiredTapCount(gesture.count)
        }
    }

    /// The attributes of a tap gesture.
    public struct Value: Equatable, @unchecked Sendable {
        /// The location of the tap gesture's current event.
        public var location: CGPoint
    }

    /// The required number of tap events.
    public var count: Int

    /// The coordinate space in which to receive location values.
    public var coordinateSpace: CoordinateSpace

    /// Creates a tap gesture with the number of required taps and the
    /// coordinate space of the gesture's location.
    ///
    /// - Parameters:
    ///   - count: The required number of taps to complete the tap
    ///     gesture.
    ///   - coordinateSpace: The coordinate space of the tap gesture's location.
    @available(*, deprecated, message: "use overload that accepts a CoordinateSpaceProtocol instead")
    @available(tvOS, unavailable)
    @_disfavoredOverload
    public init(count: Int = 1, coordinateSpace: CoordinateSpace = .local) {
        self.count = count
        self.coordinateSpace = coordinateSpace
    }

    /// Creates a tap gesture with the number of required taps and the
    /// coordinate space of the gesture's location.
    ///
    /// - Parameters:
    ///   - count: The required number of taps to complete the tap
    ///     gesture.
    ///   - coordinateSpace: The coordinate space of the tap gesture's location.
    @available(OpenSwiftUI_v5_0, *)
    @_spi_available(tvOS, introduced: 17.0)
    public init(count: Int = 1, coordinateSpace: some CoordinateSpaceProtocol = .local) {
        self.count = count
        self.coordinateSpace = coordinateSpace.coordinateSpace
    }

    nonisolated public static func _makeGesture(
        gesture: _GraphValue<SpatialTapGesture>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<SpatialTapGesture.Value> {
        let child = Attribute(Child(gesture: gesture.value))
        let outputs = Child.Value._makeGesture(
            gesture: _GraphValue(child),
            inputs: inputs
        )
        let phase = Attribute(Phase(phase: outputs.phase))
        return outputs.withPhase(phase)
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension SpatialTapGesture: Sendable {}

// MARK: - View + SpatialTapGesture

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
extension View {
    /// Adds an action to perform when this view recognizes a tap gesture,
    /// and provides the action with the location of the interaction.
    ///
    /// Use this method to perform the specified `action` when the user clicks
    /// or taps on the modified view `count` times. The action closure receives
    /// the location of the interaction.
    ///
    /// > Note: If you create a control that's functionally equivalent
    /// to a ``Button``, use ``ButtonStyle`` to create a customized button
    /// instead.
    ///
    /// The following code adds a tap gesture to a ``Circle`` that toggles the color
    /// of the circle based on the tap location.
    ///
    ///     struct TapGestureExample: View {
    ///         @State private var location: CGPoint = .zero
    ///
    ///         var body: some View {
    ///             Circle()
    ///                 .fill(self.location.y > 50 ? Color.blue : Color.red)
    ///                 .frame(width: 100, height: 100, alignment: .center)
    ///                 .onTapGesture { location in
    ///                     self.location = location
    ///                 }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///    - count: The number of taps or clicks required to trigger the action
    ///      closure provided in `action`. Defaults to `1`.
    ///    - coordinateSpace: The coordinate space in which to receive
    ///      location values. Defaults to ``CoordinateSpace/local``.
    ///    - action: The action to perform. This closure receives an input
    ///      that indicates where the interaction occurred.
    @available(*, deprecated, message: "use overload that accepts a CoordinateSpaceProtocol instead")
    @_disfavoredOverload
    nonisolated public func onTapGesture(
        count: Int = 1,
        coordinateSpace: CoordinateSpace = .local,
        perform action: @escaping (CGPoint) -> Void
    ) -> some View {
        gesture(
            SpatialTapGesture(count: count, coordinateSpace: coordinateSpace).onEnded { value in
                action(value.location)
            },
            including: .all
        )
    }
}

@available(OpenSwiftUI_v5_0, *)
@_spi_available(tvOS, introduced: 17.0)
extension View {
    /// Adds an action to perform when this view recognizes a tap gesture,
    /// and provides the action with the location of the interaction.
    ///
    /// Use this method to perform the specified `action` when the user clicks
    /// or taps on the modified view `count` times. The action closure receives
    /// the location of the interaction.
    ///
    /// > Note: If you create a control that's functionally equivalent
    /// to a ``Button``, use ``ButtonStyle`` to create a customized button
    /// instead.
    ///
    /// The following code adds a tap gesture to a ``Circle`` that toggles the color
    /// of the circle based on the tap location.
    ///
    ///     struct TapGestureExample: View {
    ///         @State private var location: CGPoint = .zero
    ///
    ///         var body: some View {
    ///             Circle()
    ///                 .fill(self.location.y > 50 ? Color.blue : Color.red)
    ///                 .frame(width: 100, height: 100, alignment: .center)
    ///                 .onTapGesture { location in
    ///                     self.location = location
    ///                 }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///    - count: The number of taps or clicks required to trigger the action
    ///      closure provided in `action`. Defaults to `1`.
    ///    - coordinateSpace: The coordinate space in which to receive
    ///      location values. Defaults to ``CoordinateSpace/local``.
    ///    - action: The action to perform. This closure receives an input
    ///      that indicates where the interaction occurred.
    nonisolated public func onTapGesture(
        count: Int = 1,
        coordinateSpace: some CoordinateSpaceProtocol = .local,
        perform action: @escaping (CGPoint) -> Void
    ) -> some View {
        gesture(
            SpatialTapGesture(count: count, coordinateSpace: coordinateSpace).onEnded { value in
                action(value.location)
            },
            including: .all
        )
    }
}
