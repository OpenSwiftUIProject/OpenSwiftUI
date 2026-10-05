//
//  LabelStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8ADADA438F274FC671ACFFBCE6ADA2B4 (SwiftUI)

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - LabelStyle

/// A type that applies a custom appearance to all labels within a view.
///
/// To configure the current label style for a view hierarchy, use the
/// ``View/labelStyle(_:)`` modifier.
///
/// A type conforming to this protocol inherits `@preconcurrency @MainActor`
/// isolation from the protocol if the conformance is included in the type's
/// base declaration:
///
///     struct MyCustomType: Transition {
///         // `@preconcurrency @MainActor` isolation by default
///     }
///
/// Isolation to the main actor is the default, but it's not required. Declare
/// the conformance in an extension to opt out of main actor isolation:
///
///     extension MyCustomType: Transition {
///         // `nonisolated` by default
///     }
@available(OpenSwiftUI_v2_0, *)
@preconcurrency
@MainActor
public protocol LabelStyle {
    /// A view that represents the body of a label.
    associatedtype Body: View

    /// Creates a view that represents the body of a label.
    ///
    /// The system calls this method for each ``Label`` instance in a view
    /// hierarchy where this style is the current label style.
    ///
    /// - Parameter configuration: The properties of the label.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    /// The properties of a label.
    typealias Configuration = LabelStyleConfiguration
}

// MARK: - LabelStyleConfiguration

/// The properties of a label.
@available(OpenSwiftUI_v2_0, *)
public struct LabelStyleConfiguration {
    /// A type-erased title view of a label.
    @MainActor
    @preconcurrency
    public struct Title: ViewAlias {
        nonisolated init() {
            _openSwiftUIEmptyStub()
        }
    }

    /// A type-erased icon view of a label.
    @MainActor
    @preconcurrency
    public struct Icon: ViewAlias {
        nonisolated init() {
            _openSwiftUIEmptyStub()
        }
    }

    /// A description of the labeled item.
    public var title: Title {
        Title()
    }

    /// A symbolic representation of the labeled item.
    public var icon: Icon {
        Icon()
    }
}

@available(*, unavailable)
extension LabelStyleConfiguration: Sendable {}

@available(*, unavailable)
extension LabelStyleConfiguration.Icon: Sendable {}

@available(*, unavailable)
extension LabelStyleConfiguration.Title: Sendable {}

// MARK: - ResolvedLabelStyle

struct ResolvedLabelStyle: StyleableView {
    var configuration: LabelStyleConfiguration { .init() }

    static var defaultStyleModifier: LabelStyleModifier<DefaultLabelStyle> {
        LabelStyleModifier(style: DefaultLabelStyle())
    }

    var body: some View {
        StaticIf(MultiViewLabel.self) {
            Label(configuration)
        } else: {
            Label(configuration)
                .modifier(AccessibilityFrameModifier())
                .platformItemLabel(configuration.title, flags: TextPlatformItemListFlags())
        }
    }
}

// MARK: - Label Inputs

struct MultiViewLabel: ViewInputBoolFlag {}

// MARK: - LabelItemRole

enum LabelItemRole: Hashable {
    case icon
    case title

    struct ContainerKey: ContainerValueKey {
        static var defaultValue: LabelItemRole? { nil }
    }
}

extension ContainerValues {
    var labelItemRole: LabelItemRole? {
        get { self[LabelItemRole.ContainerKey.self] }
        set { self[LabelItemRole.ContainerKey.self] = newValue }
    }
}

// MARK: - LabelStyleWritingModifier

private struct LabelStyleWritingModifier<Style>: ViewModifier where Style: LabelStyle {
    var style: Style

    func body(content: Content) -> some View {
        let effectiveStyle: EffectiveLabelStyle?
        if Style.self == TitleOnlyLabelStyle.self
            || Style.self == TitleAndIconLabelStyle.self
            || Style.self == IconOnlyLabelStyle.self {
            effectiveStyle = EffectiveLabelStyle(baseType: ObjectIdentifier(Style.self))
        } else {
            effectiveStyle = nil
        }
        return content
            .modifier(LabelStyleModifier(style: style))
            .environment(\.effectiveLabelStyle, effectiveStyle)
    }
}

// MARK: - LabelStyleModifier

struct LabelStyleModifier<Style>: StyleModifier where Style: LabelStyle {
    var style: Style

    init(style: Style) {
        self.style = style
    }

    func styleBody(configuration: LabelStyleConfiguration) -> Style.Body {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - View + LabelStyle

@available(OpenSwiftUI_v2_0, *)
extension View {
    /// Sets the style for labels within this view.
    ///
    /// Use this modifier to set a specific style for all labels within a view:
    ///
    ///     VStack {
    ///         Label("Fire", systemImage: "flame.fill")
    ///         Label("Lightning", systemImage: "bolt.fill")
    ///     }
    ///     .labelStyle(MyCustomLabelStyle())
    nonisolated public func labelStyle<S>(_ style: S) -> some View where S: LabelStyle {
        modifier(LabelStyleWritingModifier(style: style))
    }
}
