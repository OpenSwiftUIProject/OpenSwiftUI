//
//  ColorMatrix.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Blocked by Color, GraphicsFilter and ShapeStyle
//  ID: 623CA953523AF4C256B3825254A7F058 (SwiftUICore)

#if canImport(Darwin)
import CoreGraphics
#else
import Foundation
#endif
import OpenSwiftUI_SPI

// MARK: - ColorMatrix

/// A matrix to use in an RGBA color transformation.
///
/// The matrix has five columns, each with a red, green, blue, and alpha
/// component. You can use the matrix for tasks like creating a color
/// transformation ``GraphicsContext/Filter`` for a ``GraphicsContext`` using
/// the ``GraphicsContext/Filter/colorMatrix(_:)`` method.
@frozen
public struct ColorMatrix: Equatable {
    public var r1: Float = 1, r2: Float = 0, r3: Float = 0, r4: Float = 0, r5: Float = 0
    public var g1: Float = 0, g2: Float = 1, g3: Float = 0, g4: Float = 0, g5: Float = 0
    public var b1: Float = 0, b2: Float = 0, b3: Float = 1, b4: Float = 0, b5: Float = 0
    public var a1: Float = 0, a2: Float = 0, a3: Float = 0, a4: Float = 1, a5: Float = 0
    
    /// Creates the identity matrix.
    @inlinable
    public init() {}
}

// MARK: - _ColorMatrix

@frozen
public struct _ColorMatrix: Equatable, Codable {
    public var m11: Float = 1, m12: Float = 0, m13: Float = 0, m14: Float = 0, m15: Float = 0
    public var m21: Float = 0, m22: Float = 1, m23: Float = 0, m24: Float = 0, m25: Float = 0
    public var m31: Float = 0, m32: Float = 0, m33: Float = 1, m34: Float = 0, m35: Float = 0
    public var m41: Float = 0, m42: Float = 0, m43: Float = 0, m44: Float = 1, m45: Float = 0
    
    @inline(__always)
    init(m11: Float = 1, m12: Float = 0, m13: Float = 0, m14: Float = 0, m15: Float = 0,
         m21: Float = 0, m22: Float = 1, m23: Float = 0, m24: Float = 0, m25: Float = 0,
         m31: Float = 0, m32: Float = 0, m33: Float = 1, m34: Float = 0, m35: Float = 0,
         m41: Float = 0, m42: Float = 0, m43: Float = 0, m44: Float = 1, m45: Float = 0) {
        self.m11 = m11; self.m12 = m12; self.m13 = m13; self.m14 = m14; self.m15 = m15
        self.m21 = m21; self.m22 = m22; self.m23 = m23; self.m24 = m24; self.m25 = m25
        self.m31 = m31; self.m32 = m32; self.m33 = m33; self.m34 = m34; self.m35 = m35
        self.m41 = m41; self.m42 = m42; self.m43 = m43; self.m44 = m44; self.m45 = m45
    }
    
    @inlinable
    public init() {}
    
    public init(color: Color, in environment: EnvironmentValues) {
        // Blocked by Color
        _openSwiftUIUnimplementedFailure()
    }
    
    package init(_ m: ColorMatrix) {
        m11 = m.r1; m12 = m.r2; m13 = m.r3; m14 = m.r4; m15 = m.r5
        m21 = m.g1; m22 = m.g2; m23 = m.g3; m24 = m.g4; m25 = m.g5
        m31 = m.b1; m32 = m.b2; m33 = m.b3; m34 = m.b4; m35 = m.b5
        m41 = m.a1; m42 = m.a2; m43 = m.a3; m44 = m.a4; m45 = m.a5
    }
    
    package var isIdentity: Bool {
        self == .identity
    }
    
    @inline(__always)
    static let identity = _ColorMatrix()
    
