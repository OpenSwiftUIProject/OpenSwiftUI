//
//  GraphicsFilter.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  WIP

package enum GraphicsFilter {
    // TODO
}

package enum GraphicsBlendMode: Equatable {
    case blendMode(GraphicsContext.BlendMode)
    case caFilter(AnyObject)
    
    package init(_ mode: BlendMode) {
        let result: GraphicsContext.BlendMode = switch mode {
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
        }
        self = .blendMode(result)
    }

    package static let normal: GraphicsBlendMode = .blendMode(.normal)
    package static func == (lhs: GraphicsBlendMode, rhs: GraphicsBlendMode) -> Bool {
        switch (lhs, rhs) {
            case (.blendMode(let lhs), .blendMode(let rhs)): lhs == rhs
            case (.caFilter(let lhs), .caFilter(let rhs)): lhs === rhs
            default: false
        }
    }
}
