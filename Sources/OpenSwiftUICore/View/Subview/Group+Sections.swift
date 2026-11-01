//
//  Group+Sections.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims

// MARK: - Group + Sections

@available(OpenSwiftUI_v6_0, *)
extension Group {
    @_spi(_)
    @available(*, deprecated, renamed: "init(sections:transform:)")
    public init<Base, Result>(
        sectionsOf view: Base,
        @ViewBuilder transform: @escaping (SectionCollection) -> Result
    ) where Content == GroupSectionsOfContent<Base, Result>, Base: View, Result: View {
        self.init(sections: view, transform: transform)
    }

    /// Constructs a group from the sections of the given view.
    ///
    /// Sections are constructed lazily, on demand, so access only as much
    /// of this collection as is necessary to create the resulting content.
    ///
    ///     struct SectionedStack<Content: View>: View {
    ///         var content: Content
    ///
    ///         init(@ViewBuilder content: () -> Content) {
    ///             self.content = content()
    ///         }
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Group(sections: content) { sections in
    ///                     ForEach(sections) { section in
    ///                         SectionChrome {
    ///                             section.content
    ///                         } header: {
    ///                             section.header
    ///                         } footer: {
    ///                             section.footer
    ///                         }
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// This can then be used by creating a `SectionedStack` with its
    /// view builder-based initializer.
    ///
    ///     SectionedStack {
    ///         Section("Header A") {
    ///             Text("Hello")
    ///             Text("World")
    ///         } footer: {
    ///             Text("Footer A")
    ///         }
    ///         Section("Header B") {
    ///             Text("Foo")
    ///             Text("Bar")
    ///         } footer: {
    ///             Text("Footer B")
    ///         }
    ///     }
    ///
    /// Any content of the given view which is not explicitly specified as a
    /// section is grouped with its sibling content to form implicit sections.
    /// For example in the following `SectionedStack`, there is one explicit
    /// section, and two implicit sections containing the content before,
    /// and after the explicit section:
    ///
    ///     SectionedStack {
    ///         Text("First implicit section")
    ///         Section("Explicit section") {
    ///             Text("Content")
    ///         }
    ///         Text("Second implicit section")
    ///     }
    ///
    /// - Parameters:
    ///   - view: The view to extract the sections of.
    ///   - transform: A closure that constructs a view from the collection of
    ///     sections.
    public init<Base, Result>(
        sections view: Base,
        @ViewBuilder transform: @escaping (SectionCollection) -> Result
    ) where Content == GroupSectionsOfContent<Base, Result>, Base: View, Result: View {
        self.init {
            GroupSectionsOfContent(sections: view, content: transform)
        }
    }
}

// MARK: - GroupSectionsOfContent

/// Transforms the sections of a given view into a resulting content view.
///
/// You don't use this type directly. Instead OpenSwiftUI creates this type on
/// your behalf.
@available(OpenSwiftUI_v6_0, *)
public struct GroupSectionsOfContent<Sections, Content>: View where Sections: View, Content: View {
    let sections: Sections
    let content: (SectionCollection) -> Content

    init(sections: Sections, content: @escaping (SectionCollection) -> Content) {
        if sections is SubviewsCollection {
            Log.externalWarning("Group(sections:) or ForEach(sections:) was passed a SubviewsCollection. These APIs do not support nested sectioning. Attempting to use them this way will result in losing sectioning information.")
        }
        self.sections = sections
        self.content = content
    }

    public var body: some View {
        _VariadicView.Tree(SectionsRoot(content: content)) {
            sections
        }
    }
}

@available(*, unavailable)
extension GroupSectionsOfContent: Sendable {}

// MARK: - SectionCollection

/// An opaque collection representing the sections of view.
///
/// Sections are constructed lazily, on demand, so access only as much
/// of this collection as is necessary to create the resulting content.
///
/// You can get access to a view's ``SectionCollection`` by using the
/// ``Group/init(sections:transform:)`` initializer.
///
/// Any content of the given view which is not explicitly specified as a section
/// is grouped with its sibling content to form implicit sections.
@available(OpenSwiftUI_v6_0, *)
public struct SectionCollection: RandomAccessCollection {
    let base: [SectionConfiguration]

