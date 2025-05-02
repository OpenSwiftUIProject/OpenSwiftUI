//
//  CGSize+ExtensionTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.0.87)
import Testing
import SwiftUI
import OpenSwiftUI

extension CGSize {
    var swiftUIHasZero: Bool {
        @_silgen_name("OpenSwiftUITestStub_CGSizeHasZero")
        get
    }
}

#if compiler(>=6.1) // https://github.com/swiftlang/swift/issues/81248
struct CGSize_ExtensionTests {
    @Test(
        arguments: [
        (CGSize(width: 0, height: 0), true),
        (CGSize(width: 1, height: 0), true),
        (CGSize(width: 0, height: 1), true),
        (CGSize(width: 1, height: 1), false)
        ],
        .enabled {
            if #available(iOS 18, macOS 14, *) {
                return true
            } else {
                return false
            }
        }
    )
    func hasZero(size: CGSize, expectedResult: Bool) {
        let openSwiftUIResult = size.hasZero
        let swiftUIResult = size.swiftUIHasZero
        #expect(openSwiftUIResult == expectedResult)
        #expect(swiftUIResult == expectedResult)
        #expect(openSwiftUIResult == swiftUIResult)
    }
}
#endif

#endif
