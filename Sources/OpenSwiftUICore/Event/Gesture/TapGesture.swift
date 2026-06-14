//
//  TapGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 067A6A2846A89ACCD702678B6B8D0D6F (SwiftUICore)

package import Foundation
import OpenAttributeGraphShims

// MARK: - TapGesture

/// A gesture that recognizes one or more taps.
///
/// To recognize a tap gesture on a view, create and configure the gesture, and
/// then add it to the view using the ``View/gesture(_:including:)`` modifier.
/// The following code adds a tap gesture to a ``Circle`` that toggles the color
/// of the circle:
///
///     struct TapGestureView: View {
///         @State private var tapped = false
///
///         var tap: some Gesture {
///             TapGesture(count: 1)
///                 .onEnded { _ in self.tapped = !self.tapped }
///         }
///
///         var body: some View {
///             Circle()
///                 .fill(self.tapped ? Color.blue : Color.red)
///                 .frame(width: 100, height: 100, alignment: .center)
///                 .gesture(tap)
///         }
///     }
@available(OpenSwiftUI_v1_0, *)
public struct TapGesture: PrimitiveGesture, Gesture {
    private struct Phase: Rule {
        @Attribute var phase: GesturePhase<TappableEvent>

        typealias Value = GesturePhase<Void>

        var value: GesturePhase<Void> {
            phase.withValue(())
        }
    }

    private struct Child: Rule {
        @Attribute var gesture: TapGesture

        var value: some Gesture<TappableEvent> {
            SingleTapGesture<TappableEvent>()
                .repeatCount(gesture.count)
                .category(gesture.count == 1 ? .select : [])
                .requiredTapCount(gesture.count)
        }
    }

    /// The required number of tap events.
    public var count: Int

    /// Creates a tap gesture with the number of required taps.
    ///
    /// - Parameter count: The required number of taps to complete the tap
    ///   gesture.
    public init(count: Int = 1) {
        self.count = count
    }

    nonisolated public static func _makeGesture(
        gesture: _GraphValue<TapGesture>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Void> {
        let child = Attribute(Child(gesture: gesture.value))
        let outputs = Child.Value.makeDebuggableGesture(
            gesture: _GraphValue(child),
            inputs: inputs
        )
        let phase = Attribute(Phase(phase: outputs.phase))
        return outputs.withPhase(phase)
    }

    public typealias Value = Void
}

@available(*, unavailable)
extension TapGesture: Sendable {}

// MARK: - View + TapGesture

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Adds an action to perform when this view recognizes a tap gesture.
    ///
    /// Use this method to perform the specified `action` when the user clicks
    /// or taps on the view or container `count` times.
    ///
    /// > Note: If you create a control that's functionally equivalent
    /// to a ``Button``, use ``ButtonStyle`` to create a customized button
    /// instead.
    ///
    /// In the example below, the color of the heart images changes to a random
    /// color from the `colors` array whenever the user clicks or taps on the
    /// view twice:
    ///
    ///     struct TapGestureExample: View {
    ///         let colors: [Color] = [.gray, .red, .orange, .yellow,
    ///                                .green, .blue, .purple, .pink]
    ///         @State private var fgColor: Color = .gray
    ///
    ///         var body: some View {
    ///             Image(systemName: "heart.fill")
    ///                 .resizable()
    ///                 .frame(width: 200, height: 200)
    ///                 .foregroundColor(fgColor)
    ///                 .onTapGesture(count: 2) {
    ///                     fgColor = colors.randomElement()!
    ///                 }
    ///         }
    ///     }
    ///
    /// ![A screenshot of a view of a heart.](OpenSwiftUI-View-TapGesture.png)
    ///
    /// - Parameters:
    ///    - count: The number of taps or clicks required to trigger the action
    ///      closure provided in `action`. Defaults to `1`.
    ///    - action: The action to perform.
    nonisolated public func onTapGesture(
        count: Int = 1,
        perform action: @escaping () -> Void
    ) -> some View {
        gesture(
            TapGesture(count: count).onEnded { _ in
                action()
            },
            including: .all
        )
    }
}

// MARK: - Tap Threshold Constant

package let tapMovementThreshold: CGFloat = 45

package let tapDurationThreshold: CGFloat = 0.75

// MARK: - SingleTapGesture

package struct SingleTapGesture<BaseEvent>: Gesture where BaseEvent: TappableEventType {
    package init() {}

    package var body: some Gesture<BaseEvent> {
        EventListener<BaseEvent>()
            .discrete()
            .dependency(.failIfActive)
            .gated(by: EventListener<TappableEvent>().duration(maximum: tapDurationThreshold))
            .gated(by: DistanceGesture(maximumDistance: tapMovementThreshold).coordinateSpace(.global))
            .eventFilter(forType: MouseEvent.self) { event in
                event.button == .primary
            }
    }

    package typealias Value = BaseEvent
}
