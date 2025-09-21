//
//  Toggle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import OpenSwiftUICore

// MARK: - Toggle [WIP]

@available(OpenSwiftUI_v1_0, *)
public struct Toggle<Label>: View where Label: View {
    @Binding var toggleState: ToggleState

    var label: Label

    // var appIntentAction: AppIntentAction?

    public init(
        isOn: Binding<Bool>,
        @ViewBuilder label: () -> Label
    ) {
        self.init(toggledOn: [isOn], label: label)
    }

    @_spi(_)
    @available(OpenSwiftUI_v4_0, *)
    @available(*, deprecated, message: "Use Toggle.init(sources:isOn:label:).")
    public init<C>(
        isOn: C,
        @ViewBuilder label: () -> Label
    ) where C: RandomAccessCollection, C.Element == Binding<Bool> {
        self.init(toggledOn: isOn, label: label)
    }

    @available(OpenSwiftUI_v3_0, *)
    public init<C>(
        sources: C,
        isOn: KeyPath<C.Element, Binding<Bool>>,
        @ViewBuilder label: () -> Label
    ) where C: RandomAccessCollection {
        self.init(toggledOn: sources.lazy.map { $0[keyPath: isOn] }, label: label)
    }

    init<C>(
        toggledOn: C,
        @ViewBuilder label: () -> Label
    ) where C: Collection, C.Element == Binding<Bool> {
        self.label = label()
        _toggleState = Binding(get: {
            ToggleState.stateFor(item: true, in: toggledOn)
        }, set: { value in
            for binding in toggledOn {
                binding.wrappedValue = (value == .on)
            }
        })
    }

    public var body: some View {
        // FIXME
        ResolvedToggleStyle(
            configuration: ToggleStyleConfiguration(
                label: .init(),
                isOn: $toggleState.projecting(ToggleStateBool()),
                toggleState: $toggleState,
                isMixed: false,
                effect: .binding // FIXME
            )
        ).viewAlias(ToggleStyleConfiguration.Label.self) {
            label
        }
    }
}

@available(*, unavailable)
extension Toggle: Sendable {}

// TODO: Toggle + Extension
