//
//  GraphicsFilter.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package import OpenCoreGraphicsShims
import OpenQuartzCoreShims
#if canImport(QuartzCore)
import QuartzCore_Private
#endif

package enum GraphicsFilter: Equatable {
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
    case shader(GraphicsFilter.ShaderFilter)
    case alphaThreshold(GraphicsFilter.AlphaThreshold)
    
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

    package struct ShaderFilter: Equatable {
        package var shader: Shader.ResolvedShader
        package var size: CGSize

        package init(shader: Shader.ResolvedShader, size: CGSize) {
            self.shader = shader
            self.size = size
        }
    }

    package struct AlphaThreshold: Equatable {
        package var color: Color.Resolved
        package var amount: Float

        package init(color: Color.Resolved, amount: Float) {
            self.color = color
            self.amount = amount
        }
    }
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
    
    @inline(__always)
    func filter(compositingGroup: Bool) -> Any? {
        switch self {
        case let .caFilter(filter):
            return filter
        case let .blendMode(mode):
            #if canImport(QuartzCore)
            return ORBBlendModeGetCompositingFilter(
                .init(rawValue: mode.rawValue),
                compositingGroup: compositingGroup
            )
            #else
            return nil
            #endif
        }
    }
}

extension GraphicsFilter {
    package var isIdentity: Bool {
        switch self {
        case let .blur(style):
            style.isIdentity
        case let .variableBlur(style):
            style.isIdentity
        case let .colorMatrix(matrix, _):
            matrix.isIdentity
        case let .colorMultiply(color):
            color.linearRed == 1 &&
                color.linearGreen == 1 &&
                color.linearBlue == 1 &&
                color.opacity == 1
        case let .hueRotation(angle):
            angle.radians == 0
        case let .saturation(amount):
            amount == 1
        case let .brightness(amount):
            amount == 0
        case let .contrast(amount):
            amount == 1
        case let .grayscale(amount):
            amount == 0
        case let .colorMonochrome(monochrome):
            monochrome.amount == 0
        case let .luminanceCurve(curve):
            curve.amount == 0
        default:
            false
        }
    }
}

// MARK: - GraphicsFilter + ProtobufMessage

extension GraphicsFilter: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        switch self {
        case let .blur(style):
            try encoder.messageField(1, style)
        case let .variableBlur(style):
            try encoder.messageField(18, style)
        case .averageColor:
            encoder.emptyField(16)
        case let .shadow(style):
            try encoder.messageField(2, style)
        case let .projection(transform):
            try encoder.messageField(3, transform)
        case let .colorMatrix(matrix, premultiplied):
            try encoder.messageField(4, matrix)
            encoder.boolField(19, premultiplied)
        case let .colorMultiply(color):
            try encoder.messageField(5, color)
        case let .hueRotation(angle):
            encoder.doubleField(6, angle.radians)
        case let .saturation(amount):
            encoder.doubleField(7, amount)
        case let .brightness(amount):
            encoder.doubleField(8, amount)
        case let .contrast(amount):
            encoder.doubleField(9, amount)
        case .luminanceToAlpha:
            encoder.emptyField(10)
        case .colorInvert:
            encoder.emptyField(11)
        case let .grayscale(amount):
            encoder.doubleField(12, amount)
        case let .colorMonochrome(monochrome):
            try encoder.messageField(13, monochrome)
        case let .vibrantColorMatrix(matrix):
            try encoder.messageField(14, matrix)
        case let .luminanceCurve(curve):
            try encoder.messageField(15, curve)
        case let .colorCurves(curves):
            try encoder.messageField(20, curves)
        case let .shader(shader):
            try encoder.messageField(17, shader)
        case let .alphaThreshold(threshold):
            try encoder.messageField(21, threshold)
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self = .colorMultiply(.white)
        var premultiplied = false
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: self = .blur(try decoder.messageField(field))
            case 2: self = .shadow(try decoder.messageField(field))
            case 3: self = .projection(try decoder.messageField(field))
            case 4: self = .colorMatrix(try decoder.messageField(field), premultiplied: false)
            case 5: self = .colorMultiply(try decoder.messageField(field))
            case 6: self = .hueRotation(.radians(try decoder.doubleField(field)))
            case 7: self = .saturation(try decoder.doubleField(field))
            case 8: self = .brightness(try decoder.doubleField(field))
            case 9: self = .contrast(try decoder.doubleField(field))
            case 10:
                try decoder.skipField(field)
                self = .luminanceToAlpha
            case 11:
                try decoder.skipField(field)
                self = .colorInvert
            case 12: self = .grayscale(try decoder.doubleField(field))
            case 13: self = .colorMonochrome(try decoder.messageField(field))
            case 14: self = .vibrantColorMatrix(try decoder.messageField(field))
            case 15: self = .luminanceCurve(try decoder.messageField(field))
            case 16:
                try decoder.skipField(field)
                self = .averageColor
            case 17: self = .shader(try decoder.messageField(field))
            case 18: self = .variableBlur(try decoder.messageField(field))
            case 19: premultiplied = try decoder.boolField(field)
            case 20: self = .colorCurves(try decoder.messageField(field))
            case 21: self = .alphaThreshold(try decoder.messageField(field))
            default: try decoder.skipField(field)
            }
            if premultiplied, case let .colorMatrix(matrix, _) = self {
                self = .colorMatrix(matrix, premultiplied: true)
            }
        }
    }
}