    public subscript(index: Int) -> SectionConfiguration { base[index] }

    public var startIndex: Int { base.startIndex }

    public var endIndex: Int { base.endIndex }
}

@available(*, unavailable)
extension SectionCollection: Sendable {}

// MARK: - SectionConfiguration

/// Specifies the contents of a section.
///
/// A `SectionConfiguration` includes the content of the section, as well as
/// its header and footer.
///
/// A `SectionConfiguration` can represent either an explicit section,
/// or groups of sibling views that are not explicitly wrapped in a section.
///
/// Notably, the `header`, `footer` and `content` properties of a
/// `SectionConfiguration` are all `SubviewsCollection`s as they can be made up
/// of multiple subviews. That means in most cases, the subviews collection
/// should be treated as a collection (either indexed into, or used with a
/// `ForEach`), or the subviews collection should be wrapped in a container
/// view, like a layout, or other custom container:
///
///     PinboardSectionsLayout {
///         ForEach(sections: content) { section in
///             VStack {
///                 HStack { section.header }
///                 section.content
///                 HStack { section.footer }
///             }
///         }
///     }
///
/// Here, we want to create one view for `PinboardSectionsLayout` to place per
/// section in content. To do that, we surround the `ForEach` body in another
/// container, a `VStack` layout, ensuring the different subviews of
/// section.content are treated as a single view by the surrounding layout.
/// Additionally, surrounding the header and footer in an `HStack` layout
/// avoids vertically stacking subviews of the header and footer
/// which we want visually grouped together.
@available(OpenSwiftUI_v6_0, *)
public struct SectionConfiguration: Identifiable {
    let item: SectionAccumulator.Item

    /// A unique identifier for a section.
    public struct ID: Hashable {
        let base: AnyHashable
    }

    /// A unique identifier representing the section.
    public var id: ID { ID(base: AnyHashable(item.id)) }

    /// The container values associated with the given section.
    ///
    /// Only explicitly created sections are able to have container values,
    /// meaning this container values will be empty if the section is implicit.
    public var containerValues: ContainerValues {
        ContainerValues(base: item.sectionList?.traits ?? ViewTraitCollection())
    }

    var hasSubsections: Bool {
        !item.features.contains(.implicit) && item.hasRows
    }

    /// The contents of the section header.
    ///
    /// Notably, the section's header is a `SubviewsCollection`, not a
    /// `Subview`, as it can be made up of multiple subviews. That means in most
    /// cases, the subviews collection should be treated as a collection (either
    /// indexed into, or used with a `ForEach`), or the subviews collection
    /// should be wrapped in a container view, like a layout, or other custom
    /// container:
    ///
    ///     ForEach(sections: content) { section in
    ///         VStack {
    ///             HStack { section.header }
    ///             HStack { section.footer }
    ///         }
    ///     }
    ///
    /// Here, we surround the header and footer in an `HStack` layout to avoid
    /// vertically stacking the subviews of the header and footer which we want
    /// visually grouped together. Additionally, we surround the `ForEach` body
    /// in a VStack, so it is treated as a single view by containers it gets
    /// passed to.
    public var header: SubviewsCollection {
        if item.headerCount > 0, let section = item.sectionList {
            SubviewsCollection(
                list: section.header.list,
                contentSubgraph: item.contentSubgraph!,
                transform: item.transform
            )
        } else {
            SubviewsCollection(list: EmptyViewList(), contentSubgraph: item.contentSubgraph!, transform: .init())
        }
    }

