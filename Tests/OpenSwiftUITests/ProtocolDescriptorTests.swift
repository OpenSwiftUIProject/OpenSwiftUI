//
//  ProtocolDescriptorTests.swift
//
//
//  Created by Kyle on 2023/10/3.
//
@testable import OpenSwiftUI
import OpenSwiftUIShims
import XCTest

final class ProtocolDescriptorTests: XCTestCase {
    func testExample() throws {
        struct ContentView: View {
            var body: some View {
                EmptyView()
            }
        }

        struct ContentViewModifier: ViewModifier {
            func body(content _: Content) -> some View {
                EmptyView()
            }
        }

        XCTAssertTrue(conformsToProtocol(ContentView.self, _viewProtocolDescriptor()))
        XCTAssertFalse(conformsToProtocol(ContentView.self, _viewModifierProtocolDescriptor()))

        XCTAssertFalse(conformsToProtocol(ContentViewModifier.self, _viewProtocolDescriptor()))
        XCTAssertTrue(conformsToProtocol(ContentViewModifier.self, _viewModifierProtocolDescriptor()))
    }
}
