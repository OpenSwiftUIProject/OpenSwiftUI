//
//  GraphicsFilter.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  WIP

package enum GraphicsFilter {
    case blur(BlurStyle)
    case variableBlur(VariableBlurStyle)
    case averageColor
    case shadow(ResolvedShadowStyle)
    case projection(ProjectionTransform)
    case colorMatrix(_ColorMatrix, premultiplied: Bool)
    case colorMultiply(Color.Resolved)
    case hueRotation(Angle)
    case saturation(Double)
    case brightness(Double)
    case contrast(Double)
    case luminanceToAlpha
    case colorInvert
    case grayscale(Double)
    case colorMonochrome(GraphicsFilter.ColorMonochrome)
    case vibrantColorMatrix(_ColorMatrix)
    case luminanceCurve(GraphicsFilter.LuminanceCurve)
    case colorCurves(GraphicsFilter.ColorCurves)
    // case shader(GraphicsFilter.ShaderFilter)
    
    package struct ColorMonochrome: Equatable {
        package var color: Color.Resolved
        package var amount: Float
        package var bias: Float
        
        package init(color: Color.Resolved, amount: Float, bias: Float) {
            self.color = color
            self.amount = amount
            self.bias = bias
        }
    }

    package struct Curve: Equatable {
        package var values: (Float, Float, Float, Float)
        
        package init(_ values: (Float, Float, Float, Float)) {
            self.values = values
        }
        package static func == (lhs: GraphicsFilter.Curve, rhs: GraphicsFilter.Curve) -> Bool {
            lhs.values == rhs.values
        }
    }

    package struct LuminanceCurve: Equatable {
        package var curve: GraphicsFilter.Curve
        package var amount: Float
        
        package init(curve: GraphicsFilter.Curve, amount: Float) {
            self.curve = curve
            self.amount = amount
        }
    }

    package struct ColorCurves: Equatable {
        package var redCurve: GraphicsFilter.Curve
        package var greenCurve: GraphicsFilter.Curve
        package var blueCurve: GraphicsFilter.Curve
        package var opacityCurve: GraphicsFilter.Curve
        
        package init(redCurve: GraphicsFilter.Curve, greenCurve: GraphicsFilter.Curve, blueCurve: GraphicsFilter.Curve, opacityCurve: GraphicsFilter.Curve) {
            self.redCurve = redCurve
            self.greenCurve = greenCurve
            self.blueCurve = blueCurve
            self.opacityCurve = opacityCurve
        }
    }

//    package struct ShaderFilter {
//        package var shader: Shader.ResolvedShader
//        package var size: CGSize
//        
//        package init(shader: Shader.ResolvedShader, size: CGSize) {
//            self.shader = shader
//            self.size = size
//        }
//    }
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
