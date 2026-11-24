//
//  DefaultStepperStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUICore

// MARK: - DefaultStepperStyle

struct DefaultStepperStyle: StepperStyle {
    func makeBody(configuration: Configuration) -> some View {
        #if canImport(Darwin)
        Stepper(configuration)
            .modifier(
                StepperStyleModifier(style: MenuStepperStyle())
                    .requiring(MenuStyleContext.self)
            )
            #if os(macOS)
            .modifier(StepperStyleModifier(style: ArrowStepperStyle()))
            #else
            .modifier(StepperStyleModifier(style: SegmentedButtonStepperStyle()))
            #endif
        #elseif UIKIT_CROSS_PLATFORM
        PortableStepper(configuration: configuration)
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return EmptyView()
        #endif
    }
}

#if UIKIT_CROSS_PLATFORM
private struct PortableStepper: View {
    let configuration: StepperStyleConfiguration

    @Environment(\.labelsVisibility) private var labelsVisibility
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        HStack {
            if labelsVisibility != .hidden {
                configuration.label
                Spacer(minLength: 8)
            }
            configuration.currentValueField
            HStack(spacing: 0) {
                button(increment: false, action: configuration.onDecrement)
                Color.gray.opacity(0.35).frame(width: 1, height: 20)
                button(increment: true, action: configuration.onIncrement)
            }
            .background { RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.16)) }
        }
    }

    private func button(increment: Bool, action: (() -> Void)?) -> some View {
        ZStack {
            Rectangle().frame(width: 14, height: 2)
            if increment { Rectangle().frame(width: 2, height: 14) }
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
        ._onButtonGesture(pressing: configuration.onEditingChanged) { action?() }
        .disabled(action == nil)
        .opacity(isEnabled && action != nil ? 1 : 0.35)
    }
}
#endif
