//
//  AnyViewTests.swift
//  OpenSwiftUIUITests

import XCTest

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if os(iOS)
import UIKit

#if !OPENSWIFTUI
@available(iOS 15, *)
#endif
final class AnyViewTests: XCTestCase {
    // @Test("Attribute setter crash for basic AnyView", .bug("https://github.com/OpenSwiftUIProject/OpenGraph/issues/58", relationship: .verifiesFix))
    func testBasicAnyView() throws {
        struct ContentView: View {
            var body: some View {
                AnyView(EmptyView())
            }
        }
        let vc = UIHostingController(rootView: ContentView())
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.view.layoutSubviews()
    }
}
#endif
