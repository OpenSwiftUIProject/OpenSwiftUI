//
//  RGBColorSpace.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

extension Color {
    public enum RGBColorSpace: Sendable {
        case sRGB
        case sRGBLinear
        case displayP3
    }

//    public init(_ colorSpace: RGBColorSpace = .sRGB, red: Double, green: Double, blue: Double, opacity: Double = 1) {
//        // self.init(red: red, green: green, blue: blue, opacity: opacity)
//    }
//
//    public init(_ colorSpace: RGBColorSpace = .sRGB, white: Double, opacity: Double = 1) {
//    }
//
//    public init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
//
//    }
}

package func HSBToRGB(hue: Double, saturation: Double, brightness: Double) -> (red: Double, green: Double, blue: Double) {
    preconditionFailure("TODO")
}
