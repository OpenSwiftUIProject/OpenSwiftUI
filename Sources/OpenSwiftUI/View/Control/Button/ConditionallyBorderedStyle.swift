//
//  ConditionallyBorderedStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUICore

// MARK: - ConditionallyBorderedStyle

#if os(iOS) || os(visionOS)
struct ConditionallyBorderedStyle: PrimitiveButtonStyle {
    @Environment(\.accessibilityShowButtonShapes)
    var showsShapes: Bool

    func makeBody(configuration: Configuration) -> some View {
        if showsShapes {
            Button(configuration).buttonStyle(BorderedButtonStyle())
        } else {
            Button(configuration).buttonStyle(BorderlessButtonStyle())
        }
    }
}
#endif
