//
//  ToolbarToggleStyle.swift
//  OpenSwiftUI
//
//  Audited for iOS 6.5.4
//  Status: Blocked by toolbar button modifiers and hover effects
//  ID: 49AA034263760A84A161B338D2EA7E06 (SwiftUI)

@_spi(Private)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

#if os(iOS) || os(visionOS)
struct ToolbarToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        StaticIf(idiom: .mac) {
            Toggle(configuration)
                .toggleStyle(.button)
                .buttonStyle(.bordered)
        } else: {
            StaticIf(idiom: .vision) {
                Toggle(configuration).toggleStyle(.button)
            } else: {
                makeCommonBody(configuration: configuration)
            }
        }
    }

    func makeCommonBody(configuration: Configuration) -> some View {
        ResolvedBody(configuration: configuration)
            // TODO: Apply ToolbarButtonContentModifier(isOn: configuration.isOn)
            // requiring ToolbarStyleContext.
    }

    private struct ResolvedBody: View {
        var configuration: Configuration

        @Environment(\.controlSize)
        private var controlSize: ControlSize

        @Environment(\.buttonBorderShape)
        private var buttonBorderShape: ButtonBorderShape

        var body: some View {
            Button(action: toggle) {
                label
            }
            // TODO: Apply contentShape(configuration.isOn ? [] : .hoverEffect, ToolbarButtonHoverShape())
            // and hoverEffect(configuration.isOn ? .lift : .highlight).
            // TODO: Apply ToolbarButtonEdgeOutsetModifier requiring ToolbarStyleContext.
            .allowsToolbarItemBridging(options: .item)
            // TODO: Apply PlatformItemTintModifier requiring ToolbarStyleContext.
        }

        private var label: some View {
            configuration.label
                // TODO: Apply toolbarButtonLabel(ignoreEdge: false).
                .transformEnvironment(\.defaultForegroundStyle, transform: updateForegroundStyle)
                .background(backgroundContent)
        }

        private var backgroundContent: some View {
            ResolvedBorderShape(
                controlSize: controlSize,
                base: buttonBorderShape,
                padding: .zero
            )
            .fill(_OpacityShapeStyle(style: TintShapeStyle(), opacity: configuration.isOn ? 1 : 0))
            // TODO: Apply ToolbarButtonEdgeOutsetModifier requiring ToolbarStyleContext.
        }

        private func toggle() {
            configuration.isOn.toggle()
        }

        private func updateForegroundStyle(_ style: inout AnyShapeStyle?) {
            if configuration.isOn {
                style = AnyShapeStyle(BackgroundStyle())
            }
        }
    }
}
#endif
