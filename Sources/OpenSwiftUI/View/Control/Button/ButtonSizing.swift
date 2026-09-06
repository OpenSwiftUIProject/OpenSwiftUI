/// Mark: - ButtonSizing

/// The sizing behaviour of Buttons and other button-like controls.
struct ButtonSizing {
    static var automatic: ButtonSizing { get {.init()}}
    static var fitted: ButtonSizing { get {.init()} }
    static var flexible: ButtonSizing { get {.init()} }
}

extension ButtonSizing: Hashable {}
extension ButtonSizing: Equatable {}
extension ButtonSizing: Sendable {}

nonisolated struct ButtonSizingModifier<Style>: StyleModifier where Style: ButtonStyle {
    init(style: Style) {
        self.style = style
    }

    var style: Style;

    func styleBody(configuration: Style.Configuration) -> some View {
        style.makeBody(configuration: configuration)
    }
}

extension View {
    nonisolated public func ButtonSizing<S>(_ style: S) -> some View where S: ButtonStyle {
        modifier(ButtonSizingModifier(style: style))
    }
}

struct ButtonSizingKey: EnvironmentKey {
    static let defaultValue = ButtonSizing.automatic
}

extension EnvironmentValues {
    var buttonSizing: ButtonSizing {
        get { self[ButtonSizingKey.self] }
        set { self[ButtonSizingKey.self] = newValue }
    }
}