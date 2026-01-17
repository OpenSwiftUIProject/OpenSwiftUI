//
//  ViewGeometryDualTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
import Foundation
import OpenSwiftUICore
import Testing

extension ViewGeometry {
    var swiftUI_isInvalid: Bool {
        @_silgen_name("OpenSwiftUITestStub_ViewGeometryIsInvalid")
        get
    }
}

struct ViewGeometryDualTests {
    @Test(arguments: [
        (CGFloat.nan, true),
        (CGFloat.infinity, false),
        (-CGFloat.infinity, false),
        (3.0, false),
    ] as [(CGFloat, Bool)])
    func isInvalid(originX: CGFloat, expected: Bool) {
        let origin = ViewOrigin(x: originX, y: 0)
        let geometry = ViewGeometry(origin: origin, dimensions: .zero)
        #expect(geometry.isInvalid == expected)
        #expect(geometry.swiftUI_isInvalid == expected)
    }
}

#endif

