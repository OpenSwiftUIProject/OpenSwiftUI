//
//  ArrowStepperStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete (Blocked by CoreUIAppearanceWidget)
//  ID: 7EDEE3BC9F04CB7860AD83774DB90346 (SwiftUI)

#if os(macOS)
import AppKit
import OpenSwiftUICore

// MARK: - Coordinator

private class Coordinator: PlatformViewCoordinator {
    var configuration: StepperStyleConfiguration

    init(configuration: StepperStyleConfiguration) {
        self.configuration = configuration
        super.init()
    }

    @objc
    func valueChanged(_ stepper: NSStepper) {
        if stepper.intValue > 0 {
            Update.dispatchImmediately(reason: nil) { configuration.onIncrement?() }
        } else if stepper.intValue < 0 {
            Update.dispatchImmediately(reason: nil) { configuration.onDecrement?() }
        }
        stepper.intValue = 0
    }
}

// MARK: - EditTrackingStepper

private class EditTrackingStepper: NSStepper, AcceptsFirstMouseCustomizing {
    var onEditingChanged: ((Bool) -> Void)?

    var customAcceptsFirstMouse: Bool?

    override class var cellClass: AnyClass? {
        get { EditTrackingStepperCell.self }
        set { _openSwiftUIEmptyStub() }
    }

    override func performClick(_ sender: Any?) {
        let onEditingChanged = onEditingChanged
        onEditingChanged?(true)
        super.performClick(sender)
        onEditingChanged?(false)
    }

    override func moveUp(_ sender: Any?) {
        let onEditingChanged = onEditingChanged
        onEditingChanged?(true)
        super.moveUp(sender)
        onEditingChanged?(false)
    }

    override func moveDown(_ sender: Any?) {
        let onEditingChanged = onEditingChanged
        onEditingChanged?(true)
        super.moveDown(sender)
        onEditingChanged?(false)
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        if ResponderBasedHitTesting.isEnabled {
            customAcceptsFirstMouse ?? super.acceptsFirstMouse(for: event)
        } else {
            effectiveAcceptsFirstMouse ?? super.acceptsFirstMouse(for: event)
        }
    }
}

// MARK: - EditTrackingStepperCell

private class EditTrackingStepperCell: NSStepperCell {
    override func startTracking(at startPoint: NSPoint, in controlView: NSView) -> Bool {
        let tracking = super.startTracking(at: startPoint, in: controlView)
        if tracking {
            (self.controlView as? EditTrackingStepper)?.onEditingChanged?(true)
        }
        return tracking
    }

    override func continueTracking(last lastPoint: NSPoint, current currentPoint: NSPoint, in controlView: NSView) -> Bool {
        let tracking = super.continueTracking(last: lastPoint, current: currentPoint, in: controlView)
        if !tracking {
            (self.controlView as? EditTrackingStepper)?.onEditingChanged?(false)
        }
        return tracking
    }

    override func stopTracking(last lastPoint: NSPoint, current stopPoint: NSPoint, in controlView: NSView, mouseIsUp flag: Bool) {
        super.stopTracking(last: lastPoint, current: stopPoint, in: controlView, mouseIsUp: flag)
        (self.controlView as? EditTrackingStepper)?.onEditingChanged?(false)
    }
}

// MARK: - StepperFieldWidthKey

struct StepperFieldWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

extension EnvironmentValues {
    var stepperFieldWidth: CGFloat? {
        get { self[StepperFieldWidthKey.self] }
        set { self[StepperFieldWidthKey.self] = newValue }
    }
}

// MARK: - ArrowStepperStyle [FIXME]

struct ArrowStepperStyle: StepperStyle {
    @Environment(\.controlSize) private var controlSize

    @Environment(\.stepperFieldWidth) private var stepperFieldWidth

    func makeBody(configuration: Configuration) -> some View {
        let size: ControlSize
        switch controlSize {
        case .mini, .small: size = controlSize
        default: size = .regular
        }
        // TODO: Resolve FormStepperWidgetDefinition insets from the appearance.
        let insets = EdgeInsets()
        let field = AccessibilityLabelModifier()
            .body(content: configuration.currentValueField)
            .frame(width: stepperFieldWidth ?? 50)
        let stepper = AppKitStepper(configuration: configuration)
            .controlSize(size)
            .fixedSize()
        return LabeledContent {
            StaticIf(StyleContextAcceptsPredicate<GroupedFormStyleContext>.self) {
                ZStack(alignment: .trailing) {
                    field
                    stepper.offset(x: -insets.trailing)
                }
            } else: {
                HStack(alignment: .center, spacing: 3) {
                    field
                    stepper
                }
            }
        } label: {
            configuration.label
        }
        .accessibilityLabeledContent()
    }
}

// MARK: - FormStepperWidgetDefinition [FIXME]

// TODO: Add AppearanceWidgetDefinition and CoreUIAppearanceWidget with a layer renderer.
private struct FormStepperWidgetDefinition: Hashable {
    var controlSize: ControlSize

    var coreUIOptions: [String: Any] {
        let size: String
        switch controlSize {
        case .mini: size = "mini"
        case .small: size = "small"
        case .regular: size = "regular"
        case .large, .extraLarge: size = "large"
        }
        // Use the CoreUI constant values until the headers expose their symbols.
        return [
            "widget": "littlearrows",
            "size": size,
            "state": "normal",
            "kCUIVariantKey": "kCUIVariantForm",
        ]
    }
}

// MARK: - AppKitStepper

private struct AppKitStepper: NSViewRepresentable {
    var configuration: StepperStyleConfiguration

    @Environment(\.allowsWindowActivationEvents) private var acceptsFirstMouse

    func makeNSView(context: Context) -> EditTrackingStepper {
        let stepper = EditTrackingStepper()
        stepper.target = context.coordinator
        stepper.action = #selector(Coordinator.valueChanged(_:))
        return stepper
    }

    func updateNSView(_ nsView: EditTrackingStepper, context: Context) {
        nsView.intValue = 0
        nsView.maxValue = configuration.onIncrement == nil ? 0 : 2
        nsView.minValue = configuration.onDecrement == nil ? 0 : -2
        nsView.increment = 1
        nsView.valueWraps = false
        nsView.onEditingChanged = configuration.onEditingChanged
        context.coordinator.configuration = configuration
        nsView.customAcceptsFirstMouse = acceptsFirstMouse
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(configuration: configuration)
    }
}
#endif
