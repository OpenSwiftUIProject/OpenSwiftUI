//
//  ButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Complete

/// MARK: - ButtonStyle

@MainActor @preconcurrency
public protocol ButtonStyle {
    associatedtype Body: View
    
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body
    
    typealias Configuration = ButtonStyleConfiguration
}

extension View {
    nonisolated public func buttonStyle<S>(_ style: S) -> some View where S: ButtonStyle {
        modifier(ButtonStyleModifier(style: style))
    }
}

struct ButtonStyleModifier<Style>: StyleModifier where Style: ButtonStyle {
    init(style: Style) {
        self.style = style
    }

    var style: Style;

    func styleBody(configuration: Style.Configuration) -> some View {
        style.makeBody(configuration: configuration)
    }
}

private struct ButtonStyleKey: EnvironmentKey {
    static let defaultValue = AnyButtonStyle.default
}

private class AnyStyleBox {
    func body(configuration _: ButtonStyleConfiguration) -> AnyView {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

private final class StyleBox<Base: ButtonStyle>: AnyStyleBox {
    let base: Base

    init(base: Base) {
        self.base = base
    }

    override func body(configuration: ButtonStyleConfiguration) -> AnyView {
        AnyView(base.makeBody(configuration: configuration))
    }
}

struct AnyButtonStyle: ButtonStyle {
    private let box: AnyStyleBox;

    static let `default` = AnyButtonStyle.init()

    private init() {
        self.box = AnyStyleBox()
    }

    @Environment(\.isEnabled)
    nonisolated
    var isEnabled: Bool;


    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        box.body(configuration: configuration)
    }

    private init(box: AnyStyleBox) {
        self.box = box
    }

    init(style: some ButtonStyle) {
        self.box = StyleBox(base: style)
    }
}


extension EnvironmentValues {
    @inline(__always)
    var buttonStyle: AnyButtonStyle {
        get { self[ButtonStyleKey.self] }
        set { self[ButtonStyleKey.self] = newValue }
    }
}
