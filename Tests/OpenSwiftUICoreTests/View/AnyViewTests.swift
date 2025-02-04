//
//  AnyViewTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

struct AnyViewTests {
    @Test
    func testInitFromValue() throws {
        let empty = EmptyView()
        let any = try #require(AnyView(_fromValue: empty))
        // #expect(any.storage.id == nil)
        let _: EmptyView = any.storage.child()
        
        let any1 = AnyView(any)
        let any2 = try #require(AnyView(_fromValue: any))
        #expect(any1.storage === any2.storage)
    }
}
