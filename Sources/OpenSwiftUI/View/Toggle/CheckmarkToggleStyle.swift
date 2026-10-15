//
//  CheckmarkToggleStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 0D71D79B593BD66882F340D7E3A48052 (SwiftUI)

import Foundation
@_spi(Private) @_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

struct CheckmarkToggleStyle: ToggleStyle {
    @Environment(\.isEnabled)
    private var isEnabled: Bool

    #if os(iOS) || os(visionOS)
    @Environment(\.sizeCategory)
    private var sizeCategory: ContentSizeCategory

    @Environment(\.listRowInsets)
    private var listRowInsets: EdgeInsets

    @ScaledMetric
    private var checkmarkWidth: CGFloat = 24
    #endif

    func makeBody(configuration: Configuration) -> some View {
        StaticIf(in: .menu) {
            menuContent(configuration: configuration)
        } else: {
            #if os(macOS)
            Toggle(configuration).toggleStyle(.checkbox)
            #elseif os(iOS) || os(visionOS)
            defaultContent(configuration: configuration)
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
        }
        .buttonStyle(.automatic)
    }

    private func menuContent(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
        }
    }

    #if os(iOS) || os(visionOS)
    private func defaultContent(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
                    .foregroundColor(isEnabled ? nil : .tertiary)
                Spacer(minLength: 16)
                    .layoutPriority(-1)
                Image(systemName: "checkmark")
                    .imageScale(sizeCategory >= .accessibilityExtraLarge ? .small : .medium)
                    .font(.system(.emphasizedBody))
                    .foregroundColor(.accentColor)
                    .frame(width: adjustedCheckmarkWidth)
                    .modifier(
                        _SymbolEffectModifier(effect: .hidden(!configuration.isOn))
                            .requiring(CheckmarkAnimationPredicate.self)
                    )
                    .modifier(OpacityRendererEffect(isHidden: !configuration.isOn))
                    .accessibilityDisabled()
            }
            .defaultForegroundColor(.primary)
        }
    }

    private var adjustedCheckmarkWidth: CGFloat {
        switch sizeCategory {
        case .accessibilityMedium: checkmarkWidth - 5
        case .accessibilityLarge: checkmarkWidth - 5.5
        case .accessibilityExtraLarge: checkmarkWidth - 14
        case .accessibilityExtraExtraLarge: checkmarkWidth - 16
        case .accessibilityExtraExtraExtraLarge: checkmarkWidth - 16.5
        default: checkmarkWidth
        }
    }
    #endif
}

#if os(iOS) || os(visionOS)
// MARK: - CheckmarkAnimationPredicate

private struct CheckmarkAnimationPredicate: ViewInputPredicate {
    static func evaluate(inputs: _GraphInputs) -> Bool {
        guard inputs.interfaceIdiom.accepts(.phone) || inputs.interfaceIdiom.accepts(.pad) else {
            return false
        }
        return inputs.accepts(AnyListStyleContext()) || inputs.accepts(AnyFormStyleContext())
    }
}
#endif
