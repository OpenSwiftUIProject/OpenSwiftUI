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
        #elseif os(WASI)
        WASIStepperBody(configuration: configuration)
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return EmptyView()
        #endif
    }
}

#if os(WASI)
private struct WASIStepperBody: View {
    @Environment(\.labelsVisibility) private var labelsVisibility

    let configuration: StepperStyleConfiguration

    var body: some View {
        HStack(spacing: 12) {
            if labelsVisibility != .hidden {
                configuration.label
                Spacer(minLength: 0)
            }

            HStack(spacing: 0) {
                segment("−", action: configuration.onDecrement)
                Color.gray.opacity(0.45)
                    .frame(width: 1, height: 18)
                segment("+", action: configuration.onIncrement)
            }
            .background {
                Capsule(style: .circular)
                    .fill(Color.gray.opacity(0.22))
                    .frame(height: 32)
            }
        }
    }

    private func segment(_ title: String, action: (() -> Void)?) -> some View {
        Button {
            // Canvas buttons commit a single step on activation.
            guard let action else { return }
            configuration.onEditingChanged(true)
            action()
            configuration.onEditingChanged(false)
        } label: {
            Text(verbatim: title)
                .font(.system(size: 19, weight: .semibold))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}
#endif
