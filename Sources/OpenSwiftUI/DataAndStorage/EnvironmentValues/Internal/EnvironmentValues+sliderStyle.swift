//
//  EnvironmentValues+sliderStyle.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/2.
//  Lastest Version: iOS 15.5
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
