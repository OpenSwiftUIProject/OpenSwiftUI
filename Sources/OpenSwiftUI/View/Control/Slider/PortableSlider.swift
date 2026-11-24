//
//  PortableSlider.swift
//  OpenSwiftUI

#if UIKIT_CROSS_PLATFORM
import Foundation
import OpenSwiftUICore

struct PortableSlider: View {
    let configuration: SliderStyleConfiguration
    @Environment(\.tintColor) private var tint
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.layoutDirection) private var direction
    @State private var editing = false

    var body: some View {
        HStack(spacing: 8) {
            if configuration.hasCustomMinMaxValueLabels { configuration.minimumValueLabel }
            GeometryReader { geometry in
                let width = geometry.size.width
                let radius = min(10, width / 2)
                let travel = max(0, width - 2 * radius)
                let value = configuration.value
                let fraction = value.isFinite ? min(1, max(0, value)) : 0
                let active = travel * CGFloat(fraction)
                let accent = tint ?? Color.accentColor
                ZStack {
                    Capsule().fill(Color.gray.opacity(0.35))
                        .frame(width: travel, height: 4)
                    Capsule().fill(accent)
                        .frame(width: active, height: 4)
                        .frame(width: travel, alignment: .leading)
                    Circle().fill(accent)
                        .frame(width: 2 * radius, height: 2 * radius)
                        .frame(width: 2 * radius + active, alignment: .trailing)
                        .frame(width: width, alignment: .leading)
                }
                .frame(width: width, height: 44)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { event in
                        guard isEnabled, travel > 0 else { return }
                        if !editing {
                            editing = true
                            configuration.onEditingChanged(true)
                        }
                        update(x: event.location.x, radius: radius, travel: travel)
                    }
                    .onEnded { event in
                        if isEnabled, travel > 0 {
                            update(x: event.location.x, radius: radius, travel: travel)
                        }
                        endEditing()
                    }
                    .onFailed { endEditing() })
            }
            .frame(height: 44)
            if configuration.hasCustomMinMaxValueLabels { configuration.maximumValueLabel }
        }
        .opacity(isEnabled ? 1 : 0.35)
        .onDisappear { endEditing() }
    }

    private func update(x: CGFloat, radius: CGFloat, travel: CGFloat) {
        let physical = Double(min(1, max(0, (x - radius) / travel)))
        configuration.value = direction == .rightToLeft ? 1 - physical : physical
    }

    private func endEditing() {
        guard editing else { return }
        editing = false
        configuration.onEditingChanged(false)
    }
}
#endif
