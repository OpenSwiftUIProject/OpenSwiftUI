//
//  ProtocolDescriptorTests.swift
//
//
//  Created by Kyle on 2023/10/3.
//

@testable import OpenSwiftUI
import COpenSwiftUI
import Testing

struct ProtocolDescriptorTests {
    @Test
    func conformsToProtocolCheck() throws {
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
        
        #expect(conformsToProtocol(ContentView.self, _OpenSwiftUI_viewProtocolDescriptor()))
        #expect(!conformsToProtocol(ContentView.self, _OpenSwiftUI_viewModifierProtocolDescriptor()))
        #expect(!conformsToProtocol(ContentViewModifier.self, _OpenSwiftUI_viewProtocolDescriptor()))
        #expect(conformsToProtocol(ContentViewModifier.self, _OpenSwiftUI_viewModifierProtocolDescriptor()))
    }
}
