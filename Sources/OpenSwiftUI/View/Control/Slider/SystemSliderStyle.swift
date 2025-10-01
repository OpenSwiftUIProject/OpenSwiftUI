//
//  SystemSliderStyle.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: WIP
//  ID: 8AA246B2E0E916EFA5AD706DCC8A0FE8

// TODO
private struct SystemSliderStyle: SliderStyle {
    func body(configuration: Slider<SliderStyleLabel, SliderStyleValueLabel>) -> some View {
        EmptyView()
    }
}

extension AnySliderStyle {
    static let `default` = AnySliderStyle(style: SystemSliderStyle())
}
