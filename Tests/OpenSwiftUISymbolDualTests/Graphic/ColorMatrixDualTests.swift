//
//  ColorMatrixDualTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
@_spi(Private) @testable import OpenSwiftUICore
import Testing

extension _ColorMatrix {
    @_silgen_name("OpenSwiftUITestStub_ColorMatrixInitIdentity")
    init(swiftUI_identity: Void)

    @_silgen_name("OpenSwiftUITestStub_ColorMatrixInitColorMatrix")
    init(swiftUI_colorMatrix matrix: ColorMatrix)

    @_silgen_name("OpenSwiftUITestStub_ColorMatrixInitRows")
    init(
        swiftUI_row1 row1: (Float, Float, Float, Float, Float),
        row2: (Float, Float, Float, Float, Float),
        row3: (Float, Float, Float, Float, Float),
        row4: (Float, Float, Float, Float, Float)
    )

    @_silgen_name("OpenSwiftUITestStub_ColorMatrixInitGraphicsFilter")
    init?(swiftUI_filter filter: GraphicsFilter, premultiplied: Bool)

    @_silgen_name("OpenSwiftUITestStub_ColorMatrixMultiply")
    static func swiftUI_multiply(_ lhs: _ColorMatrix, _ rhs: _ColorMatrix) -> _ColorMatrix

    var swiftUI_isIdentity: Bool {
        @_silgen_name("OpenSwiftUITestStub_ColorMatrixIsIdentity")
        get
    }

    @_silgen_name("OpenSwiftUITestStub_ColorMatrixInitColorMultiply")
    init(swiftUI_colorMultiply color: Color.Resolved, premultiplied: Bool)

    @_silgen_name("OpenSwiftUITestStub_ColorMatrixInitHueRotation")
    init(swiftUI_hueRotation angle: Angle)

    @_silgen_name("OpenSwiftUITestStub_ColorMatrixInitBrightness")
    init(swiftUI_brightness: Double)

    @_silgen_name("OpenSwiftUITestStub_ColorMatrixInitContrast")
    init(swiftUI_contrast: Double)

    @_silgen_name("OpenSwiftUITestStub_ColorMatrixInitLuminanceToAlpha")
    init(swiftUI_luminanceToAlpha: Void)

    @_silgen_name("OpenSwiftUITestStub_ColorMatrixInitColorInvert")
    init(swiftUI_colorInvert: Float)

    @_silgen_name("OpenSwiftUITestStub_ColorMatrixInitColorMonochrome")
    init(swiftUI_colorMonochrome color: Color.Resolved, amount: Float, bias: Float)

    @_silgen_name("OpenSwiftUITestStub_ColorMatrixInitFloatArray")
    init(swiftUI_floatArray: [Float])

    var swiftUI_floatArray: [Float] {
        @_silgen_name("OpenSwiftUITestStub_ColorMatrixFloatArray")
        get
    }
}

@Suite(.serialized)
struct ColorMatrixDualTests {
    @Test(arguments: colorMatrixFixtures)
    func identityAndColorMatrixInitializers(_ matrix: _ColorMatrix) {
        guard isSwiftUIVersionAtLeast65AndBefore70 else {
            return
        }

        let openSwiftUIIdentity = _ColorMatrix()
        let swiftUIIdentity = _ColorMatrix(swiftUI_identity: ())
        #expect(openSwiftUIIdentity == swiftUIIdentity)
        #expect(openSwiftUIIdentity.isIdentity == swiftUIIdentity.swiftUI_isIdentity)

        var colorMatrix = ColorMatrix()
        colorMatrix.r1 = matrix.m11; colorMatrix.r2 = matrix.m12; colorMatrix.r3 = matrix.m13; colorMatrix.r4 = matrix.m14; colorMatrix.r5 = matrix.m15
        colorMatrix.g1 = matrix.m21; colorMatrix.g2 = matrix.m22; colorMatrix.g3 = matrix.m23; colorMatrix.g4 = matrix.m24; colorMatrix.g5 = matrix.m25
        colorMatrix.b1 = matrix.m31; colorMatrix.b2 = matrix.m32; colorMatrix.b3 = matrix.m33; colorMatrix.b4 = matrix.m34; colorMatrix.b5 = matrix.m35
        colorMatrix.a1 = matrix.m41; colorMatrix.a2 = matrix.m42; colorMatrix.a3 = matrix.m43; colorMatrix.a4 = matrix.m44; colorMatrix.a5 = matrix.m45
        #expect(_ColorMatrix(colorMatrix) == _ColorMatrix(swiftUI_colorMatrix: colorMatrix))
        #expect(matrix.isIdentity == matrix.swiftUI_isIdentity)
    }

