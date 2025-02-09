//
//  IDViewTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing
import Foundation

@MainActor
struct IDViewTests {
    @Test
    func viewExtension() {
        let empty = EmptyView()
        _ = empty.id("1")
        _ = empty.id(2)
        _ = empty.id(UUID())
    }
}