    /// The missing fifth row would be (0, 0, 0, 0, 1)
    ///
    ///     | R' |     | r1 r2 r3 r4 r5 |   | R |
    ///     | G' |     | g1 g2 g3 g4 g5 |   | G |
    ///     | B' |  =  | b1 b2 b3 b4 b5 | * | B |
    ///     | A' |     | a1 a2 a3 a4 a5 |   | A |
    ///     | 1  |     | 0  0  0  0  1  |   | 1 |
    public static func * (a: _ColorMatrix, b: _ColorMatrix) -> _ColorMatrix {
        let m11 = a.m11 * b.m11 + a.m12 * b.m21 + a.m13 * b.m31 + a.m14 * b.m41
        let m12 = a.m11 * b.m12 + a.m12 * b.m22 + a.m13 * b.m32 + a.m14 * b.m42
        let m13 = a.m11 * b.m13 + a.m12 * b.m23 + a.m13 * b.m33 + a.m14 * b.m43
        let m14 = a.m11 * b.m14 + a.m12 * b.m24 + a.m13 * b.m34 + a.m14 * b.m44
        let m15 = a.m11 * b.m15 + a.m12 * b.m25 + a.m13 * b.m35 + a.m14 * b.m45 + a.m15

        let m21 = a.m21 * b.m11 + a.m22 * b.m21 + a.m23 * b.m31 + a.m24 * b.m41
        let m22 = a.m21 * b.m12 + a.m22 * b.m22 + a.m23 * b.m32 + a.m24 * b.m42
        let m23 = a.m21 * b.m13 + a.m22 * b.m23 + a.m23 * b.m33 + a.m24 * b.m43
        let m24 = a.m21 * b.m14 + a.m22 * b.m24 + a.m23 * b.m34 + a.m24 * b.m44
        let m25 = a.m21 * b.m15 + a.m22 * b.m25 + a.m23 * b.m35 + a.m24 * b.m45 + a.m25
        
        let m31 = a.m31 * b.m11 + a.m32 * b.m21 + a.m33 * b.m31 + a.m34 * b.m41
        let m32 = a.m31 * b.m12 + a.m32 * b.m22 + a.m33 * b.m32 + a.m34 * b.m42
        let m33 = a.m31 * b.m13 + a.m32 * b.m23 + a.m33 * b.m33 + a.m34 * b.m43
        let m34 = a.m31 * b.m14 + a.m32 * b.m24 + a.m33 * b.m34 + a.m34 * b.m44
        let m35 = a.m31 * b.m15 + a.m32 * b.m25 + a.m33 * b.m35 + a.m34 * b.m45 + a.m35
        
        let m41 = a.m41 * b.m11 + a.m42 * b.m21 + a.m43 * b.m31 + a.m44 * b.m41
        let m42 = a.m41 * b.m12 + a.m42 * b.m22 + a.m43 * b.m32 + a.m44 * b.m42
        let m43 = a.m41 * b.m13 + a.m42 * b.m23 + a.m43 * b.m33 + a.m44 * b.m43
        let m44 = a.m41 * b.m14 + a.m42 * b.m24 + a.m43 * b.m34 + a.m44 * b.m44
        let m45 = a.m41 * b.m15 + a.m42 * b.m25 + a.m43 * b.m35 + a.m44 * b.m45 + a.m45
        
        return _ColorMatrix(
            row1: (m11, m12, m13, m14, m15),
            row2: (m21, m22, m23, m24, m25),
            row3: (m31, m32, m33, m34, m35),
            row4: (m41, m42, m43, m44, m45)
        )
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encodeRow((m11, m12, m13, m14, m15))
        try container.encodeRow((m21, m22, m23, m24, m25))
        try container.encodeRow((m31, m32, m33, m34, m35))
        try container.encodeRow((m41, m42, m43, m44, m45))
    }
    
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let row1 = try container.decodeRow()
        let row2 = try container.decodeRow()
        let row3 = try container.decodeRow()
        let row4 = try container.decodeRow()
        self.init(row1: row1, row2: row2, row3: row3, row4: row4)
    }
}

extension UnkeyedEncodingContainer {
    fileprivate mutating func encodeRow(_ row: (Float, Float, Float, Float, Float)) throws {
        try encode(row.0)
        try encode(row.1)
        try encode(row.2)
        try encode(row.3)
        try encode(row.4)
    }
}

extension UnkeyedDecodingContainer {
    fileprivate mutating func decodeRow() throws -> (Float, Float, Float, Float, Float) {
        let m11 = try decode(Float.self)
        let m12 = try decode(Float.self)
        let m13 = try decode(Float.self)
        let m14 = try decode(Float.self)
        let m15 = try decode(Float.self)
        return (m11, m12, m13, m14, m15)
    }
}

// MARK: - _ColorMatrix + init [TODO]

extension _ColorMatrix {
    @inline(__always)
    package init(
        row1: (Float, Float, Float, Float, Float),
        row2: (Float, Float, Float, Float, Float),
        row3: (Float, Float, Float, Float, Float),
        row4: (Float, Float, Float, Float, Float)
    ) {
        m11 = row1.0; m12 = row1.1; m13 = row1.2; m14 = row1.3; m15 = row1.4
        m21 = row2.0; m22 = row2.1; m23 = row2.2; m24 = row2.3; m25 = row2.4
        m31 = row3.0; m32 = row3.1; m33 = row3.2; m34 = row3.3; m35 = row3.4
        m41 = row4.0; m42 = row4.1; m43 = row4.2; m44 = row4.3; m45 = row4.4
    }
    
