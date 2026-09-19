//
//  TapGestureUXTests.swift
//  OpenSwiftUIUXTests

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Testing

@MainActor
@Suite(.serialized)
struct TapGestureUXTests {
    @Test
    func onTapGestureIncrementsCount() async throws {
        var count = 0
        let content = Color.red.onTapGesture {
            count += 1
        }
        try await withUXTestHost(of: content) { host in
            #expect(count == 0)
            try await host.tap()
            try await host.waitUntil(count > 0)
            #expect(count == 1)
        }
    }
}
