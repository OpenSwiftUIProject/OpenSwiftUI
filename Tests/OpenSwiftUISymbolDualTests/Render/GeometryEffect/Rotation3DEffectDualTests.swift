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
            axis: (x: 1.0, y: 0.0, z: 0.0),
            anchor: .center,
            anchorZ: 2,
            perspective: 2,
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

        @Test
        func dataInit() {
            let (leftData, rightData) = Self.makeData()
            #expect(leftData.isAlmostEqual(
                to: .init(
                    angle: .radians(.pi / 4),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: (x: 50, y: 25, z: 2),
                    perspective: 50,
                    flipWidth: .nan
                )
            ))
            #expect(rightData.isAlmostEqual(
                to: .init(
                    angle: .radians(.pi / 4),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: (x: 50, y: 25, z: 2),
                    perspective: 50,
                    flipWidth: 100
                )
            ))
        }

        @Test
        func transform() {
            let (leftData, rightData) = Self.makeData()
            #expect(leftData.transform.m11.isAlmostEqual(to: 1.0))
            #expect(leftData.transform.m12.isAlmostEqual(to: 0.0))
            #expect(leftData.transform.m13.isAlmostEqual(to: 0.0))
            #expect(leftData.transform.m21.isAlmostEqual(to: 0.0))
            #expect(leftData.transform.m22.isAlmostEqual(to: 0.7071067811865476))
            #expect(leftData.transform.m23.isAlmostEqual(to: 0.0))
            #expect(leftData.transform.m31.isAlmostEqual(to: 0.0))
            #expect(leftData.transform.m32.isAlmostEqual(to: 8.736544032709405))
            #expect(leftData.transform.m33.isAlmostEqual(to: 1.0))

            #expect(rightData.transform.m11.isAlmostEqual(to: 1.0))
            #expect(rightData.transform.m12.isAlmostEqual(to: 0.0))
            #expect(rightData.transform.m13.isAlmostEqual(to: 0.0))
            #expect(rightData.transform.m21.isAlmostEqual(to: 0.0))
            #expect(rightData.transform.m22.isAlmostEqual(to: 0.5000000000000001))
            #expect(rightData.transform.m23.isAlmostEqual(to: 0.0))
            #expect(rightData.transform.m31.isAlmostEqual(to: 100.0))
            #expect(rightData.transform.m32.isAlmostEqual(to: 56.17766952966369))
            #expect(rightData.transform.m33.isAlmostEqual(to: 1.0))
        }

        @Test(
            arguments: [
                (makeData().0, "09182d4454fb21e93f150000803f2d00004842350000c8413d000000404500004842"),
                (makeData().1, "09182d4454fb21e93f150000803f2d00004842350000c8413d0000004045000048424d0000c842"),
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
