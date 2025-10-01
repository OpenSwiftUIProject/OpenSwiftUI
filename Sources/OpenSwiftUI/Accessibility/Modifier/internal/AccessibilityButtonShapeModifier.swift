//
//  AccessibilityButtonShapeModifier.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: WIP
//  ID: 0D3243EDC3DD4D641848661DCC354D4B

struct AccessibilityButtonShapeModifier<Content: View>: AccessibilityConfigurationModifier {
    func body(content: Content) -> some View {
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
