//
//  Section.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 323999C1FFD4730F4D14ABD69CA73C8C (SwiftUI)

public import OpenSwiftUICore

// MARK: - Section

/// A container view that you can use to add hierarchy within certain views.
///
/// Use `Section` instances in views like ``List``, ``Picker``, and
/// ``Form`` to organize content into separate sections. Each section has
/// custom content that you provide on a per-instance basis. You can also
/// provide headers and footers for each section.
///
/// ### Collapsible sections
///
/// Create sections that expand and collapse by using an initializer that
/// accepts an `isExpanded` binding. A collapsible section in a ``List`` that
/// uses the ``ListStyle/sidebar`` style shows a disclosure indicator next to
/// the section's header. Tapping on the disclosure indicator toggles the
/// appearance of the section's content.
///
/// > Note: Not all contexts provide a default control to trigger collapse or
///   expansion.
@available(OpenSwiftUI_v1_0, *)
public struct Section<Parent, Content, Footer> {
    var header: Parent
    var content: Content
    var footer: Footer
    var isExpanded: Binding<Bool>?

    init(header: Parent, content: Content, footer: Footer) {
        self.header = header
        self.content = content
        self.footer = footer
        isExpanded = nil
    }
}

@available(*, unavailable)
extension Section: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension Section: View, PrimitiveView, PubliclyPrimitiveView where Parent: View, Content: View, Footer: View {
    public typealias Body = Never

