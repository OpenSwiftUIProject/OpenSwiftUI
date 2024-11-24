//
//  ColorMatrixTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUICore
import Testing

struct ColorMatrixTests {
    @Test
    func identity() {
        let identityMatrix = ColorMatrix()
        #expect(identityMatrix.r1 == 1); #expect(identityMatrix.r2 == 0); #expect(identityMatrix.r3 == 0); #expect(identityMatrix.r4 == 0); #expect(identityMatrix.r5 == 0)
        #expect(identityMatrix.g1 == 0); #expect(identityMatrix.g2 == 1); #expect(identityMatrix.g3 == 0); #expect(identityMatrix.g4 == 0); #expect(identityMatrix.g5 == 0)
        #expect(identityMatrix.b1 == 0); #expect(identityMatrix.b2 == 0); #expect(identityMatrix.b3 == 1); #expect(identityMatrix.b4 == 0); #expect(identityMatrix.b5 == 0)
        #expect(identityMatrix.a1 == 0); #expect(identityMatrix.a2 == 0); #expect(identityMatrix.a3 == 0); #expect(identityMatrix.a4 == 1); #expect(identityMatrix.a5 == 0)
    }
}

struct _ColorMatrixTests {
    @Test
    func identity() {
        let identityMatrix = _ColorMatrix()
        #expect(identityMatrix.m11 == 1); #expect(identityMatrix.m12 == 0); #expect(identityMatrix.m13 == 0); #expect(identityMatrix.m14 == 0); #expect(identityMatrix.m15 == 0)
        #expect(identityMatrix.m21 == 0); #expect(identityMatrix.m22 == 1); #expect(identityMatrix.m23 == 0); #expect(identityMatrix.m24 == 0); #expect(identityMatrix.m25 == 0)
        #expect(identityMatrix.m31 == 0); #expect(identityMatrix.m32 == 0); #expect(identityMatrix.m33 == 1); #expect(identityMatrix.m34 == 0); #expect(identityMatrix.m35 == 0)
        #expect(identityMatrix.m41 == 0); #expect(identityMatrix.m42 == 0); #expect(identityMatrix.m43 == 0); #expect(identityMatrix.m44 == 1); #expect(identityMatrix.m45 == 0)
        #expect(identityMatrix.isIdentity == true)
        
        var matrix = identityMatrix
        matrix.m11 = 0
        #expect(matrix.isIdentity == false)
    }
    
    @Test(
        arguments: [
            (_ColorMatrix(), ""),
            (_ColorMatrix(m11: 3.0), "0d00004040"),
        ]
    )
    func pbMessage(matrix: _ColorMatrix, hexString: String) throws {
        try matrix.testPBEncoding(hexString: hexString)
        try matrix.testPBDecoding(hexString: hexString)
    }
}
