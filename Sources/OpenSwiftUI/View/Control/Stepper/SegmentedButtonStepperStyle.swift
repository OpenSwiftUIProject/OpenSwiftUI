//
//  SegmentedButtonStepperStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: F1E9485F33A623EEFA647AA5EC4AE094 (SwiftUI)

#if os(iOS) || os(visionOS)
import OpenSwiftUICore
import UIKit

// MARK: - Coordinator

private class Coordinator: PlatformViewCoordinator {
    var configuration: StepperStyleConfiguration

    init(configuration: StepperStyleConfiguration) {
        self.configuration = configuration
        super.init()
    }

    @objc
    func valueChanged(_ stepper: UIStepper) {
        if stepper.value > 0, let onIncrement = configuration.onIncrement {
            Update.dispatchImmediately(reason: nil) { onIncrement() }
        } else if stepper.value < 0, let onDecrement = configuration.onDecrement {
            Update.dispatchImmediately(reason: nil) { onDecrement() }
        }
        stepper.value = 0
    }

    @objc
    func editingBegan(_ stepper: UIStepper) {
        Update.dispatchImmediately(reason: nil) { configuration.onEditingChanged(true) }
    }

    @objc
    func editingEnded(_ stepper: UIStepper) {
        Update.dispatchImmediately(reason: nil) { configuration.onEditingChanged(false) }
    }
}

// MARK: - SegmentedButtonStepperStyle

struct SegmentedButtonStepperStyle: StepperStyle {
    func makeBody(configuration: Configuration) -> some View {
        LabeledContent {
            UIKitStepper(configuration: configuration)
                .fixedSize()
        } label: {
            configuration.label
        }
        .listLabeledContentPrefersHorizontalLayout()
        .accessibilityLabeledContent()
    }
}

// MARK: - UIKitStepper

private struct UIKitStepper: UIViewRepresentable {
    var configuration: StepperStyleConfiguration

    func makeUIView(context: Context) -> UIStepper {
        let stepper = UIStepper()
        stepper.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        stepper.addTarget(context.coordinator, action: #selector(Coordinator.editingBegan(_:)), for: .touchDown)
        stepper.addTarget(context.coordinator, action: #selector(Coordinator.editingEnded(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return stepper
    }

    func updateUIView(_ uiView: UIStepper, context: Context) {
        uiView.value = 0
        uiView.minimumValue = configuration.onDecrement == nil ? 0 : -2
        uiView.maximumValue = configuration.onIncrement == nil ? 0 : 2
        uiView.stepValue = 1
        context.coordinator.configuration = configuration
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(configuration: configuration)
    }
}
#endif
