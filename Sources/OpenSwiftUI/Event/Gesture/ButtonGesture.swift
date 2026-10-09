//
//  ButtonGesture.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 2218E1141B3D7C3A65B6697591AFB638 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - _ButtonGesture

@available(OpenSwiftUI_v1_0, *)
public struct _ButtonGesture: PrimitiveGesture, PubliclyPrimitiveGesture, Gesture {
    @preconcurrency
    nonisolated(unsafe) public var action: @MainActor () -> Void

    @preconcurrency
    nonisolated(unsafe) public var pressingAction: (@MainActor (Bool) -> Void)?

    var touchDelay: Double?

    @preconcurrency
    nonisolated public init(
        action: @escaping @MainActor () -> Void,
        pressing: (@MainActor (Bool) -> Void)? = nil
    ) {
        self.action = action
        pressingAction = pressing
        touchDelay = nil
    }

    nonisolated public static func _makeGesture(
        gesture: _GraphValue<_ButtonGesture>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Void> {
        makeGesture(gesture: gesture, inputs: inputs)
    }

    package var internalBody: some Gesture<Void> {
        StaticIf(ImprovedButtonGestureFeature.self) {
            PrimitiveButtonGesture(
                pressingAction: pressingAction.map { action in
                    .withinBounds { phase in
                        MainActor.assumeIsolated {
                            action(phase == .pressingInside)
                        }
                    }
                },
                pressedAction: { _ in
                    MainActor.assumeIsolated {
                        action()
                    }
                },
                touchDelay: touchDelay
            )
            .map { _ in () }
        } else: {
            LegacyBody(base: self)
        }
    }

    public typealias Body = Never

    public typealias Value = Void

    private struct LegacyBody: Gesture {
        @Environment(\.buttonOutset) var outset

        var base: _ButtonGesture

        var body: some Gesture<Void> {
            let effectiveOutset: CGFloat
            if let outset {
                effectiveOutset = outset
            } else if _GraphInputs.defaultInterfaceIdiom.accepts(.pad) {
                effectiveOutset = 25
            } else if _GraphInputs.defaultInterfaceIdiom.accepts(.mac) {
                effectiveOutset = 0
            } else {
                effectiveOutset = 70
            }
            return LegacyButtonGesture(
                outset: effectiveOutset,
                touchDelay: base.touchDelay ?? 0
            )
            .callbacks(pressing: base.pressingAction, pressed: base.action)
            .map { _ in () }
        }
    }
}

@available(*, unavailable)
extension _ButtonGesture: Sendable {}

// MARK: - View + _onButtonGesture

@available(OpenSwiftUI_v1_0, *)
extension View {
    @MainActor
    @preconcurrency
    public func _onButtonGesture(
        pressing: ((Bool) -> Void)? = nil,
        perform action: @escaping () -> Void
    ) -> some View {
        modifier(ButtonActionModifier(
            gesture: _ButtonGesture(action: action, pressing: pressing),
            action: action
        ))
    }
}

// MARK: - ButtonActionModifier

struct ButtonActionModifier<G>: GestureViewModifier where G: Gesture {
    var gesture: G

    var action: () -> Void

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = makeView(modifier: modifier, inputs: inputs, body: body)
        if inputs.preferences.requiresPlatformItemList,
           inputs.platformItemListFlags.contains(.selection) {
            outputs.transformPlatformItemList(
                inputs: inputs,
                transform: Attribute(PlatformSelectionBehavior(
                    modifier: modifier.value,
                    isEnabled: inputs.isEnabled,
                    springLoadingBehavior: inputs.base.springLoadingBehavior
                ))
            )
        }
        if inputs.preferences.requiresPlatformItems,
           inputs.platformItemFeatures.contains(.selection) {
            let action = Attribute(PlatformAction(modifier: modifier.value))
            let selection = Attribute(PlatformButtonActionTransform.SelectionContent(
                action: action,
                isEnabled: inputs.isEnabled,
                springLoadingBehavior: inputs.base.springLoadingBehavior
            ))
            let transform = Attribute(PlatformButtonActionTransform.MakeTransform(
                selection: selection
            ))
            PlatformButtonActionTransform.transformPlatformItemsOutputs(
                &outputs,
                inputs: inputs,
                modifier: _GraphValue(transform)
            )
        }
        return outputs
    }

