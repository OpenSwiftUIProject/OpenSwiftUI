//
//  ForEach+Sections.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - ForEach + Sections

@available(OpenSwiftUI_v6_0, *)
extension ForEach {
    @_spi(_)
    @available(*, deprecated, renamed: "init(sections:content:)")
    public init<V>(
        sectionOf view: V,
        @ViewBuilder content: @escaping (SectionConfiguration) -> Content
    ) where Data == ForEachSectionCollection<Content>, ID == SectionConfiguration.ID, Content: View, V: View {
        self.init(sections: view, content: content)
    }

    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the sections of a given view.
    ///
    /// - Parameters:
    ///   - view: The view to extract the sections of.
    ///   - content: The view builder that creates views from sections
    public init<V>(
        sections view: V,
        @ViewBuilder content: @escaping (SectionConfiguration) -> Content
    ) where Data == ForEachSectionCollection<Content>, ID == SectionConfiguration.ID, Content: View, V: View {
        self.init(
            ForEachSectionCollection(subviewOf: view, content: content),
            id: \.id,
            content: content
        )
    }
}

// MARK: - ForEachSectionCollection

/// A collection which allows a view to be treated as a collection of its
/// sections in a for each loop.
///
/// You don't use this type directly. Instead OpenSwiftUI creates this type on
/// your behalf.
@available(OpenSwiftUI_v6_0, *)
public struct ForEachSectionCollection<Content>: RandomAccessCollection where Content: View {
    var substituteView: AnyView

    init<V>(subviewOf view: V, content: @escaping (SectionConfiguration) -> Content) where V: View {
        substituteView = AnyView(Group(sections: view) { sections in
            ForEach(sections, content: content)
        })
    }

    public var startIndex: Int {
        _openSwiftUIUnreachableCode()
    }

    public var endIndex: Int {
        _openSwiftUIUnreachableCode()
    }

    public subscript(index: Int) -> SectionConfiguration {
        _openSwiftUIUnreachableCode()
    }
}

@available(*, unavailable)
extension ForEachSectionCollection: Sendable {}
