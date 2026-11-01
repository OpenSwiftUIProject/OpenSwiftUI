//
//  Group+Subviews.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B0B39CD9AD4D5C78B1166BFF4E214610 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - Group + Subviews

@available(OpenSwiftUI_v6_0, *)
extension Group {
    @_spi(_)
    @available(*, deprecated, renamed: "init(subviews:transform:)")
    public init<Base, Result>(
        elementsOf view: Base,
        @ViewBuilder transform: @escaping (SubviewsCollection) -> Result
    ) where Content == GroupElementsOfContent<Base, Result>, Base: View, Result: View {
        self.init(subviews: view, transform: transform)
    }

    @_spi(_)
    @available(*, deprecated, renamed: "init(subviews:transform:)")
    public init<Base, Result>(
        subviewsOf view: Base,
        @ViewBuilder transform: @escaping (SubviewsCollection) -> Result
    ) where Content == GroupElementsOfContent<Base, Result>, Base: View, Result: View {
        self.init(subviews: view, transform: transform)
    }

    /// Constructs a group from the subviews of the given view.
    ///
    /// Use this initializer to create a group that gives you programmatic
    /// access to the group's subviews. The following `CardsView` defines the
    /// group's structure based on the set of views that you provide to it:
    ///
    ///     struct CardsView<Content: View>: View {
    ///         var content: Content
    ///
    ///         init(@ViewBuilder content: () -> Content) {
    ///             self.content = content()
    ///         }
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Group(subviews: content) { subviews in
    ///                     HStack {
    ///                         if subviews.count >= 2 {
    ///                             SecondaryCard { subviews[1] }
    ///                         }
    ///                         if let first = subviews.first {
    ///                             FeatureCard { first }
    ///                         }
    ///                         if subviews.count >= 3 {
    ///                             SecondaryCard { subviews[2] }
    ///                         }
    ///                     }
    ///                     if subviews.count > 3 {
    ///                         subviews[3...]
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// You can use `CardsView` with its view builder-based initializer to
    /// arrange a collection of subviews:
    ///
    ///     CardsView {
    ///         NavigationLink("What's New!") { WhatsNewView() }
    ///         NavigationLink("Latest Hits") { LatestHitsView() }
    ///         NavigationLink("Favorites") { FavoritesView() }
    ///         NavigationLink("Playlists") { MyPlaylists() }
    ///     }
    ///
    /// Subviews collection constructs subviews on demand, so only access the
    /// part of the collection you need to create the resulting content.
    ///
    /// Subviews are proxies to the view they represent, which means
    /// that modifiers that you apply to the original view take effect before
    /// modifiers that you apply to the subview. OpenSwiftUI resolves the view
    /// using the environment of its container rather than the environment of
    /// its subview proxy. Additionally, because subviews represent a
    /// single view or container, a subview might represent a view after the
    /// application of styles. As a result, applying a style to a subview might
    /// have no effect.
    ///
    /// - Parameters:
    ///   - view: The view to get the subviews of.
    ///   - transform: A closure that constructs a view from the collection of
    ///     subviews.
    public init<Base, Result>(
        subviews view: Base,
        @ViewBuilder transform: @escaping (SubviewsCollection) -> Result
    ) where Content == GroupElementsOfContent<Base, Result>, Base: View, Result: View {
        self.init {
            GroupElementsOfContent(subviews: view, content: transform)
        }
    }
}

// MARK: - GroupElementsOfContent

/// Transforms the subviews of a given view into a resulting content view.
///
/// You don't use this type directly. Instead OpenSwiftUI creates this type on
/// your behalf.
@available(OpenSwiftUI_v6_0, *)
public struct GroupElementsOfContent<Subviews, Content>: View where Subviews: View, Content: View {
    enum Storage {
        case subviewsCollection(SubviewsCollection)
        case view(Subviews)
    }

    let storage: Storage
    let content: (SubviewsCollection) -> Content

