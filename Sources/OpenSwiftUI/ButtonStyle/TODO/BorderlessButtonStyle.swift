//
//  BorderlessButtonStyle.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 8946ABD13E6925C5D5FDD316D4A45F59

import Foundation

public struct BorderlessButtonStyle : PrimitiveButtonStyle, ButtonStyleConvertible {

    /// Creates a borderless button style.
    public init() { }

    /// Creates a view that represents the body of a button.
    ///
    /// The system calls this method for each ``Button`` instance in a view
    /// hierarchy where this style is the current button style.
    ///
    /// - Parameter configuration : The properties of the button.
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
//        Button(configuration)
//            // FIXME: AccessibilityButtonShapeModifier is missing
//            .buttonStyle(buttonStyleRepresentation)
    }

    internal var buttonStyleRepresentation: some ButtonStyle {
        BorderlessButtonStyleBase()
    }

//    @Environment(\.tintColor)
//    private var controlTint: Color?
}

extension PrimitiveButtonStyle where Self == BorderlessButtonStyle {
    public static var borderless: BorderlessButtonStyle { BorderlessButtonStyle() }
}

private struct BorderlessButtonStyleBase: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

struct OpacityButtonHighlightModifier: ViewModifier {
    var highlighted: Bool

//    @Environment(\.colorScheme)
//    var colorScheme: ColorScheme

//    fileprivate var pressedOpacity: Double {
//        switch colorScheme {
//        case .light: 0.2
//        case .dark: 0.4
//        }
//    }

    func body(content: Content) -> some View {
        content
//            .opacity(highlighted ? pressedOpacity : 1.0)
//            .contentShape(Rectangle(), eoFill: false)
    }
}