    package init?(_ filter: GraphicsFilter, premultiplied: Bool = false) {
        _openSwiftUIUnimplementedFailure()
    }
    
    package init(colorMultiply c: Color.Resolved, premultiplied: Bool = false) {
        let factor: Float = premultiplied ? c.opacity : 1.0
        let red = c.red * factor
        let green = c.green * factor
        let blue = c.blue * factor
        let alpha = c.opacity
        self.init(
            row1: (red, 0, 0, 0, 0),
            row2: (0, green, 0, 0, 0),
            row3: (0, 0, blue, 0, 0),
            row4: (0, 0, 0, alpha, 0)
        )
    }
    
    package init(hueRotation angle: Angle) {
        let cosValue = Float(cos(angle.radians))
        let sinValue = Float(sin(angle.radians))
        
        // Matrix coefficients for hue rotation
        // Based on color rotation matrix formula
        self.init(
            row1: (0.2126 + cosValue * 0.7873 - sinValue * 0.2126, 0.2126 - cosValue * 0.2126 + sinValue * 0.1430, 0.2126 - cosValue * 0.2126 - sinValue * 0.7873, 0, 0),
            row2: (0.7152 - cosValue * 0.7152 - sinValue * 0.7152, 0.7152 + cosValue * 0.2848 + sinValue * 0.1400, 0.7152 - cosValue * 0.7152 + sinValue * 0.7152, 0, 0),
            row3: (0.0722 - cosValue * 0.0722 + sinValue * 0.9278, 0.0722 - cosValue * 0.0722 - sinValue * 0.2830, 0.0722 + cosValue * 0.9278 + sinValue * 0.0722, 0, 0),
            row4: (0, 0, 0, 1, 0)
        )
    }
    
    package init(brightness: Double) {
        let b = Float(brightness)
        self.init(
            row1: (1, 0, 0, 0, b),
            row2: (0, 1, 0, 0, b),
            row3: (0, 0, 1, 0, b),
            row4: (0, 0, 0, 1, 0)
        )
    }
    
    package init(contrast: Double) {
        let c = Float(contrast)
        let t = (1.0 - c) / 2.0
        self.init(
            row1: (c, 0, 0, 0, t),
            row2: (0, c, 0, 0, t),
            row3: (0, 0, c, 0, t),
            row4: (0, 0, 0, 1, 0)
        )
    }
    
    package init(luminanceToAlpha: Void) {
        // Using standard luminance coefficients (Rec. 709)
        self.init(
            row1: (0, 0, 0, 0, 0),
            row2: (0, 0, 0, 0, 0),
            row3: (0, 0, 0, 0, 0),
            row4: (0.2126, 0.7152, 0.0722, 0, 0) // Luminance coefficients in alpha channel
        )
    }
    
    package init(colorInvert x: Float) {
        self.init(
            row1: (-1, 0, 0, 0, x),
            row2: (0, -1, 0, 0, x),
            row3: (0, 0, -1, 0, x),
            row4: (0, 0, 0, 1, 0)
        )
    }
    
    package init(colorMonochrome c: Color.Resolved, amount: Float = 1, bias: Float = 0) {
        let red = c.red
        let green = c.green
        let blue = c.blue
        let opacity = c.opacity
        
        // Standard luminance coefficients (Rec. 709)
        let lumR: Float = 0.2126
        let lumG: Float = 0.7152
        let lumB: Float = 0.0722
        
        // Calculate the inverse of amount for blending
        let invAmount = 1.0 - amount
        
        self.init(
            row1: (red * lumR * amount + invAmount, red * lumG * amount, red * lumB * amount, 0, red * amount * bias),
            row2: (green * lumR * amount, green * lumG * amount + invAmount, green * lumB * amount, 0, green * amount * bias),
            row3: (blue * lumR * amount, blue * lumG * amount, blue * lumB * amount + invAmount, 0, blue * amount * bias),
            row4: (0, 0, 0, opacity * amount + invAmount, 0)
        )
    }
    
    package init(floatArray: [Float]) {
        m11 = floatArray[0]; m12 = floatArray[1]; m13 = floatArray[2]; m14 = floatArray[3]; m15 = floatArray[4]
        m21 = floatArray[5]; m22 = floatArray[6]; m23 = floatArray[7]; m24 = floatArray[8]; m25 = floatArray[9]
        m31 = floatArray[10]; m32 = floatArray[11]; m33 = floatArray[12]; m34 = floatArray[13]; m35 = floatArray[14]
        m41 = floatArray[15]; m42 = floatArray[16]; m43 = floatArray[17]; m44 = floatArray[18]; m45 = floatArray[19]
    }
    
