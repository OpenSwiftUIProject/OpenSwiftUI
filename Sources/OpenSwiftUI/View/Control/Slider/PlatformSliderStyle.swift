//
//  PlatformSliderStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D73865907660DC2CCEED4B77967EA955 (SwiftUI)

import OpenSwiftUICore

// MARK: - PlatformSliderCoordinator

protocol PlatformSliderCoordinator: PlatformViewCoordinator {}

// MARK: - PlatformSliderStyle

#if !canImport(Darwin)
struct PlatformSliderStyle: SliderStyle {
    func makeBody(configuration: Configuration) -> some View {
        _openSwiftUIPlatformUnimplementedWarning()
        return EmptyView()
    }
}
#endif

// MARK: - PlatformSliderStyle + SymbolEffectState

extension PlatformSliderStyle {
    struct SymbolEffectState {
        var minimumValueLabelSeed: UInt32 = 0

        var maximumValueLabelSeed: UInt32 = 0
    }
}

// MARK: - PlatformSliderStyle + ValueLabel

extension PlatformSliderStyle {
    struct ValueLabel<Base>: View where Base: View {
        let base: Base

        var body: some View {
            #if os(macOS)
            base
                .imageScale(.small)
                .symbolVariant(.fill)
                .font(.footnote)
            #else
            base
            #endif
        }
    }

    #if os(macOS)
    // MARK: - PlatformSliderStyle + InteractiveValueLabel

    struct InteractiveValueLabel<Base>: View where Base: View {
        let base: Base

        let configuration: SliderStyleConfiguration

        var body: some View {
            base.map { element in
                Button {
                    configuration.onEditingChanged(true)
                    action()
                    configuration.onEditingChanged(false)
                } label: {
                    ValueLabel(base: element.content)
                }
                .buttonStyle(.borderless)
                .buttonRepeatBehavior(.enabled)
                .environment(\.buttonRepeatTiming, .macOSStepper)
                .accessibilityIgnoreViewResponders()
                .accessibilityAddTraits(.isLabel)
            }
        }

        private func action() {
            if base is SliderStyleConfiguration.MinimumValueLabel {
                configuration.value = max(configuration.value - configuration.skipDistance, 0)
            } else if base is SliderStyleConfiguration.MaximumValueLabel {
                configuration.value = min(configuration.value + configuration.skipDistance, 1)
            }
        }
    }
    #endif
}