    @Test(arguments: colorMatrixFixtures)
    func rowInitializer(_ matrix: _ColorMatrix) {
        guard isSwiftUIVersionAtLeast65AndBefore70 else {
            return
        }

        let swiftUIValue = _ColorMatrix(
            swiftUI_row1: (matrix.m11, matrix.m12, matrix.m13, matrix.m14, matrix.m15),
            row2: (matrix.m21, matrix.m22, matrix.m23, matrix.m24, matrix.m25),
            row3: (matrix.m31, matrix.m32, matrix.m33, matrix.m34, matrix.m35),
            row4: (matrix.m41, matrix.m42, matrix.m43, matrix.m44, matrix.m45)
        )
        #expect(matrix == swiftUIValue)
    }

    @Test(arguments: colorMatrixFixtures)
    func multiplication(_ lhs: _ColorMatrix) {
        guard isSwiftUIVersionAtLeast65AndBefore70 else {
            return
        }

        let rhs = _ColorMatrix(
            row1: (0.25, -0.5, 0.75, 1, -1.25),
            row2: (1.5, 0.5, -0.25, 0.125, 2),
            row3: (-1, 0.25, 0.5, -0.75, 3),
            row4: (0.125, 0.25, 0.5, 1, -4)
        )
        #expect(lhs * rhs == _ColorMatrix.swiftUI_multiply(lhs, rhs))
    }

    @Test(arguments: ColorMatrixFixture.allCases)
    func graphicsFilterInitializer(_ fixture: ColorMatrixFixture) {
        let openSwiftUIValue = _ColorMatrix(
            fixture.filter,
            premultiplied: fixture.premultiplied
        )
        #expect((openSwiftUIValue == nil) == fixture.expectsNil)

        guard isSwiftUIVersionAtLeast65AndBefore70 else {
            return
        }
        let swiftUIValue = _ColorMatrix(
            swiftUI_filter: fixture.filter,
            premultiplied: fixture.premultiplied
        )
        #expect(openSwiftUIValue == swiftUIValue)
    }

    @Test(arguments: ColorMatrixHelperFixture.allCases)
    func helperInitializers(_ fixture: ColorMatrixHelperFixture) {
        guard isSwiftUIVersionAtLeast65AndBefore70 else {
            return
        }

        #expect(fixture.openSwiftUIValue == fixture.swiftUIValue)
    }

    @Test(arguments: colorMatrixFixtures)
    func floatArray(_ matrix: _ColorMatrix) {
        guard isSwiftUIVersionAtLeast65AndBefore70 else {
            return
        }

        let values = matrix.floatArray
        let openSwiftUIValue = _ColorMatrix(floatArray: values)
        let swiftUIValue = _ColorMatrix(swiftUI_floatArray: values)
        #expect(openSwiftUIValue == swiftUIValue)
        #expect(openSwiftUIValue.floatArray == swiftUIValue.swiftUI_floatArray)
    }
}

let colorMatrixFixtures: [_ColorMatrix] = {
    let identity = _ColorMatrix()
    var leadingValue = identity
    leadingValue.m11 = 3
    var trailingValue = identity
    trailingValue.m45 = 3
    let dense = _ColorMatrix(
        row1: (1, 2, 3, 4, 5),
        row2: (6, 7, 8, 9, 10),
        row3: (11, 12, 13, 14, 15),
        row4: (16, 17, 18, 19, 20)
    )
    return [identity, leadingValue, trailingValue, dense]
}()

enum ColorMatrixHelperFixture: String, CaseIterable, Sendable, CustomTestStringConvertible {
    case colorMultiply
    case premultipliedColorMultiply
    case hueRotation
    case brightness
    case contrast
    case luminanceToAlpha
    case colorInvertZero
    case colorInvertPartial
    case colorInvertFull
    case colorMonochrome

    var testDescription: String { rawValue }

