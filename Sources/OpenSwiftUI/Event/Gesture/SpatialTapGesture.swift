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

@available(iOS 16.0, macOS 13.0, watchOS 9.0, visionOS 1.0, *)
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

    public struct Value: Equatable, @unchecked Sendable {
        public var location: CGPoint
    }

    public var count: Int

    public var coordinateSpace: CoordinateSpace

    @available(iOS, introduced: 16.0, deprecated: 100000.0, message: "use overload that accepts a CoordinateSpaceProtocol instead")
    @available(macOS, introduced: 13.0, deprecated: 100000.0, message: "use overload that accepts a CoordinateSpaceProtocol instead")
    @available(watchOS, introduced: 9.0, deprecated: 100000.0, message: "use overload that accepts a CoordinateSpaceProtocol instead")
    @available(tvOS, unavailable)
    @available(visionOS, introduced: 1.0, deprecated: 100000.0, message: "use overload that accepts a CoordinateSpaceProtocol instead")
    @_disfavoredOverload
    public init(count: Int = 1, coordinateSpace: CoordinateSpace = .local) {
        self.count = count
        self.coordinateSpace = coordinateSpace
    }

    @available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
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
        let outputs = Child.Value.makeDebuggableGesture(
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

@available(iOS 16.0, macOS 13.0, watchOS 9.0, visionOS 1.0, *)
@available(tvOS, unavailable)
extension View {
    @available(iOS, introduced: 16.0, deprecated: 100000.0, message: "use overload that accepts a CoordinateSpaceProtocol instead")
    @available(macOS, introduced: 13.0, deprecated: 100000.0, message: "use overload that accepts a CoordinateSpaceProtocol instead")
    @available(watchOS, introduced: 9.0, deprecated: 100000.0, message: "use overload that accepts a CoordinateSpaceProtocol instead")
    @available(tvOS, unavailable)
    @available(visionOS, introduced: 1.0, deprecated: 100000.0, message: "use overload that accepts a CoordinateSpaceProtocol instead")
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

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
@_spi_available(tvOS, introduced: 17.0)
extension View {
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
