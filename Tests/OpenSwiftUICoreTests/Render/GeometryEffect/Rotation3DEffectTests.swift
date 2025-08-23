//
//  Rotation3DEffectTests.swift
//  OpenSwiftUICoreTests

#if canImport(CoreGraphics)
import Foundation
import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

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
            let leftData = _Rotation3DEffect.Data(effect, size: size, layoutDirection: .leftToRight)
            let rightData = _Rotation3DEffect.Data(effect, size: size, layoutDirection: .rightToLeft)
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
            func testPBDecodingIgnoreFlipWidth(hexString: String) throws {
                var decodedValue = try hexString.decodePBHexString(_Rotation3DEffect.Data.self)
                if decodedValue.flipWidth.isNaN { // Ignore flipWidth when decoding
                    decodedValue.flipWidth = data.flipWidth
                }
                #expect(decodedValue.isAlmostEqual(to: data))
            }
            try data.testPBEncoding(hexString: hexString)
            try testPBDecodingIgnoreFlipWidth(hexString: hexString)
        }
    }
}

#endif
