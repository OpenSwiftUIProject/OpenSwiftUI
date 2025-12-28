//
//  CGBlendModeUtil.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if canImport(CoreGraphics)
package import CoreGraphics

extension BlendMode {
    package init(_ blendMode: CGBlendMode) {
        self = switch blendMode {
            case .normal: .normal
            case .multiply: .multiply
            case .screen: .screen
            case .overlay: .overlay
            case .darken: .darken
            case .lighten: .lighten
            case .colorDodge: .colorDodge
            case .colorBurn: .colorBurn
            case .softLight: .softLight
            case .hardLight: .hardLight
            case .difference: .difference
            case .exclusion: .exclusion
            case .hue: .hue
            case .saturation: .saturation
            case .color: .color
            case .luminosity: .luminosity
            case .sourceAtop: .sourceAtop
            case .destinationOver: .destinationOver
            case .destinationOut: .destinationOut
            case .plusDarker: .plusDarker
            case .plusLighter: .plusLighter
            default: .normal
        }
    }
}
#endif
