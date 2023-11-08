//
//  ProtocolDescriptorTests.swift
//
//
//  Created by Kyle on 2023/10/3.
//

#if OPENSWIFTUI_USE_SWIFT_TESTING
@testable import OpenSwiftUI
import OpenSwiftUIShims
import Testing

struct ProtocolDescriptorTests {
    @Test
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

        #expect(conformsToProtocol(ContentView.self, _viewProtocolDescriptor()))
        #expect(!conformsToProtocol(ContentView.self, _viewModifierProtocolDescriptor()))
        #expect(!conformsToProtocol(ContentViewModifier.self, _viewProtocolDescriptor()))
        #expect(conformsToProtocol(ContentViewModifier.self, _viewModifierProtocolDescriptor()))
    }
}
#endif
