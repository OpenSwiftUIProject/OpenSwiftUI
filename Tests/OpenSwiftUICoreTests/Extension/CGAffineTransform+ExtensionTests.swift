//
//  CGAffineTransform+ExtensionTests.swift
//  OpenSwiftUICoreTests

#if canImport(Darwin)
import Testing
import CoreGraphics
import OpenSwiftUICore

struct CGAffineTransform_ExtensionTests {
    @Test(
        arguments: [
            (CGAffineTransform.identity, ""),
            (CGAffineTransform(scaleX: 2, y: 4), "0d000000402500008040"),
            (CGAffineTransform(translationX: 2, y: 4), "2d000000403500008040"),
        ]
    )
    func pbMessage(transfrom: CGAffineTransform, hexString: String) throws {
        try transfrom.testPBEncoding(hexString: hexString)
        try transfrom.testPBDecoding(hexString: hexString)
    }
}
#endif
