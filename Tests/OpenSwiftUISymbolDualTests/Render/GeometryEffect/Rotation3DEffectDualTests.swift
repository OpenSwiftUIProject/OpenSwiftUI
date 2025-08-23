//
//  Rotation3DEffectDualTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
import Foundation
import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

extension _Rotation3DEffect.Data {
    @_silgen_name("OpenSwiftUITestStub__Rotation3DEffectDataInit")
    init(swiftUI: Void)

    @_silgen_name("OpenSwiftUITestStub__Rotation3DEffectDataInitEffect")
    init(swiftUI_effect: _Rotation3DEffect, size: CGSize, layoutDirection: LayoutDirection = .leftToRight)

    var swiftui_transform: ProjectionTransform {
        @_silgen_name("OpenSwiftUITestStub__Rotation3DEffectDataTransform")
        get
    }
}

extension _Rotation3DEffect.Data {
    @_silgen_name("OpenSwiftUITestStub__Rotation3DEffectDataEncode")
    func swiftUI_encode(to encoder: inout ProtobufEncoder) throws

    @_silgen_name("OpenSwiftUITestStub__Rotation3DEffectDataDecode")
    init(swiftUI_from decoder: inout ProtobufDecoder) throws
}

@Suite
struct Rotation3DEffectDualTests {
    private static func makeEffect() -> _Rotation3DEffect {
        _Rotation3DEffect(
            angle: .radians(.pi / 4),
            axis: (x: 1, y: 0, z: 0),
            anchor: .center,
            anchorZ: 2,
            perspective: 2,
        )
    }

    private static func makeEffect2() -> _Rotation3DEffect {
        _Rotation3DEffect(
            angle: .radians(.pi / 3),
            axis: (x: 0, y: 1, z: 0),
            anchor: .center,
            anchorZ: 1,
            perspective: 1,
        )
    }

    @Suite
    struct DataTests {
        private static func makeData() -> (_Rotation3DEffect.Data, _Rotation3DEffect.Data) {
            let effect = makeEffect()
            let size = CGSize(width: 100, height: 50)
            let leftData = _Rotation3DEffect.Data(swiftUI_effect: effect, size: size, layoutDirection: .leftToRight)
            let rightData = _Rotation3DEffect.Data(swiftUI_effect: effect, size: size, layoutDirection: .rightToLeft)
            return (leftData, rightData)
        }

        private static func makeData2() -> (_Rotation3DEffect.Data, _Rotation3DEffect.Data) {
            let effect = makeEffect2()
            let size = CGSize(width: 100, height: 50)
            let leftData = _Rotation3DEffect.Data(swiftUI_effect: effect, size: size, layoutDirection: .leftToRight)
            let rightData = _Rotation3DEffect.Data(swiftUI_effect: effect, size: size, layoutDirection: .rightToLeft)
            return (leftData, rightData)
        }

        @Test(
            arguments: [
                (
                    makeData().0,
                    _Rotation3DEffect.Data(
                        angle: .radians(.pi / 4),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: (x: 50, y: 25, z: 2),
                        perspective: 50,
                        flipWidth: .nan
                    )
                ),
                (
                    makeData().1,
                    _Rotation3DEffect.Data(
                        angle: .radians(.pi / 4),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: (x: 50, y: 25, z: 2),
                        perspective: 50,
                        flipWidth: 100
                    )
                ),
                (
                    makeData2().0,
                    _Rotation3DEffect.Data(
                        angle: .radians(.pi / 3),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: (x: 50, y: 25, z: 1),
                        perspective: 100,
                        flipWidth: .nan
                    )
                ),
                (
                    makeData2().1,
                    _Rotation3DEffect.Data(
                        angle: .radians(.pi / 3),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: (x: 50, y: 25, z: 1),
                        perspective: 100,
                        flipWidth: 100
                    )
                ),
            ]
        )
        func dataInit(_ data: _Rotation3DEffect.Data, expected: _Rotation3DEffect.Data) {
            #expect(data.isAlmostEqual(to: expected))
        }

