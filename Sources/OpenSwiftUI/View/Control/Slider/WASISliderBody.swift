//
//  WASISliderBody.swift
//  OpenSwiftUI
//

#if os(WASI)
import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
struct WASISliderBody: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.labelsVisibility) private var labelsVisibility
    @Environment(\.tintColor) private var tint
    let configuration: SliderStyleConfiguration

    nonisolated init(configuration: SliderStyleConfiguration) {
        self.configuration = configuration
    }

    var body: some View {
        let fraction = configuration.value
        return VStack(alignment: .leading, spacing: 4) {
            if labelsVisibility != .hidden {
                configuration.label
            }
            HStack(spacing: 8) {
                if configuration.hasCustomMinMaxValueLabels {
                    configuration.minimumValueLabel
                }
                GeometryReader { geometry in
                    track(size: geometry.size, fraction: fraction)
                }
                .frame(idealWidth: 180)
                .frame(height: 28)
                .opacity(isEnabled ? 1 : 0.5)
                if configuration.hasCustomMinMaxValueLabels {
                    configuration.maximumValueLabel
                }
            }
        }
    }

    private func track(size: CGSize, fraction: Double) -> some View {
        let width = size.width.isFinite ? max(size.width, 0) : 0
        let thumbWidth = min(width, 18)
        let radius = thumbWidth / 2
        let travel = width - thumbWidth
        let fill = CGFloat(fraction.isFinite ? fraction.clamped(to: 0...1) : 0) * travel
        let centerY = size.height / 2

        return ZStack {
            Capsule(style: .circular)
                .fill(Color.gray.opacity(0.45))
                .frame(width: travel, height: 6)
            Capsule(style: .circular)
                .fill(tint ?? .accentColor)
                .frame(width: fill, height: 6)
                .position(x: radius + fill / 2, y: centerY)
            Circle()
                .fill(Color.white)
                .frame(width: thumbWidth, height: thumbWidth)
                .position(x: radius + fill, y: centerY)
        }
        .frame(width: width, height: size.height)
        .contentShape(Rectangle())
        .gesture(
            EventListener<SpatialEvent>()
                .eventFilter(forType: MouseEvent.self) { $0.button == .primary }
                .eventFilter(forType: SpatialEvent.self) { $0.kind != .pan }
                .callbacks(WASISliderCallbacks(
                    value: configuration.$value,
                    onEditingChanged: configuration.onEditingChanged,
                    width: width,
                    thumbRadius: radius,
                    isRightToLeft: layoutDirection == .rightToLeft
                ))
        )
    }
}

private struct WASISliderCallbacks: GestureCallbacks {
    typealias StateType = Bool
    typealias Value = SpatialEvent
    static let initialState = false

    // Slider's existing binding projects the unit interval into its range and snaps steps.
    let value: Binding<Double>
    let onEditingChanged: (Bool) -> Void
    let width: CGFloat
    let thumbRadius: CGFloat
    let isRightToLeft: Bool

    func dispatch(phase: GesturePhase<SpatialEvent>, state editing: inout Bool) -> (() -> Void)? {
        switch phase {
        case .possible:
            return nil
        case let .active(event):
            guard let fraction = fraction(at: event.location.x) else { return nil }
            let beganEditing = !editing
            editing = true
            return {
                if beganEditing { onEditingChanged(true) }
                value.wrappedValue = fraction
            }
        case let .ended(event):
            guard editing else { return nil }
            editing = false
            let fraction = fraction(at: event.location.x)
            return {
                if let fraction { value.wrappedValue = fraction }
                onEditingChanged(false)
            }
        case .failed:
            let action = cancel(state: editing)
            editing = false
            return action
        }
    }

    func cancel(state editing: Bool) -> (() -> Void)? {
        editing ? { onEditingChanged(false) } : nil
    }

    private func fraction(at x: CGFloat) -> Double? {
        let travel = width - 2 * thumbRadius
        guard travel > 0, x.isFinite else { return nil }
        let position = isRightToLeft ? width - x : x
        return Double((position - thumbRadius) / travel).clamped(to: 0...1)
    }
}
#endif