    package var floatArray: [Float] {
        [
            m11, m12, m13, m14, m15,
            m21, m22, m23, m24, m25,
            m31, m32, m33, m34, m35,
            m41, m42, m43, m44, m45
        ]
    }
}

// MARK: - _ColorMatrix + ShapeStyle [TODO]

@_spi(Private)
extension _ColorMatrix: ShapeStyle {
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        // TODO
    }
    
    public typealias Resolved = Never
}

// MARK: - _ColorMatrix + ProtobufMessage

extension _ColorMatrix: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) {
        withUnsafePointer(to: self) { pointer in
            let pointer = UnsafeRawPointer(pointer).assumingMemoryBound(to: Float.self)
            let bufferPointer = UnsafeBufferPointer(start: pointer, count: 20)
            for index: UInt in 1 ... 6 {
                encoder.floatField(
                    index,
                    bufferPointer[Int(index &- 1)],
                    defaultValue: (index == 1 || index == 7 || index == 13 || index == 19) ? 1 : 0
                )
            }
        }
    }
    
    package init(from decoder: inout ProtobufDecoder) throws {
        var matrix = _ColorMatrix()
        try withUnsafeMutablePointer(to: &matrix) { pointer in
            let pointer = UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: Float.self)
            let bufferPointer = UnsafeMutableBufferPointer(start: pointer, count: 20)
            while let field = try decoder.nextField() {
                let tag = field.tag
                switch tag {
                    case 1...6: bufferPointer[Int(tag &- 1)] = try decoder.floatField(field)
                    default: try decoder.skipField(field)
                }
            }
        }
        self = matrix
        
    }
}

// MARK: - _ColorMatrix + Calculations

extension _ColorMatrix {
    mutating func add(_ other: _ColorMatrix) {
        m11 += other.m11; m12 += other.m12; m13 += other.m13; m14 += other.m14; m15 += other.m15
        m21 += other.m21; m22 += other.m22; m23 += other.m23; m24 += other.m24; m25 += other.m25
        m31 += other.m31; m32 += other.m32; m33 += other.m33; m34 += other.m34; m35 += other.m35
        m41 += other.m41; m42 += other.m42; m43 += other.m43; m44 += other.m44; m45 += other.m45
    }
    
    mutating func subtract(_ other: _ColorMatrix) {
        m11 -= other.m11; m12 -= other.m12; m13 -= other.m13; m14 -= other.m14; m15 -= other.m15
        m21 -= other.m21; m22 -= other.m22; m23 -= other.m23; m24 -= other.m24; m25 -= other.m25
        m31 -= other.m31; m32 -= other.m32; m33 -= other.m33; m34 -= other.m34; m35 -= other.m35
        m41 -= other.m41; m42 -= other.m42; m43 -= other.m43; m44 -= other.m44; m45 -= other.m45
    }
    
    mutating func negate() {
        m11 = -m11; m12 = -m12; m13 = -m13; m14 = -m14; m15 = -m15
        m21 = -m21; m22 = -m22; m23 = -m23; m24 = -m24; m25 = -m25
        m31 = -m31; m32 = -m32; m33 = -m33; m34 = -m34; m35 = -m35
        m41 = -m41; m42 = -m42; m43 = -m43; m44 = -m44; m45 = -m45
    }
    
    mutating func scale(by scalar: Double) {
        let scalar = Float(scalar)
        m11 *= scalar; m12 *= scalar; m13 *= scalar; m14 *= scalar; m15 *= scalar
        m21 *= scalar; m22 *= scalar; m23 *= scalar; m24 *= scalar; m25 *= scalar
        m31 *= scalar; m32 *= scalar; m33 *= scalar; m34 *= scalar; m35 *= scalar
        m41 *= scalar; m42 *= scalar; m43 *= scalar; m44 *= scalar; m45 *= scalar
    }
    
    var magnitudeSquared: Double {
        floatArray.reduce(0.0) { $0 + Double($1 * $1) }
    }
}

#if canImport(Darwin)
extension _ColorMatrix {
    @inline(__always)
    var caColorMatrix: CAColorMatrix {
        CAColorMatrix(
            m11: m11, m12: m12, m13: m13, m14: m14, m15: m15,
            m21: m21, m22: m22, m23: m23, m24: m24, m25: m25,
            m31: m31, m32: m32, m33: m33, m34: m34, m35: m35,
            m41: m41, m42: m42, m43: m43, m44: m44, m45: m45
        )
    }
}
#endif