        @Test(
            arguments: [
                (
                    makeData().0,
                    ProjectionTransform(
                        m11: 1.0, m12: 0.0, m13: 0.0,
                        m21: -0.7071067811865475, m22: 0.35355339059327384, m23: -0.014142135623730949,
                        m31: 19.09188309203678, m32: 18.282485578727798, m33: 1.3818376618407355
                    )
                ),
                (
                    makeData().1,
                    ProjectionTransform(
                        m11: 1.0, m12: 0.0, m13: 0.0,
                        m21: -0.7071067811865475, m22: 0.35355339059327384, m23: -0.014142135623730949,
                        m31: 19.09188309203678, m32: 18.282485578727798, m33: 1.3818376618407355
                    )
                ),
                (
                    makeData2().0,
                    ProjectionTransform(
                        m11: 0.9330127018922194, m12: 0.21650635094610965, m13: 0.008660254037844387,
                        m21: 0.0, m22: 1.0, m23: 0.0,
                        m31: 2.7333395016045907, m32: -10.700317547305483, m33: 0.5719872981077807
                    )
                ),
                (
                    makeData2().1,
                    ProjectionTransform(
                        m11: 0.06698729810778081, m12: -0.21650635094610965, m13: -0.008660254037844387,
                        m21: 0.0, m22: 1.0, m23: 0.0,
                        m31: 47.766660498395396, m32: 10.950317547305483, m33: 1.4380127018922193
                    )
                ),
            ]
        )
        func transform(data: _Rotation3DEffect.Data, transform: ProjectionTransform) {
            #expect(data.swiftui_transform.isAlmostEqual(to: transform))
        }

        @Test(
            arguments: [
                (makeData().0, "09182d4454fb21e93f150000803f2d00004842350000c8413d000000404500004842"),
                (makeData().1, "09182d4454fb21e93f150000803f2d00004842350000c8413d0000004045000048424d0000c842"),
                (makeData2().0, "0965732d3852c1f03f1d0000803f2d00004842350000c8413d0000803f450000c842"),
                (makeData2().1, "0965732d3852c1f03f1d0000803f2d00004842350000c8413d0000803f450000c8424d0000c842"),
                (_Rotation3DEffect.Data.init(flipWidth: .zero), ""),
                (_Rotation3DEffect.Data.init(flipWidth: .nan), ""),
                (_Rotation3DEffect.Data.init(flipWidth: .infinity), ""),
                (_Rotation3DEffect.Data.init(flipWidth: -.infinity), ""),
                (_Rotation3DEffect.Data.init(flipWidth: .ulpOfOne), "4d00008025"),
            ]
        )
        func pbMessage(data: _Rotation3DEffect.Data, hexString: String) throws {
            try data.testPBEncoding(swiftUI_hexString: hexString)
            try data.testPBDecoding(swiftUI_hexString: hexString)
        }
    }
}

extension _Rotation3DEffect.Data {
    func testPBEncoding(swiftUI_hexString expectedHexString: String) throws {
        let data = try ProtobufEncoder.encoding { encoder in
            try swiftUI_encode(to: &encoder)
        }
        #expect(data.hexString == expectedHexString)
    }

    func testPBDecoding(swiftUI_hexString hexString: String) throws {
        var decodedValue = try decodePBSwiftUIHexString(hexString)
        if decodedValue.flipWidth.isNaN { // Ignore flipWidth when decoding
            decodedValue.flipWidth = flipWidth
        }
        #expect(decodedValue.isAlmostEqual(to: self))
    }

    private func decodePBSwiftUIHexString(_ string: String) throws -> _Rotation3DEffect.Data {
        guard let data = Data(hexString: string) else {
            throw ProtobufDecoder.DecodingError.failed
        }
        var decoder = ProtobufDecoder(data)
        return try _Rotation3DEffect.Data(swiftUI_from: &decoder)
    }
}

#endif
