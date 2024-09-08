//
//  ColorResolved.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

import Foundation

extension Color {
    // MARK: - Color.Resolved
    
    @frozen
    public struct Resolved: Hashable {
        public var linearRed: Float
        public var linearGreen: Float
        public var linearBlue: Float
        public var opacity: Float
        
        package init(linearRed: Float, linearGreen: Float, linearBlue: Float, opacity: Float = 1) {
            self.linearRed = linearRed
            self.linearGreen = linearGreen
            self.linearBlue = linearBlue
            self.opacity = opacity
        }
        
        package func multiplyingOpacity(by opacity: Float) -> Color.Resolved {
            Color.Resolved(linearRed: linearRed, linearGreen: linearGreen, linearBlue: linearBlue, opacity: opacity * self.opacity)
        }
        
        package func over(_ s: Resolved) -> Color.Resolved {
            fatalError("TODO")
        }
    }
    
    package struct ResolvedVibrant: Equatable {
        package var scale: Float
        package var bias: (Float, Float, Float)
        // package var colorMatrix: _ColorMatrix { fatalError("TODO") }
        
        package static func == (lhs: ResolvedVibrant, rhs: ResolvedVibrant) -> Bool {
            lhs.scale == rhs.scale && lhs.bias == rhs.bias
        }
    }
    
    public init(_ resolved: Resolved) {
        // TODO
    }
}

// MARK: - Color.Resolved + ResolvedPaint

extension Color.Resolved/*: ResolvedPaint*/ {
    //    func draw(path: Path, style: paathDrawingStyle, in context: GraphicsContext, bounds: CGRect?)
    
    var isClear: Bool { opacity == 0 }
    var isOpaque: Bool { opacity == 1 }
    
//    static leafProtobufTag: CodableResolvedPaint.Tag?
}

extension Color.Resolved: ShapeStyle/*, PrimitiveShapeStyle*/ {
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        fatalError("TODO")
    }
    
    public typealias Resolved = Never
}

extension Color.Resolved: CustomStringConvertible {
    public var description: String {
        "TODO"
    }
}

//extension Color.Resolved : Animatable {
//  public typealias AnimatableData = AnimatablePair<Float, AnimatablePair<Float, AnimatablePair<Float, Float>>>
//  package static var legacyInterpolation: Bool
//  public var animatableData: Color.Resolved.AnimatableData {
//    get
//    set
//  }
//}
//extension Color.ResolvedVibrant : Animatable {
//  package typealias AnimatableData = AnimatablePair<Float, AnimatablePair<Float, AnimatablePair<Float, Float>>>
//  package var animatableData: Color.ResolvedVibrant.AnimatableData {
//    get
//    set
//  }
//}

extension Color.Resolved {
    package static let clear: Color.Resolved = Color.Resolved(linearRed: 0, linearGreen: 0, linearBlue: 0, opacity: 0)
    package static let black: Color.Resolved = Color.Resolved(linearRed: 0, linearGreen: 0, linearBlue: 0, opacity: 1)
    package static let gray_75: Color.Resolved = Color.Resolved(linearRed: 0.522522, linearGreen: 0.522522, linearBlue: 0.522522, opacity: 1)
    package static let gray_50: Color.Resolved = Color.Resolved(linearRed: 0.214041, linearGreen: 0.214041, linearBlue: 0.214041, opacity: 1)
    package static let gray_25: Color.Resolved = Color.Resolved(linearRed: 0.0508761, linearGreen: 0.0508761, linearBlue: 0.0508761, opacity: 1)
    package static let white: Color.Resolved = Color.Resolved(linearRed: 1, linearGreen: 1, linearBlue: 1, opacity: 1)
    package static let red: Color.Resolved = Color.Resolved(linearRed: 1, linearGreen: 0, linearBlue: 0, opacity: 1)
    package static let blue: Color.Resolved = Color.Resolved(linearRed: 0, linearGreen: 0, linearBlue: 1, opacity: 1)
    package static let green: Color.Resolved = Color.Resolved(linearRed: 0, linearGreen: 1, linearBlue: 0, opacity: 1)

