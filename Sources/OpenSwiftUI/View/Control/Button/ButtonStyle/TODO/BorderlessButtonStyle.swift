//
//  BorderlessButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: 8946ABD13E6925C5D5FDD316D4A45F59

@available(tvOS, unavailable)
public struct BorderlessButtonStyle: PrimitiveButtonStyle, ButtonStyleConvertible {
    /// Creates a borderless button style.
    public init() {}

    /// Creates a view that represents the body of a button.
    ///
    /// The system calls this method for each ``Button`` instance in a view
    /// hierarchy where this style is the current button style.
    ///
    /// - Parameter configuration : The properties of the button.
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
//        AccessibilityButtonShapeModifier()
//            .body(content: Button(configuration))
//            .buttonStyle(buttonStyleRepresentation)
    }

    var buttonStyleRepresentation: some ButtonStyle {
        BorderlessButtonStyleBase()
    }

//    @Environment(\.tintColor)
//    private var controlTint: Color?
}

@available(tvOS, unavailable)
extension PrimitiveButtonStyle where Self == BorderlessButtonStyle {
    public static var borderless: BorderlessButtonStyle { BorderlessButtonStyle() }
}

@available(tvOS, unavailable)
private struct BorderlessButtonStyleBase: ButtonStyle {
    @inline(__always)
    fileprivate init() {}

//    @Environment(\.keyboardShortcut)
//    private var keyboardShortcut: KeyboardShortcut?
//
    @Environment(\.controlSize)
    private var controlSize: ControlSize

    @Environment(\.isEnabled)
    private var isEnable: Bool

    private var isDefault: Bool {
        #if os(watchOS)
        // TODO
        false
        #else
        let keyboardShortcut = KeyboardShortcut.defaultAction
        return keyboardShortcut == .defaultAction
        #endif
    }

    private var defaultFont: Font {
        let style: Font.TextStyle = switch controlSize {
        case .mini: .subheadline
        case .small: .subheadline
        case .regular: .body
        case .large: .body
        case .extraLarge: .body
        }
//        let font = Font(provider: Font.TextStyleProvider(
//            textStyle: style,
//            design: .default,
//            weight: isDefault ? .regular : .semibold
//        ))
//        return font
        return .body
    }

//    internal var accessibilityShowButtonShapes: Bool

    fileprivate func makeBody(configuration: Configuration) -> some View {
        EmptyView()
//        HStack {
//            configuration.label
//        }
                .defaultFont(defaultFont)
//        .multilineTextAlignment(.center)
//        .buttonDefaultRenderingMode()
//        .defaultForegroundColor(isEnable ? (configuration.role == .destructive ? .red : .accentColor) : .gray)
                .modifier(OpacityButtonHighlightModifier(highlighted: configuration.isPressed))
    }
}

struct OpacityButtonHighlightModifier: ViewModifier {
    var highlighted: Bool

    @Environment(\.colorScheme)
    var colorScheme: ColorScheme

    fileprivate var pressedOpacity: Double {
        switch colorScheme {
        case .light: 0.2
        case .dark: 0.4
        }
    }

    func body(content: Content) -> some View {
        content
        // TODO: Fix visionOS build issue with opacity modifier
//            .opacity(highlighted ? pressedOpacity : 1.0)
            .contentShape(Rectangle(), eoFill: false)
    }
}