    @usableFromInline
    package init(subviews: Subviews, content: @escaping (SubviewsCollection) -> Content) {
        if let subviews = subviews as? SubviewsCollection {
            storage = .subviewsCollection(subviews)
        } else {
            storage = .view(subviews)
        }
        self.content = content
    }

    public var body: some View {
        switch storage {
        case let .subviewsCollection(subviews):
            content(subviews)
        case let .view(view):
            _VariadicView.Tree(SubviewsRoot(content: content)) {
                view
            }
        }
    }
}

@available(*, unavailable)
extension GroupElementsOfContent: Sendable {}

// MARK: - SubviewsCollection

/// An opaque collection representing the subviews of a view.
///
/// Subviews collection constructs subviews on demand, so only access the part
/// of the collection you need to create the resulting content.
///
/// You can get access to a view's subview collection by using the
/// ``Group/init(subviews:transform:)`` initializer.
///
/// The collection's elements are the pieces that make up the given view, and
/// the collection as a whole acts as a proxy for the original view.
@available(OpenSwiftUI_v6_0, *)
public struct SubviewsCollection: RandomAccessCollection {
    package var base: _VariadicView.Children

    package init(_ base: _VariadicView.Children) {
        self.base = base
    }

    package init(
        list: any ViewList,
        contentSubgraph: Subgraph,
        transform: ViewList.SublistTransform
    ) {
        base = _VariadicView.Children(list, contentSubgraph: contentSubgraph, transform: transform)
    }

    public func index(before i: Int) -> Int {
        base.index(before: i)
    }

    public func index(after i: Int) -> Int {
        base.index(after: i)
    }

    public subscript(index: Int) -> Subview {
        Subview(base[index])
    }

    public subscript(bounds: Range<Int>) -> SubviewsCollectionSlice {
        SubviewsCollectionSlice(base: Slice(base: self, bounds: bounds))
    }

    public var startIndex: Int { base.startIndex }

    public var endIndex: Int { base.endIndex }
}

@available(*, unavailable)
extension SubviewsCollection: Sendable {}

@available(OpenSwiftUI_v6_0, *)
extension SubviewsCollection: View, MultiView, PrimitiveView {
    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        _VariadicView.Children._makeViewList(
            view: view[offset: { .of(&$0.base) }],
            inputs: inputs
        )
    }

    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        nil
    }
}

// MARK: - SubviewsCollectionSlice

/// A slice of a SubviewsCollection.
@available(OpenSwiftUI_v6_0, *)
public struct SubviewsCollectionSlice: RandomAccessCollection {
    package var base: Slice<SubviewsCollection>

    public subscript(index: Int) -> Subview {
        base[index]
    }

    public subscript(bounds: Range<Int>) -> SubviewsCollectionSlice {
        SubviewsCollectionSlice(base: Slice(base: base.base, bounds: bounds))
    }

    public var startIndex: Int { base.startIndex }

    public var endIndex: Int { base.endIndex }
}

@available(*, unavailable)
extension SubviewsCollectionSlice: Sendable {}

@available(OpenSwiftUI_v6_0, *)
extension SubviewsCollectionSlice: View, MultiView, PrimitiveView {
    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        let child = _GraphValue(Child(slice: view[offset: { .of(&$0.base) }].value))
        return ForEach._makeViewList(view: child, inputs: inputs)
    }

    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        nil
    }

    private struct Child: Rule, AsyncAttribute {
        @Attribute var slice: Slice<SubviewsCollection>

        var value: ForEach<Slice<SubviewsCollection>, Subview.ID, Subview> {
            ForEach(slice) { $0 }
        }
    }
}

// MARK: - SubviewsRoot

package struct SubviewsRoot<Content>: _VariadicView.MultiViewRoot where Content: View {
    package let content: (SubviewsCollection) -> Content

    package func body(children: _VariadicView.Children) -> some View {
        content(SubviewsCollection(children))
    }
}
