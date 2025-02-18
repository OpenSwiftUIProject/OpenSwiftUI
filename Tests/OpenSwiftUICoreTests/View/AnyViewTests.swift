//
//  AnyViewTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

@MainActor
struct AnyViewTests {
    @Test
    func initFromValue() throws {
        let empty = EmptyView()
        let any1 = try #require(AnyView(_fromValue: empty))

        let any2 = try #require(AnyView(_fromValue: any1))
        #expect(any2.storage === any1.storage)

        let any3 = AnyView(any1)
        #expect(any3.storage === any1.storage)
    }
}