    private struct PlatformSelectionBehavior: Rule {
        @Attribute var modifier: ButtonActionModifier
        @Attribute var isEnabled: Bool
        @Attribute var springLoadingBehavior: SpringLoadingBehavior

        var value: (inout PlatformItemList) -> Void {
            let modifier = modifier
            let isEnabled = isEnabled
            let springLoadingBehavior = springLoadingBehavior
            return { list in
                var item = list.mergedContentItem
                item.selectionBehavior = isEnabled
                    ? .init(onSelect: modifier.action, springLoadingBehavior: springLoadingBehavior)
                    : .init()
                item.isEnabled = isEnabled
                list.items = [item]
            }
        }
    }

    private struct PlatformAction: Rule {
        @Attribute var modifier: ButtonActionModifier

        var value: (() -> Void)? {
            modifier.action
        }
    }
}

// MARK: - ButtonOutsetKey

private struct ButtonOutsetKey: EnvironmentKey {
    static var defaultValue: CGFloat? { nil }
}

extension EnvironmentValues {
    var buttonOutset: CGFloat? {
        get { self[ButtonOutsetKey.self] }
        set { self[ButtonOutsetKey.self] = newValue }
    }
}

extension CachedEnvironment.ID {
    fileprivate static let buttonOutset = CachedEnvironment.ID()
}

extension View {
    func buttonOutset(_ outset: CGFloat?) -> some View {
        environment(\.buttonOutset, outset)
    }
}

// MARK: - PrimitiveButtonGesture

struct PrimitiveButtonGesture: PrimitiveGesture {
    var pressingAction: ButtonPressingAction?

    var pressedAction: (CGPoint?) -> Void

    var touchDelay: Double? = nil

    nonisolated static func _makeGesture(
        gesture: _GraphValue<Self>,
        inputs: _GestureInputs
    ) -> _GestureOutputs<Void> {
        let child = Attribute(Child(
            gesture: gesture.value,
            outset: inputs.viewInputs.base.mapEnvironment(id: .buttonOutset) { $0.buttonOutset },
            interfaceIdiom: inputs.viewInputs.base.interfaceIdiom
        ))
        let outputs = Child.Value.makeDebuggableGesture(
            gesture: _GraphValue(child),
            inputs: inputs
        )
        return outputs.withPhase(Attribute(Phase(phase: outputs.phase)))
    }

    typealias Value = Void

    private struct Child: Rule {
        @Attribute var gesture: PrimitiveButtonGesture
        @Attribute var outset: CGFloat?
        var interfaceIdiom: AnyInterfaceIdiom

        var value: some Gesture<PrimitiveButtonGestureCore.Value> {
            PrimitiveButtonGestureCore(outset: effectiveOutset, touchDelay: gesture.touchDelay)
                .callbacks(PrimitiveButtonGestureCallbacks(
                    pressingAction: gesture.pressingAction,
                    pressedAction: gesture.pressedAction
                ))
                .requiredTapCount(1)
        }

        var effectiveOutset: CGFloat {
            if let outset {
                return outset
            } else if interfaceIdiom.accepts(.pad) {
                return 25
            } else if interfaceIdiom.accepts(.mac) {
                return 0
            } else {
                return 70
            }
        }
    }

    private struct Phase: Rule {
        @Attribute var phase: GesturePhase<PrimitiveButtonGestureCore.Value>

        var value: GesturePhase<Void> {
            phase.withValue(())
        }
    }
}

// MARK: - ButtonPressingAction

enum ButtonPressingAction {
    case withinBounds((ButtonPressPhase) -> Void)
    case simple((Bool) -> Void)
}

// MARK: - ButtonPressPhase

enum ButtonPressPhase: Hashable {
    case inactive
    case pressingOutside
    case pressingInside
    case pressedInside
}

// MARK: - LegacyButtonGesture

private struct LegacyButtonGesture: Gesture {
    var outset: CGFloat

    var touchDelay: Double

