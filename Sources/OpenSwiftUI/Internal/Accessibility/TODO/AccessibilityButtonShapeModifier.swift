//
//  AccessibilityButtonShapeModifier.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/9.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 0D3243EDC3DD4D641848661DCC354D4B

struct AccessibilityButtonShapeModifier<V: View>: AccessibilityConfigurationModifier {
    typealias Configuration = Never
    typealias Content = V

    // deleted method
    var configuration: Never { fatalError() }

    func body(content: V) -> some View {
        content.modifier(Child())
    }

    private struct Child: ViewModifier {
//        @Environment(\.accessibilityShowButtonShapes)
//        private var accessibilityShowButtonShapes: Bool

        func body(content: Child.Content) -> some View {
//            if accessibilityShowButtonShapes {
                content
                // .buttonStyle(BorderedButtonStyle())
//            } else {
//                content
//            }
        }
    }
}
