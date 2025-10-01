//
//  PlainButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Blocked
//  ID: AEEE04F3F0E4AB1B61A885733139FBF6

public struct PlainButtonStyle: PrimitiveButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
//        Button(configuration)
//            .buttonStyle(buttonStyleRepresentation)
        _openSwiftUIBaseClassAbstractMethod()
    }
}

// MARK: ButtonStyleConvertible

extension PlainButtonStyle: ButtonStyleConvertible {
    var buttonStyleRepresentation: some ButtonStyle { PlainButtonStyleBase() }
}

extension PrimitiveButtonStyle where Self == PlainButtonStyle {
    public static var plain: PlainButtonStyle { PlainButtonStyle() }
}

private struct PlainButtonStyleBase: ButtonStyle {
    @Environment(\.isEnabled)
    private var isEnabled: Bool

    fileprivate func makeBody(configuration _: Configuration) -> some View {
//        HStack {
//            configuration.label
//        }
//        .opacity(isEnabled ? (configuration.isPressed ? 0.75 : 1.0) : 0.5)
        _openSwiftUIBaseClassAbstractMethod()
    }
}
