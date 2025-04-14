//
//  DisplayGamut.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

import OpenSwiftUI_SPI

@_spi(Private)
public enum DisplayGamut: Int {
    case sRGB
    case displayP3

    package static var deviceDefault: DisplayGamut {
        #if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
        switch _CUIDefaultDisplayGamut() {
        case .SRGB: .sRGB
        case .P3: .displayP3
        }
        #else
        return .sRGB
        #endif
    }
}

@available(*, unavailable)
extension DisplayGamut: Sendable {}

extension DisplayGamut: ProtobufEnum {}