// MARK: - GraphicsFilter.ColorMonochrome + ProtobufMessage

extension GraphicsFilter.ColorMonochrome: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, color)
        encoder.floatField(2, amount, defaultValue: 1)
        encoder.floatField(3, bias)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init(color: .clear, amount: 1, bias: 0)
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: color = try decoder.messageField(field)
            case 2: amount = try decoder.floatField(field)
            case 3: bias = try decoder.floatField(field)
            default: try decoder.skipField(field)
            }
        }
    }
}

// MARK: - GraphicsFilter.LuminanceCurve + ProtobufMessage

extension GraphicsFilter.LuminanceCurve: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        curve.encode(to: &encoder, tag: 1)
        encoder.floatField(2, amount)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init(curve: .init((0, 0, 0, 0)), amount: 0)
        var index = 0
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: try curve.decode(from: &decoder, field: field, index: &index)
            case 2: amount = try decoder.floatField(field)
            default: try decoder.skipField(field)
            }
        }
    }
}

// MARK: - GraphicsFilter.ColorCurves + ProtobufMessage

extension GraphicsFilter.ColorCurves: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        redCurve.encode(to: &encoder, tag: 1)
        greenCurve.encode(to: &encoder, tag: 2)
        blueCurve.encode(to: &encoder, tag: 3)
        opacityCurve.encode(to: &encoder, tag: 4)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        let zero = GraphicsFilter.Curve((0, 0, 0, 0))
        self.init(redCurve: zero, greenCurve: zero, blueCurve: zero, opacityCurve: zero)
        var indices = (0, 0, 0, 0)
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: try redCurve.decode(from: &decoder, field: field, index: &indices.0)
            case 2: try greenCurve.decode(from: &decoder, field: field, index: &indices.1)
            case 3: try blueCurve.decode(from: &decoder, field: field, index: &indices.2)
            case 4: try opacityCurve.decode(from: &decoder, field: field, index: &indices.3)
            default: try decoder.skipField(field)
            }
        }
    }
}

extension GraphicsFilter.Curve {
    fileprivate func encode(to encoder: inout ProtobufEncoder, tag: UInt) {
        encoder.packedField(tag) { encoder in
            encoder.encodeFloat(values.0)
            encoder.encodeFloat(values.1)
            encoder.encodeFloat(values.2)
            encoder.encodeFloat(values.3)
        }
    }

    fileprivate mutating func decode(
        from decoder: inout ProtobufDecoder,
        field: ProtobufDecoder.Field,
        index: inout Int
    ) throws {
        let value = try decoder.floatField(field)
        switch index {
        case 0: values.0 = value
        case 1: values.1 = value
        case 2: values.2 = value
        case 3: values.3 = value
        default: return
        }
        index += 1
    }
}

// MARK: - GraphicsFilter.ShaderFilter + ProtobufMessage

extension GraphicsFilter.ShaderFilter: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, shader)
        try encoder.messageField(2, size, defaultValue: .zero)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var shader: Shader.ResolvedShader?
        var size: CGSize = .zero
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: shader = try decoder.messageField(field)
            case 2: size = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        guard let shader else {
            throw ProtobufDecoder.DecodingError.failed
        }
        self.init(shader: shader, size: size)
    }
}

// MARK: - GraphicsFilter.AlphaThreshold + ProtobufMessage

extension GraphicsFilter.AlphaThreshold: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, color)
        encoder.floatField(2, amount, defaultValue: 0.5)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init(color: .black, amount: 0.5)
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: color = try decoder.messageField(field)
            case 2: amount = try decoder.floatField(field)
            default: try decoder.skipField(field)
            }
        }
    }
}

// TODO: Remaining extension API
