//
//  SystemSliderStyle_Phone.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8AA246B2E0E916EFA5AD706DCC8A0FE8 (SwiftUI)

#if os(iOS) || os(visionOS)
import OpenSwiftUICore
import UIKit

// MARK: - PlatformSliderStyle

struct PlatformSliderStyle: SliderStyle {
    @State private var symbolEffectState = SymbolEffectState()

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            ValueLabel(base: configuration.minimumValueLabel)
                .symbolEffect(.bounce(value: symbolEffectState.minimumValueLabelSeed))
            SystemSlider(
                value: configuration.$value,
                onEditingChanged: configuration.onEditingChanged,
                symbolEffectState: $symbolEffectState
            )
            .frame(height: 31)
            .accessibilityLabel(.prefix) {
                configuration.label
            }
            ValueLabel(base: configuration.maximumValueLabel)
                .symbolEffect(.bounce(value: symbolEffectState.maximumValueLabelSeed))
        }
    }
}

// MARK: - SystemSlider

private struct SystemSlider: UIViewRepresentable {
    @Binding var value: Double

    var onEditingChanged: (Bool) -> Void

    @Binding var symbolEffectState: PlatformSliderStyle.SymbolEffectState

    @Environment(\.tintColor)
    private var controlTint: Color?

    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider()
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.editingEnded(_:)),
            for: [.touchUpInside, .touchUpOutside, .touchCancel]
        )
        return slider
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.setValue(Float(value), animated: context.transaction.animation != nil)
        if let controlTint {
            uiView.tintColor = (controlTint.resolve(in: context.environment).kitColor as! UIColor)
        }
        context.coordinator.configuration = self
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(configuration: self)
    }
}

// MARK: - Coordinator

private class Coordinator: PlatformViewCoordinator {
    var configuration: SystemSlider

    var isUpdating: Bool = false

    init(configuration: SystemSlider) {
        self.configuration = configuration
        super.init()
    }

    @objc
    func valueChanged(_ slider: UISlider) {
        let newValue = Double(slider.value)
        guard configuration.value != newValue else {
            return
        }
        if !isUpdating {
            isUpdating = true
            Update.dispatchImmediately(reason: nil) {
                configuration.onEditingChanged(true)
            }
        }
        configuration.value = newValue
        slider.value = Float(configuration.value)
        let value = configuration.value
        var symbolEffectState = configuration.symbolEffectState
        if value == 0 {
            symbolEffectState.minimumValueLabelSeed &+= 1
        } else if value == 1 {
            symbolEffectState.maximumValueLabelSeed &+= 1
        }
        configuration.symbolEffectState = symbolEffectState
    }

    @objc
    func editingEnded(_ slider: UISlider) {
        isUpdating = false
        Update.dispatchImmediately(reason: nil) {
            configuration.onEditingChanged(false)
        }
    }
}
#endif