    var internalBody: some View {
        ResolvedSectionStyle(configuration: .init(isExpanded: isExpanded))
            .viewAlias(SectionStyleConfiguration.Header.self) {
                header.accessibilityConfiguration(
                    AccessibilityTraitsModifier(traits: .init(trait: .isHeader))
                )
            }
            .viewAlias(SectionStyleConfiguration.Footer.self) {
                footer
            }
            .viewAlias(SectionStyleConfiguration.RawContent.self) {
                content._trait(SectionActionsTraitKey.self, nil)
            }
    }

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        defaultViewListCount(inputs: inputs)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Section where Parent: View, Content: View, Footer: View {
    /// Creates a section with a header, footer, and the provided section
    /// content.
    ///
    /// - Parameters:
    ///   - content: The section's content.
    ///   - header: A view to use as the section's header.
    ///   - footer: A view to use as the section's footer.
    @_alwaysEmitIntoClient
    public init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Parent,
        @ViewBuilder footer: () -> Footer
    ) {
        self.init(header: header(), footer: footer(), content: content)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Section where Parent == EmptyView, Content: View, Footer: View {
    /// Creates a section with a footer and the provided section content.
    /// - Parameters:
    ///   - content: The section's content.
    ///   - footer: A view to use as the section's footer.
    @_alwaysEmitIntoClient
    public init(@ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer) {
        self.init(footer: footer(), content: content)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Section where Parent: View, Content: View, Footer == EmptyView {
    /// Creates a section with a header and the provided section content.
    /// - Parameters:
    ///   - content: The section's content.
    ///   - header: A view to use as the section's header.
    @_alwaysEmitIntoClient
    public init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Parent) {
        self.init(header: header(), content: content)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Section where Parent == EmptyView, Content: View, Footer == EmptyView {
    /// Creates a section with the provided section content.
    /// - Parameters:
    ///   - content: The section's content.
    public init(@ViewBuilder content: () -> Content) {
        self.init(header: EmptyView(), content: content(), footer: EmptyView())
    }
}

@available(OpenSwiftUI_v3_0, *)
extension Section where Parent == Text, Content: View, Footer == EmptyView {
    /// Creates a section with the provided section content.
    /// - Parameters:
    ///   - titleKey: The key for the section's localized title, which describes
    ///     the contents of the section.
    ///   - content: The section's content.
    public init(_ titleKey: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.init(header: Text(titleKey), content: content(), footer: EmptyView())
    }

    /// Creates a section with the provided section content.
    /// - Parameters:
    ///   - title: A string that describes the contents of the section.
    ///   - content: The section's content.
    @_disfavoredOverload
    public init<S>(_ title: S, @ViewBuilder content: () -> Content) where S: StringProtocol {
        self.init(header: Text(title), content: content(), footer: EmptyView())
    }
}

@available(OpenSwiftUI_v5_0, *)
extension Section where Parent == Text, Content: View, Footer == EmptyView {
    /// Creates a section with the provided section content.
    /// - Parameters:
    ///   - titleKey: The key for the section's localized title, which describes
    ///     the contents of the section.
    ///   - isExpanded: A binding to a Boolean value that determines the section's
    ///    expansion state (expanded or collapsed).
    ///   - content: The section's content.
    public init(
        _ titleKey: LocalizedStringKey,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.init(isExpanded: isExpanded, content: content) {
            Text(titleKey)
        }
    }

    /// Creates a section with the provided section content.
    /// - Parameters:
    ///   - title: A string that describes the contents of the section.
    ///   - isExpanded: A binding to a Boolean value that determines the section's
    ///    expansion state (expanded or collapsed).
    ///   - content: The section's content.
    @_disfavoredOverload
    public init<S>(
        _ title: S,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) where S: StringProtocol {
        self.init(isExpanded: isExpanded, content: content) {
            Text(title)
        }
    }
}

@_spi(Private)
@available(OpenSwiftUI_iOS_v4_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Section where Parent: View, Content: View, Footer: View {
    /// Sets whether a `Section` can be collapsed by the user.
    ///
    /// Currently this modifier only applies to sections in `.sidebar`-styled
    /// `List` views.
    public func collapsible(_ collapsible: Bool) -> some View {
        environment(\.canCollapseSections, collapsible)
    }
}

// MARK: - IsCollapsibleTraitKey

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
struct IsCollapsibleTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: Bool { true }
}

@available(*, unavailable)
extension IsCollapsibleTraitKey: Sendable {}

@available(OpenSwiftUI_v5_0, *)
extension Section where Parent: View, Content: View, Footer == EmptyView {
    /// Creates a section with a header, the provided section content, and a binding
    /// representing the section's expansion state.
    ///
    /// - Parameters:
    ///   - isExpanded: A binding to a Boolean value that determines the section's
    ///    expansion state (expanded or collapsed).
    ///   - content: The section's content.
    ///   - header: A view to use as the section's header.
    public init(
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Parent
    ) {
        self.content = content()
        self.header = header()
        footer = EmptyView()
        self.isExpanded = isExpanded
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Section where Parent: View, Content: View, Footer: View {
    /// Creates a section with a header, footer, and the provided section content.
    /// - Parameters:
    ///   - header: A view to use as the section's header.
    ///   - footer: A view to use as the section's footer.
    ///   - content: The section's content.
    @available(iOS, deprecated: 100000.0, renamed: "Section(content:header:footer:)")
    @available(macOS, deprecated: 100000.0, renamed: "Section(content:header:footer:)")
    @available(tvOS, deprecated: 100000.0, renamed: "Section(content:header:footer:)")
    @available(watchOS, deprecated: 100000.0, renamed: "Section(content:header:footer:)")
    @available(visionOS, deprecated: 100000.0, renamed: "Section(content:header:footer:)")
    public init(header: Parent, footer: Footer, @ViewBuilder content: () -> Content) {
        self.init(header: header, content: content(), footer: footer)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Section where Parent == EmptyView, Content: View, Footer: View {
    /// Creates a section with a footer and the provided section content.
    /// - Parameters:
    ///   - footer: A view to use as the section's footer.
    ///   - content: The section's content.
    @available(iOS, deprecated: 100000.0, renamed: "Section(content:footer:)")
    @available(macOS, deprecated: 100000.0, renamed: "Section(content:footer:)")
    @available(tvOS, deprecated: 100000.0, renamed: "Section(content:footer:)")
    @available(watchOS, deprecated: 100000.0, renamed: "Section(content:footer:)")
    @available(visionOS, deprecated: 100000.0, renamed: "Section(content:footer:)")
    public init(footer: Footer, @ViewBuilder content: () -> Content) {
        self.init(header: EmptyView(), content: content(), footer: footer)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Section where Parent: View, Content: View, Footer == EmptyView {
    /// Creates a section with a header and the provided section content.
    /// - Parameters:
    ///   - header: A view to use as the section's header.
    ///   - content: The section's content.
    @available(iOS, deprecated: 100000.0, renamed: "Section(content:header:)")
    @available(macOS, deprecated: 100000.0, renamed: "Section(content:header:)")
    @available(tvOS, deprecated: 100000.0, renamed: "Section(content:header:)")
    @available(watchOS, deprecated: 100000.0, renamed: "Section(content:header:)")
    @available(visionOS, deprecated: 100000.0, renamed: "Section(content:header:)")
    public init(header: Parent, @ViewBuilder content: () -> Content) {
        self.init(header: header, content: content(), footer: EmptyView())
    }
}

// MARK: - EnvironmentValues + canCollapseSections

extension EnvironmentValues {
    var canCollapseSections: Bool {
        get { self[CollapsibleSectionsEnvironmentKey.self] }
        set { self[CollapsibleSectionsEnvironmentKey.self] = newValue }
    }
}

private struct CollapsibleSectionsEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool { true }
}