    package init(red: Float, green: Float, blue: Float, opacity: Float = 1) {
        self.init(linearRed: sRGBToLinear(red), linearGreen: sRGBToLinear(green), linearBlue: sRGBToLinear(blue), opacity: opacity)
    }

    public init(colorSpace: Color.RGBColorSpace = .sRGB, red: Float, green: Float, blue: Float, opacity: Float = 1) {
        switch colorSpace {
        case .sRGB:
            self.init(red: red, green: green, blue: blue, opacity: opacity)
        case .sRGBLinear:
            self.init(linearRed: red, linearGreen: green, linearBlue: blue, opacity: opacity)
        case .displayP3:
            self.init(linearDisplayP3Red: sRGBToLinear(red), green: sRGBToLinear(green), blue: sRGBToLinear(blue), opacity: opacity)
        }
    }

    package init(linearWhite: Float, opacity: Float = 1) {
        self.init(linearRed: linearWhite, linearGreen: linearWhite, linearBlue: linearWhite, opacity: opacity)
    }

    package init(white: Float, opacity: Float = 1) {
        let linearWhite = sRGBToLinear(white)
        self.init(linearWhite: linearWhite, opacity: opacity)
    }

    package var red: Float {
        get { sRGBFromLinear(linearRed) }
        set { linearRed = sRGBToLinear(newValue) }
    }

    package var green: Float {
        get { sRGBFromLinear(linearGreen) }
        set { linearGreen = sRGBToLinear(newValue) }
    }

    package var blue: Float {
        get { sRGBFromLinear(linearBlue) }
        set { linearBlue = sRGBToLinear(newValue) }
    }

    package var white: Float {
        sRGBFromLinear(linearWhite)
    }

    package var linearWhite: Float {
        linearRed * 0.2126 + linearGreen * 0.7152 + linearBlue * 0.0722
    }
}

extension Color.Resolved {
    init(linearDisplayP3Red: Float, green: Float, blue: Float, opacity: Float = 1) {
        fatalError("TODO")
    }

    init(displayP3Red: Float, green: Float, blue: Float, opacity: Float = 1) {
        fatalError("TODO")
    }

    
//  package init(linearDisplayP3Red red: Float, green: Float, blue: Float, opacity a: Float = 1)
//  package init(displayP3Red red: Float, green: Float, blue: Float, opacity: Float = 1)
//  package var linearDisplayP3Components: (Float, Float, Float) {
//    get
//  }
//  package var displayP3Components: (Float, Float, Float) {
//    get
//  }
}

//extension Color.Resolved: Codable {
//  public func encode(to encoder: any Encoder) throws
//  public init(from decoder: any Decoder) throws
//}

//extension Color.Resolved : ProtobufMessage {
//  package func encode(to encoder: inout ProtobufEncoder)
//  package init(from decoder: inout ProtobufDecoder) throws
//}

func sRGBFromLinear(_ linear: Float) -> Float {
    let nonNegativeLinear = linear > 0 ? linear : -linear
    let result = if nonNegativeLinear <= 0.0031308 {
        nonNegativeLinear * 12.92
    } else if nonNegativeLinear == 1.0 {
        1.0
    } else {}
        pow(nonNegativeLinear, 1.0 / 2.4) * 1.055 - 0.055
    }
    return linear > 0 ? result : -result
}

func sRGBToLinear(_ sRGB: Float) -> Float {
    let nonNegativeSRGB = sRGB > 0 ? sRGB : -sRGB
    let result = if nonNegativeSRGB <= 0.04045 {
        nonNegativeSRGB * 0.0773994
    } else if nonNegativeSRGB == 1.0 {
        1.0
    } else {
        pow(nonNegativeSRGB * 0.947867 + 0.0521327, 2.4)
    }
    return sRGB > 0 ? result : -result
}
