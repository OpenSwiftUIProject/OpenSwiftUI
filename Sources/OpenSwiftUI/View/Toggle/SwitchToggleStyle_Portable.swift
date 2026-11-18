//
//  SwitchToggleStyle_Portable.swift
//  OpenSwiftUI

#if UIKIT_CROSS_PLATFORM
import OpenSwiftUICore

struct PortableSwitch: View {
    var configuration: ToggleStyleConfiguration
    var tint: Color?

    @Environment(\.labelsVisibility)
    private var labelsVisibility: Visibility

    var body: some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                if labelsVisibility != .hidden {
                    configuration.label
                    Spacer(minLength: 8)
                }
                ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                    (configuration.isOn ? tint ?? Color.green : Color.gray)
                        .frame(width: 52, height: 32)
                        .cornerRadius(16)
                    Color.white
                        .frame(width: 28, height: 28)
                        .cornerRadius(14)
                        .padding(2)
                }
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
#endif
