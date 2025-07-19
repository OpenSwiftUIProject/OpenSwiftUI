//
//  ViewGraphTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import OpenSwiftUI_SPI
import Testing

struct ViewGraphTests {
    struct NextUpdateTests {
        typealias Update = ViewGraph.NextUpdate

        @Test
        func interval() {
            let update = Update()
            #expect(update.interval == .zero)
        }
    }
}
