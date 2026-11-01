//
//  ForEach+Subviews.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - ForEach + Subviews

@available(OpenSwiftUI_v6_0, *)
extension ForEach {
    @_spi(_)
    @available(*, deprecated, renamed: "init(subviews:content:)")
    public init<V>(
        elementOf view: V,
        @ViewBuilder content: @escaping (Subview) -> Content
    ) where Data == ForEachSubviewCollection<Content>, ID == Subview.ID, Content: View, V: View {
        self.init(subviews: view, content: content)
    }

    @_spi(_)
    @available(*, deprecated, renamed: "init(subviews:content:)")
    public init<V>(
        subviewOf view: V,
        @ViewBuilder content: @escaping (Subview) -> Content
    ) where Data == ForEachSubviewCollection<Content>, ID == Subview.ID, Content: View, V: View {
        self.init(subviews: view, content: content)
    }

    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the subviews of a given view.
    ///
    /// Subviews are proxies to the resolved view they represent, meaning
    /// that modifiers applied to the original view will be applied before
    /// modifiers applied to the subview, and the view is resolved
    /// using the environment of its container, *not* the environment of
    /// its subview proxy. Additionally, because subviews must represent a
    /// single leaf view, or container, a subview may represent a view after the
    /// application of styles. As such, attempting to apply a style to it may
    /// have no effect.
    ///
    /// - Parameters:
    ///   - view: The view to extract the subviews of.
    ///   - content: The view builder that creates views from subviews.
    public init<V>(
        subviews view: V,
        @ViewBuilder content: @escaping (Subview) -> Content
    ) where Data == ForEachSubviewCollection<Content>, ID == Subview.ID, Content: View, V: View {
        self.init(
            ForEachSubviewCollection(elementOf: view, content: content),
            id: \.id,
            content: content
        )
    }
}

// MARK: - ForEachSubviewCollection

/// A collection which allows a view to be treated as a collection of its
/// subviews in a for each loop.
@available(OpenSwiftUI_v6_0, *)
public struct ForEachSubviewCollection<Content>: RandomAccessCollection where Content: View {
    var substituteView: AnyView

    init<V>(elementOf view: V, content: @escaping (Subview) -> Content) where V: View {
        substituteView = AnyView(GroupElementsOfContent(subviews: view) { subviews in
            ForEach(subviews) { subview in
                content(subview)
            }
        })
    }

    public var startIndex: Int {
        _openSwiftUIUnreachableCode()
    }

    public var endIndex: Int {
        _openSwiftUIUnreachableCode()
    }

    public subscript(index: Int) -> Subview {
        _openSwiftUIUnreachableCode()
    }
}

@available(*, unavailable)
extension ForEachSubviewCollection: Sendable {}