    /// The contents of the section footer.
    ///
    /// Notably, the section's footer is a `SubviewsCollection`, not a
    /// `Subview`, as it can be made up of multiple subviews. That means in most
    /// cases, the subviews collection should be treated as a collection (either
    /// indexed into, or used with a `ForEach`), or the subviews collection
    /// should be wrapped in a container view, like a layout, or other custom
    /// container:
    ///
    ///     ForEach(sections: content) { section in
    ///         VStack {
    ///             HStack { section.header }
    ///             HStack { section.footer }
    ///         }
    ///     }
    ///
    /// Here, we surround the header and footer in an `HStack` layout to avoid
    /// vertically stacking the subviews of the header and footer which we want
    /// visually grouped together. Additionally, we surround the `ForEach` body
    /// in a VStack, so it is treated as a single view by containers it gets
    /// passed to.
    public var footer: SubviewsCollection {
        if item.footerCount > 0, let section = item.sectionList {
            SubviewsCollection(
                list: section.footer.list,
                contentSubgraph: item.contentSubgraph!,
                transform: item.transform
            )
        } else {
            SubviewsCollection(list: EmptyViewList(), contentSubgraph: item.contentSubgraph!, transform: .init())
        }
    }

    /// The contents of the section body.
    ///
    /// Notably, the section's content is a `SubviewsCollection`, not a
    /// `Subview`, as it can be made up of multiple subviews. That means in most
    /// cases, the subviews collection should be treated as a collection (either
    /// indexed into, or used with a `ForEach`), or the subviews collection
    /// should be wrapped in a container view, like a layout, or other custom
    /// container:
    ///
    ///     PinboardSectionsLayout {
    ///         ForEach(sections: content) { section in
    ///             VStack {
    ///                 section.content
    ///             }
    ///         }
    ///     }
    ///
    /// Here, we want to create one view for `PinboardSectionsLayout` to place
    /// per section in content. To do that, we surround the `ForEach` body in
    /// another container, a `VStack` layout, ensuring the different subviews of
    /// section.content are treated as a single view by the surrounding layout.
    public var content: SubviewsCollection {
        if let section = item.sectionList {
            SubviewsCollection(
                list: section.content.list,
                contentSubgraph: item.contentSubgraph!,
                transform: item.transform
            )
        } else {
            SubviewsCollection(
                list: ViewListSlice(base: item.list, bounds: item.start ..< item.start + item.count),
                contentSubgraph: item.contentSubgraph!,
                transform: item.transform
            )
        }
    }
}

@available(*, unavailable)
extension SectionConfiguration: Sendable {}

@available(*, unavailable)
extension SectionConfiguration.ID: Sendable {}

// MARK: - SectionsRoot

struct SectionsRoot<Content>: _VariadicView.MultiViewRoot where Content: View {
    var content: (SectionCollection) -> Content

    static var _viewListOptions: Int {
        Int(_ViewListInputs.Options([
            .requiresDepthAndSections,
            .requiresSections,
            .allowsNestedSections,
        ]).rawValue)
    }

    nonisolated static func _makeView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewListOutputs
    ) -> _ViewOutputs {
        withoutActuallyEscaping(body) { body in
            .multiView(inputs: inputs) { graph, inputs in
                let outputs = body(graph, inputs)
                let list = outputs.makeAttribute(inputs: _ViewListInputs(inputs.base))
                let child = _GraphValue(Child(
                    view: root.value,
                    viewList: list,
                    contentSubgraph: Subgraph.current!
                ))
                return Content.makeDebuggableViewList(view: child, inputs: inputs.implicitRootBodyInputs)
            }
        }
    }

    nonisolated static func _makeViewList(
        root: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        let outputs = body(.init(), inputs)
        let list = outputs.makeAttribute(inputs: inputs)
        let child = _GraphValue(Child(
            view: root.value,
            viewList: list,
            contentSubgraph: Subgraph.current!
        ))
        return Content.makeDebuggableViewList(view: child, inputs: inputs)
    }

    typealias Body = Never

    struct Child: Rule {
        @Attribute var view: SectionsRoot
        @Attribute var viewList: any ViewList
        var contentSubgraph: Subgraph

        var value: Content {
            let items: [SectionAccumulator.Item]
            if let unsectioned = SectionAccumulator.processUnsectionedContent(
                list: viewList,
                contentSubgraph: contentSubgraph
            ) {
                items = unsectioned
            } else {
                var accumulator = SectionAccumulator(contentSubgraph: contentSubgraph)
                accumulator.formResult(from: viewList, listAttribute: $viewList)
                items = accumulator.items
            }
            return view.content(SectionCollection(base: items.map { SectionConfiguration(item: $0) }))
        }
    }
}
