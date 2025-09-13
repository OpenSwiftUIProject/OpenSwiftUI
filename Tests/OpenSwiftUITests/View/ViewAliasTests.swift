//
//  ViewAliasTests.swift
//  OpenSwiftUITests

import Testing
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if os(iOS) || os(visionOS)
import UIKit
#endif

// TODO: Add viewAlias related test after style are implemented
@MainActor
struct ViewAliasTests {
//    struct CustomView: View {
//        struct Alias: ViewAlias {
//            init() {}
//        }
//    }
//    @Test
//    func optionalViewAliasDynamicProperty() {
//        struct ContentView: View {
//            @OptionalViewAlias
//            private var alias: CustomView.Alias?
//
//            var body: some View {
//                CustomView()
//                    .viewAlias(CustomView.Alias.self) {
//                        Color.red
//                    }
//            }
//        }
//        #if os(iOS) || os(visionOS)
//        let hostingView = _UIHostingView(rootView: ContentView())
//        hostingView.render()
//        #endif
//    }
}
