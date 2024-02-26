//
//  EnvironmentValues+sliderStyle.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

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
