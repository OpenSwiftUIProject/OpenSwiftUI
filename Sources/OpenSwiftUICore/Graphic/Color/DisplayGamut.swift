//
//  DisplayGamut.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

#if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
import CoreUI_Private
import CoreUI
#endif

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

    #if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
    @inline(__always)
    var cuiDisplayGamut: CUIDisplayGamut {
        switch self {
        case .sRGB: .SRGB
        case .displayP3: .P3
        }
    }
    #endif
}

@available(*, unavailable)
extension DisplayGamut: Sendable {}

extension DisplayGamut: ProtobufEnum {}
