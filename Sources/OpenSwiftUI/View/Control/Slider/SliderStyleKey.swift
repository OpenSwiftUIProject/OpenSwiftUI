//
//  SliderStyleKey.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete
//  ID: F0F8A8741F68A968D995328632123C18

private struct SliderStyleKey: EnvironmentKey {
    static let defaultValue = AnySliderStyle.default
}

extension EnvironmentValues {
    @inline(__always)
    var sliderStyle: AnySliderStyle {
        get { self[SliderStyleKey.self] }
        set { self[SliderStyleKey.self] = newValue }
    }
}