    var body: some Gesture<Value> {
        SizeGesture { size in
            EventListener<SpatialEvent>()
                .delayed(by: touchDelay) { $0.kind == .touch }
                .mapPhase { phase in
                    let bounds = CGRect(origin: .zero, size: size)
                        .insetBy(dx: -outset, dy: -outset)
                    switch phase {
                    case .possible(nil):
                        return .possible(nil)
                    case let .possible(event?), let .active(event):
                        let value = Value(
                            location: event.location,
                            timestamp: event.timestamp,
                            inside: bounds.contains(event.location)
                        )
                        return .possible(value.inside ? value : nil)
                    case let .ended(event):
                        let value = Value(
                            location: event.location,
                            timestamp: event.timestamp,
                            inside: bounds.contains(event.location)
                        )
                        return value.inside ? .ended(value) : .failed
                    case .failed:
                        return .failed
                    }
                }
        }
        .dependency(.failIfActive)
        .eventFilter(forType: MouseEvent.self) { $0.button == .primary }
        .eventFilter(forType: SpatialEvent.self) { $0.kind != .pan }
    }

    struct Value: PressableEventValue {
        var location: CGPoint
        var timestamp: Time
        var inside: Bool

        static func isPressing(_ phase: GesturePhase<Value>) -> Bool {
            phase.unwrapped?.inside ?? false
        }
    }
}

// MARK: - PrimitiveButtonGestureCore

private struct PrimitiveButtonGestureCore: Gesture {
    var outset: CGFloat

    var touchDelay: Double?

    var body: some Gesture<Value> {
        SizeGesture { size in
            EventListener<SpatialEvent>()
                .delayed(by: touchDelay ?? 0.012) { $0.kind == .touch }
                .mapPhase { phase in
                    let bounds = CGRect(origin: .zero, size: size)
                    let value = phase.map { event in
                        let locationInBounds: LocationInBounds
                        if bounds.contains(event.location) {
                            locationInBounds = .inside
                        } else if bounds.insetBy(dx: -outset, dy: -outset).contains(event.location) {
                            locationInBounds = .insideExtended
                        } else {
                            locationInBounds = .outsideExtended
                        }
                        return Value(
                            location: event.location,
                            timestamp: event.timestamp,
                            locationInBounds: locationInBounds
                        )
                    }
                    if case let .ended(event) = value, event.locationInBounds == .outsideExtended {
                        return .failed
                    }
                    return value
                }
        }
        .dependency(.failIfActive)
        .eventFilter(forType: MouseEvent.self) { $0.button == .primary }
        .eventFilter(forType: SpatialEvent.self) { $0.kind != .pan }
        .cancellable()
    }

    struct Value: Equatable {
        var location: CGPoint
        var timestamp: Time
        var locationInBounds: LocationInBounds
    }

    enum LocationInBounds: Hashable {
        case inside
        case insideExtended
        case outsideExtended
    }
}

// MARK: - PrimitiveButtonGestureCallbacks

private struct PrimitiveButtonGestureCallbacks: GestureCallbacks {
    var pressingAction: ButtonPressingAction?

    var pressedAction: (CGPoint?) -> Void

    typealias Value = PrimitiveButtonGestureCore.Value

    static var initialState: ButtonPressPhase { .inactive }

    func dispatch(phase: GesturePhase<Value>, state: inout ButtonPressPhase) -> (() -> Void)? {
        switch phase {
        case .possible:
            return nil
        case .active:
            let newState = pressPhase(phase)
            guard newState != state else {
                return nil
            }
            let oldState = state
            state = newState
            switch pressingAction {
            case let .withinBounds(action):
                return { action(newState) }
            case let .simple(action):
                let wasPressing = oldState == .pressingOutside || oldState == .pressingInside
                let isPressing = newState == .pressingOutside || newState == .pressingInside
                return wasPressing && isPressing ? nil : { action(isPressing) }
            case nil:
                return nil
            }
        case let .ended(value):
            let reset = cancel(state: state)
            state = .inactive
            return {
                reset?()
                pressedAction(value.location)
            }
        case .failed:
            let reset = cancel(state: state)
            state = .inactive
            return reset
        }
    }

    func cancel(state: ButtonPressPhase) -> (() -> Void)? {
        switch pressingAction {
        case let .withinBounds(action) where state == .pressingInside:
            return { action(.inactive) }
        case let .simple(action) where state == .pressingOutside || state == .pressingInside:
            return { action(false) }
        default:
            return nil
        }
    }

    func pressPhase(_ phase: GesturePhase<Value>) -> ButtonPressPhase {
        guard let value = phase.unwrapped else {
            return .inactive
        }
        switch value.locationInBounds {
        case .inside:
            return phase.isEnded ? .pressedInside : .pressingInside
        case .insideExtended:
            return .pressingInside
        case .outsideExtended:
            return .pressingOutside
        }
    }
}