    var openSwiftUIValue: _ColorMatrix {
        switch self {
        case .colorMultiply:
            _ColorMatrix(colorMultiply: color, premultiplied: false)
        case .premultipliedColorMultiply:
            _ColorMatrix(colorMultiply: color, premultiplied: true)
        case .hueRotation:
            _ColorMatrix(hueRotation: .degrees(37))
        case .brightness:
            _ColorMatrix(brightness: 0.25)
        case .contrast:
            _ColorMatrix(contrast: 1.5)
        case .luminanceToAlpha:
            _ColorMatrix(luminanceToAlpha: ())
        case .colorInvertZero:
            _ColorMatrix(colorInvert: 0)
        case .colorInvertPartial:
            _ColorMatrix(colorInvert: 0.25)
        case .colorInvertFull:
            _ColorMatrix(colorInvert: 1)
        case .colorMonochrome:
            _ColorMatrix(colorMonochrome: color, amount: 0.75, bias: 0.1)
        }
    }

    var swiftUIValue: _ColorMatrix {
        switch self {
        case .colorMultiply:
            _ColorMatrix(swiftUI_colorMultiply: color, premultiplied: false)
        case .premultipliedColorMultiply:
            _ColorMatrix(swiftUI_colorMultiply: color, premultiplied: true)
        case .hueRotation:
            _ColorMatrix(swiftUI_hueRotation: .degrees(37))
        case .brightness:
            _ColorMatrix(swiftUI_brightness: 0.25)
        case .contrast:
            _ColorMatrix(swiftUI_contrast: 1.5)
        case .luminanceToAlpha:
            _ColorMatrix(swiftUI_luminanceToAlpha: ())
        case .colorInvertZero:
            _ColorMatrix(swiftUI_colorInvert: 0)
        case .colorInvertPartial:
            _ColorMatrix(swiftUI_colorInvert: 0.25)
        case .colorInvertFull:
            _ColorMatrix(swiftUI_colorInvert: 1)
        case .colorMonochrome:
            _ColorMatrix(swiftUI_colorMonochrome: color, amount: 0.75, bias: 0.1)
        }
    }

    private var color: Color.Resolved {
        Color.Resolved(
            linearRed: 0.2,
            linearGreen: 0.4,
            linearBlue: 0.6,
            opacity: 0.8
        )
    }
}

enum ColorMatrixFixture: String, CaseIterable, Sendable, CustomTestStringConvertible {
    case colorMatrix
    case mismatchedColorMatrix
    case colorMultiply
    case premultipliedColorMultiply
    case hueRotation
    case premultipliedHueRotation
    case saturation
    case negativeSaturation
    case brightness
    case contrast
    case luminanceToAlpha
    case colorInvert
    case grayscale
    case colorMonochrome
    case unsupported

    var testDescription: String { rawValue }

    var premultiplied: Bool {
        switch self {
        case .mismatchedColorMatrix, .premultipliedColorMultiply, .premultipliedHueRotation:
            true
        default:
            false
        }
    }

    var expectsNil: Bool {
        switch self {
        case .mismatchedColorMatrix, .premultipliedHueRotation, .unsupported:
            true
        default:
            false
        }
    }

    var filter: GraphicsFilter {
        switch self {
        case .colorMatrix, .mismatchedColorMatrix:
            .colorMatrix(
                _ColorMatrix(
                    row1: (1, 2, 3, 4, 5),
                    row2: (6, 7, 8, 9, 10),
                    row3: (11, 12, 13, 14, 15),
                    row4: (16, 17, 18, 19, 20)
                ),
                premultiplied: false
            )
        case .colorMultiply, .premultipliedColorMultiply:
            .colorMultiply(.init(linearRed: 0.2, linearGreen: 0.4, linearBlue: 0.6, opacity: 0.8))
        case .hueRotation, .premultipliedHueRotation:
            .hueRotation(.degrees(37))
        case .saturation:
            .saturation(1.25)
        case .negativeSaturation:
            .saturation(-0.5)
        case .brightness:
            .brightness(0.25)
        case .contrast:
            .contrast(1.5)
        case .luminanceToAlpha:
            .luminanceToAlpha
        case .colorInvert:
            .colorInvert
        case .grayscale:
            .grayscale(-0.25)
        case .colorMonochrome:
            .colorMonochrome(.init(
                color: .init(linearRed: 0.2, linearGreen: 0.4, linearBlue: 0.6, opacity: 0.8),
                amount: 0.75,
                bias: 0.1
            ))
        case .unsupported:
            .averageColor
        }
    }
}

#endif
