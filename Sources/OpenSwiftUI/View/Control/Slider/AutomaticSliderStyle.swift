//
//  AutomaticSliderStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - SliderStyle + Automatic

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension SliderStyle where Self == AutomaticSliderStyle {
    @MainActor
    @preconcurrency
    public static var automatic: AutomaticSliderStyle {
        AutomaticSliderStyle()
    }
}

// MARK: - AutomaticSliderStyle

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@MainActor
@preconcurrency
public struct AutomaticSliderStyle: SliderStyle {
    public func makeBody(configuration: Configuration) -> some View {
        #if os(iOS) || os(visionOS)
        Slider(configuration)
            .modifier(
                SliderStyleModifier(style: MenuSliderStyle())
                    .requiring(MenuStyleContext.self)
            )
            .sliderStyle(PlatformSliderStyle())
        #elseif os(macOS)
        Slider(configuration)
            .modifier(
                SliderStyleModifier(style: MenuSliderStyle())
                    .requiring(MenuStyleContext.self)
            )
            .sliderStyle(PlatformSliderStyle(isVertical: false, showTickMarks: false))
            .modifier(ToolbarStyleContextModifier().requiring(ToolbarStyleContext.self))
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}

@_spi(Private)
@available(*, unavailable)
extension AutomaticSliderStyle: Sendable {}
