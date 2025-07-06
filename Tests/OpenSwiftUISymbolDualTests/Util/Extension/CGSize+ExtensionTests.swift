//
//  CGSize+ExtensionTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.0.87)
import Testing
import SwiftUI

extension CGSize {
    var hasZero: Bool {
        @_silgen_name("OpenSwiftUITestStub_CGSizeHasZero")
        get
    }
}

struct CGSize_ExtensionTests {
    @Test(
        .enabled {
            if #available(iOS 18, macOS 14, *) {
                return true
            } else {
                return false
            }
        },
        arguments: [
            (CGSize(width: 0, height: 0), true),
            (CGSize(width: 1, height: 0), true),
            (CGSize(width: 0, height: 1), true),
            (CGSize(width: 1, height: 1), false)
        ]
    )
    func hasZero(size: CGSize, expectedResult: Bool) {
        let result = size.hasZero
        #expect(result == expectedResult)
    }
}

#endif
