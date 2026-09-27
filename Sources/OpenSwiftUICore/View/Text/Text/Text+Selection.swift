//
//  Text+Selection.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E9056C24F23374CCD1A34D90898CB830 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - TextSelectability

/// A type that describes the ability to select text.
///
/// To configure whether people can select text in your app, use the
/// ``View/textSelection(_:)`` modifier, passing in a text selectability
/// value like ``enabled`` or ``disabled``.
@available(OpenSwiftUI_v3_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public protocol TextSelectability {
    /// A Boolean value that indicates whether the selectability type allows
    /// selection.
    ///
    /// Conforming types, such as ``EnabledTextSelectability`` and
    /// ``DisabledTextSelectability``, return `true` or `false` for this
    /// property as appropriate. OpenSwiftUI expects this value for a given
    /// selectability type to be constant, unaffected by global state.
    static var allowsSelection: Bool { get }
}

@available(OpenSwiftUI_v3_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension TextSelectability where Self == EnabledTextSelectability {
    /// A selectability value that enables text selection by a person using your app.
    ///
    /// Enabling text selection allows people to perform actions on the text
    /// content, such as copying and sharing. Enable text selection in views
    /// where those operations are useful, such as copying unique IDs or
    /// error messages. This allows people to paste the data into
    /// emails or documents.
    ///
    /// The following example enables text selection on the second of two
    /// ``Text`` views in a ``VStack``.
    ///
    ///     VStack {
    ///         Text("Event Invite")
    ///             .font(.title)
    ///         Text(invite.date.formatted(date: .long, time: .shortened))
    ///             .textSelection(.enabled)
    ///     }
    ///
    @_alwaysEmitIntoClient
    public static var enabled: EnabledTextSelectability {
        .init()
    }
}

@available(OpenSwiftUI_v3_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension TextSelectability where Self == DisabledTextSelectability {
    /// A selectability value that disables text selection by the person using your app.
    ///
    /// Use this property to disable text selection of views that
    /// you don't want people to select and copy, even if contained within an
    /// overall context that allows text selection.
    ///
    ///     content // Content that might contain Text views.
    ///        .textSelection(.disabled)
    ///        .padding()
    ///        .contentShape(Rectangle())
    ///        .gesture(someGesture)
    ///
    @_alwaysEmitIntoClient
    public static var disabled: DisabledTextSelectability {
        .init()
    }
}

// MARK: - EnabledTextSelectability

/// A selectability type that enables text selection by the person using your app.
///
/// Don't use this type directly. Instead, use ``TextSelectability/enabled``.
@available(OpenSwiftUI_v3_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct EnabledTextSelectability: TextSelectability {
    public static let allowsSelection: Bool = true

    @usableFromInline
    internal init() {
        _openSwiftUIEmptyStub()
    }
}

@available(*, unavailable)
extension EnabledTextSelectability: Sendable {}

// MARK: - DisabledTextSelectability

/// A selectability type that disables text selection by the person using your app.
///
/// Don't use this type directly. Instead, use ``TextSelectability/disabled``.
@available(OpenSwiftUI_v3_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct DisabledTextSelectability: TextSelectability {
    public static let allowsSelection: Bool = false

    @usableFromInline
    internal init() {
        _openSwiftUIEmptyStub()
    }
}

@available(*, unavailable)
extension DisabledTextSelectability: Sendable {}

// MARK: - TextAllowsSelection

package struct TextAllowsSelection: ViewInput {
    package static let defaultValue: Bool = false

    package typealias Value = Bool
}

// MARK: - TextSelectionForbidden

package struct TextSelectionForbidden: ViewInputBoolFlag {
    package init() {
        _openSwiftUIEmptyStub()
    }

    package typealias Value = Bool
}

// MARK: - PlatformTextSelectionRepresentation

package protocol PlatformTextSelectionRepresentation {
    static func makeSelectableText(
        resolvedText: Attribute<ResolvedStyledText>,
        inputs: _ViewInputs
    ) -> _ViewOutputs
}

extension _ViewInputs {
    package var textSelectionRepresentation: (any PlatformTextSelectionRepresentation.Type)? {
        get { base.textSelectionRepresentation }
        set { base.textSelectionRepresentation = newValue }
    }
}

extension _GraphInputs {
    private struct TextSelectionRepresentationKey: GraphInput {
        static var defaultValue: (any PlatformTextSelectionRepresentation.Type)? { nil }
    }

    package var textSelectionRepresentation: (any PlatformTextSelectionRepresentation.Type)? {
        get { self[TextSelectionRepresentationKey.self] }
        set { self[TextSelectionRepresentationKey.self] = newValue }
    }
}
