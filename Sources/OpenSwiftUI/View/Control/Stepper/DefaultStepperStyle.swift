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
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return EmptyView()
        #endif
    }
}
