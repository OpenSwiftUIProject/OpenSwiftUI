//
//  Group.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C1B8B6896BB94C69479F427820712D02 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - Group

/// A type that collects multiple instances of a content type --- like views,
/// scenes, or commands --- into a single unit.
///
/// Use a group to collect multiple views into a single instance, without
/// affecting the layout of those views, like an ``OpenSwiftUI/HStack``,
/// ``OpenSwiftUI/VStack``, or ``OpenSwiftUI/Section`` would. After creating a group,
/// any modifier you apply to the group affects all of that group's members.
/// For example, the following code applies the ``OpenSwiftUI/Font/headline``
/// font to three views in a group.
///
///     Group {
///         Text("OpenSwiftUI")
///         Text("Combine")
///         Text("Swift System")
///     }
///     .font(.headline)
///
/// Because you create a group of views with a ``OpenSwiftUI/ViewBuilder``, you can
/// use the group's initializer to produce different kinds of views from a
/// conditional, and then optionally apply modifiers to them. The following
/// example uses a `Group` to add a navigation bar title,
/// regardless of the type of view the conditional produces:
///
///     Group {
///         if isLoggedIn {
///             WelcomeView()
///         } else {
///             LoginView()
///         }
///     }
///     .navigationBarTitle("Start")
///
/// The modifier applies to all members of the group --- and not to the group
/// itself. For example, if you apply ``View/onAppear(perform:)`` to the above
/// group, it applies to all of the views produced by the `if isLoggedIn`
/// conditional, and it executes every time `isLoggedIn` changes.
///
/// Because a group of views itself is a view, you can compose a group within
/// other view builders, including nesting within other groups. This allows you
/// to add large numbers of views to different view builder containers. The
/// following example uses a `Group` to collect 10 ``OpenSwiftUI/Text`` instances,
/// meaning that the vertical stack's view builder returns only two views ---
/// the group, plus an additional ``OpenSwiftUI/Text``:
///
///     var body: some View {
///         VStack {
///             Group {
///                 Text("1")
///                 Text("2")
///                 Text("3")
///                 Text("4")
///                 Text("5")
///                 Text("6")
///                 Text("7")
///                 Text("8")
///                 Text("9")
///                 Text("10")
///             }
///             Text("11")
///         }
///     }
///
/// You can initialize groups with several types other than ``OpenSwiftUI/View``,
/// such as ``OpenSwiftUI/Scene`` and ``OpenSwiftUI/ToolbarContent``. The closure you
/// provide to the group initializer uses the corresponding builder type
/// (``OpenSwiftUI/SceneBuilder``, ``OpenSwiftUI/ToolbarContentBuilder``, and so on),
/// and the capabilities of these builders vary between types. For example,
/// you can use groups to return large numbers of scenes or toolbar content
/// instances, but not to return different scenes or toolbar content based
/// on conditionals.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct Group<Content> {

    public typealias Body = Never

    @usableFromInline
    package var content: Content

    @_disfavoredOverload
    @_alwaysEmitIntoClient
    internal init(_content: Content) {
        self.content = _content
    }
}

@available(*, unavailable)
extension Group: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension Group {

    
    @available(OpenSwiftUI_v1_0, *)
    @_alwaysEmitIntoClient
    public static func _make(content: Content) -> Group<Content> {
        self.init(_content: content)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension Group: View, MultiView, PrimitiveView where Content: View {

    /// Creates a group of views.
    /// - Parameter content: A ``OpenSwiftUI/ViewBuilder`` that produces the views
    /// to group.
    @inlinable
    nonisolated public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        _VariadicView.Tree.makeDebuggableViewList(
            view: view.unsafeBitCast(to: _VariadicView.Tree<GroupContainer, Content>.self),
            inputs: inputs
        )
    }

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        Content._viewListCount(inputs: inputs)
    }
}

// MARK: - _ViewListOutputs + Group

extension _ViewListOutputs {
    package static func sectionListOutputs(
        _ outputs: [_ViewListOutputs],
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        var nextImplicitID = inputs.implicitID
        var staticCount: Int? = 0
        var lists: [Attribute<any ViewList>] = []
        for output in outputs {
            let list = output.makeAttribute(inputs: inputs)
            lists.append(list)
            nextImplicitID = output.nextImplicitID
            if let currentStaticCount = staticCount,
               let outputStaticCount = output.staticCount {
                staticCount = outputStaticCount &+ currentStaticCount
            } else {
                staticCount = nil
            }
        }
        if inputs.options.contains(.sectionsConcatenateFooter) {
            lists[1] = Attribute(ViewList.Group.Init(lists: .init(lists.dropFirst())))
            lists[2] = inputs.base.intern(EmptyViewList(), id: .defaultValue)
        }
        let section = Attribute(
            MakeSection(
                lists: lists,
                isHierarchical: inputs.options.contains(.sectionsAreHierarchical),
                traits: inputs._traits
            )
        )
        return _ViewListOutputs(
            .dynamicList(section, nil),
            nextImplicitID: nextImplicitID,
            staticCount: staticCount
        )
    }

    @inline(__always)
    private static func groupViewListOptions(
        from options: _ViewListInputs.Options
    ) -> _ViewListInputs.Options {
        var optionsWithoutNestedSections = options
        if optionsWithoutNestedSections.contains(.requiresNonEmptyGroupParent) {
            optionsWithoutNestedSections.subtract([.requiresNonEmptyGroupParent, .allowsNestedSections])
        }
        if optionsWithoutNestedSections.contains(.requiresSections) {
            optionsWithoutNestedSections.subtract([.requiresSections, .allowsNestedSections])
        }
        if options.contains(.allowsNestedSections) {
            return options
        } else {
            return optionsWithoutNestedSections
        }
    }

    package static func groupViewList<Parent, Footer>(
        parent: _GraphValue<Parent>,
        footer: Attribute<Footer>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs where Parent: View, Footer: View {
        let options = inputs.options
        let groupOptionss = groupViewListOptions(from: options)

        var headerInputs = inputs
        headerInputs.options = groupOptionss
        if options.contains(.requiresDepthAndSections) {
            headerInputs.traits = Attribute(SectionedTrait(traits: headerInputs._traits))
            headerInputs.addTraitKey(IsSectionedTraitKey.self)
        }

        if options.contains(.requiresNonEmptyGroupParent) {
            headerInputs.options.insert(.isNonEmptyParent)
            headerInputs.traits = Attribute(SectionHeaderTrait(traits: headerInputs._traits))
            headerInputs.addTraitKey(IsSectionHeaderTraitKey.self)
        }
        if options.contains(.resetHeaderStyleContext) {
            headerInputs.base.resetStyleContext()
        }
        let headerOutputs = Parent.makeDebuggableViewList(
            view: parent,
            inputs: headerInputs
        )

        var contentInputs = inputs
        contentInputs.implicitID = headerOutputs.nextImplicitID
        contentInputs.options = groupOptionss
        if options.contains(.requiresDepthAndSections) {
            contentInputs.traits = Attribute(DepthTrait(traits: headerInputs._traits))
            contentInputs.addTraitKey(DepthTraitKey.self)
        }
        let contentOutputs = body(.init(), contentInputs)

        var footerInputs = inputs
        footerInputs.implicitID = contentOutputs.nextImplicitID
        footerInputs.options = groupOptionss
        if options.contains(.requiresNonEmptyGroupParent) {
            footerInputs.options.subtract(.requiresNonEmptyGroupParent)
            footerInputs.traits = Attribute(SectionFooterTrait(traits: footerInputs._traits))
            footerInputs.addTraitKey(IsSectionFooterTraitKey.self)
        }
        if options.contains(.resetFooterStyleContext) {
            footerInputs.base.resetStyleContext()
        }
        let footerOutputs = Footer.makeDebuggableViewList(
            view: .init(footer),
            inputs: footerInputs
        )

        let outputs = [headerOutputs, contentOutputs, footerOutputs]
        if options.contains(.requiresSections) {
            return .sectionListOutputs(outputs, inputs: inputs)
        } else {
            return .concat(outputs, inputs: inputs)
        }
    }

    package static func groupViewListCount<V, H, F>(
        inputs: _ViewListCountInputs,
        contentType: V.Type,
        headerType: H.Type,
        footerType: F.Type
    ) -> Int? where V: View, H: View, F: View {
        let options = inputs.options
        let groupOptionss = groupViewListOptions(from: options)

        var contentInputs = inputs
        contentInputs.options = groupOptionss
        guard let contentCount = V._viewListCount(inputs: contentInputs) else {
            return nil
        }
        var count = contentCount

        var headerOptions = groupOptionss
        if options.contains(.requiresNonEmptyGroupParent) {
            headerOptions.insert(.isNonEmptyParent)
        }
        var headerInputs = inputs
        headerInputs.options = headerOptions
        if options.contains(.resetHeaderStyleContext) {
            headerInputs.resetStyleContext()
        }
        guard let headerCount = H._viewListCount(inputs: headerInputs) else {
            return nil
        }
        count += headerCount

        var footerOptions = groupOptionss
        if options.contains(.requiresNonEmptyGroupParent) {
            footerOptions.remove(.requiresNonEmptyGroupParent)
        }
        var footerInputs = inputs
        footerInputs.options = footerOptions
        if options.contains(.resetFooterStyleContext) {
            footerInputs.resetStyleContext()
        }
        guard let footerCount = F._viewListCount(inputs: footerInputs) else {
            return nil
        }
        count += footerCount
        return count
    }

    package static func nonEmptyParentViewList(
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        var newInputs = inputs
        newInputs.traits = Attribute(EmptyViewTrait(traits: inputs._traits))
        newInputs.addTraitKey(IsEmptyViewTraitKey.self)
        let view = newInputs.base.intern(_UnaryViewAdaptor(EmptyView()), id: .defaultValue)
        return unaryViewList(
            view: .init(view),
            inputs: newInputs
        )
    }
}

// MARK: - DepthTrait

package struct DepthTrait: Rule {
    @OptionalAttribute
    private var traits: ViewTraitCollection?

    package init(traits: OptionalAttribute<ViewTraitCollection>) {
        _traits = traits
    }

    package var value: ViewTraitCollection {
        var traits = traits ?? .init()
        traits.groupDepth += 1
        return traits
    }
}

// MARK: - SectionHeaderTrait

package struct SectionHeaderTrait: Rule {
    @OptionalAttribute
    private var traits: ViewTraitCollection?

    package init(traits: OptionalAttribute<ViewTraitCollection>) {
        _traits = traits
    }

    package var value: ViewTraitCollection {
        var traits = traits ?? .init()
        traits.isSectionHeader = true
        return traits
    }
}

// MARK: - DepthTraitKey

/// The trait key for the depth of a view – the number of `Group`s a view is
/// nested within.
///
/// The default is `0`.
@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package struct DepthTraitKey: _ViewTraitKey {
    @inlinable
    package static var defaultValue: Int { 0 }
}

@available(*, unavailable)
extension DepthTraitKey: Sendable {}

extension ViewTraitCollection {
    package var groupDepth: Int {
        get { self[DepthTraitKey.self] }
        set { self[DepthTraitKey.self] = newValue }
    }
}

// MARK: - IsSectionedTraitKey

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package struct IsSectionedTraitKey: _ViewTraitKey {
    @inlinable
    package static var defaultValue: Bool { false }
}

@available(*, unavailable)
extension IsSectionedTraitKey: Sendable {}

extension ViewTraitCollection {
    package var isSectioned: Bool {
        get { self[IsSectionedTraitKey.self] }
        set { self[IsSectionedTraitKey.self] = newValue }
    }
}

extension View {
    @MainActor
    @preconcurrency
    package func definesSection() -> some View {
        _trait(IsSectionedTraitKey.self, true)
    }
}

// MARK: - IsEmptyViewTraitKey

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package struct IsEmptyViewTraitKey: _ViewTraitKey {
    @inlinable
    package static var defaultValue: Bool { false }
}

@available(*, unavailable)
extension IsEmptyViewTraitKey: Sendable {}

extension ViewTraitCollection {
    package var isEmptyView: Bool {
        get { self[IsEmptyViewTraitKey.self] }
        set { self[IsEmptyViewTraitKey.self] = newValue }
    }
}

// MARK: - IsSectionHeaderTraitKey

@available(OpenSwiftUI_v4_0, *)
@usableFromInline
package struct IsSectionHeaderTraitKey: _ViewTraitKey {
    @inlinable
    package static var defaultValue: Bool { false }
}

@available(*, unavailable)
extension IsSectionHeaderTraitKey: Sendable {}

extension ViewTraitCollection {
    package var isSectionHeader: Bool {
        get { self[IsSectionHeaderTraitKey.self] }
        set { self[IsSectionHeaderTraitKey.self] = newValue }
    }
}

// MARK: - IsSectionFooterTraitKey

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package struct IsSectionFooterTraitKey: _ViewTraitKey {
    @inlinable
    package static var defaultValue: Bool { false }
}

@available(*, unavailable)
extension IsSectionFooterTraitKey: Sendable {}

extension ViewTraitCollection {
    package var isSectionFooter: Bool {
        get { self[IsSectionFooterTraitKey.self] }
        set { self[IsSectionFooterTraitKey.self] = newValue }
    }
}

// MARK: - EmptyViewTrait

private struct EmptyViewTrait: Rule {
    @OptionalAttribute
    var traits: ViewTraitCollection?

    init(traits: OptionalAttribute<ViewTraitCollection>) {
        _traits = traits
    }

    var value: ViewTraitCollection {
        var traits = traits ?? .init()
        traits.isEmptyView = true
        return traits
    }
}

// MARK: - SectionedTrait

private struct SectionedTrait: Rule {
    @OptionalAttribute
    var traits: ViewTraitCollection?

    init(traits: OptionalAttribute<ViewTraitCollection>) {
        _traits = traits
    }

    var value: ViewTraitCollection {
        var traits = traits ?? .init()
        traits.isSectioned = true
        return traits
    }
}

// MARK: - SectionFooterTrait

private struct SectionFooterTrait: Rule {
    @OptionalAttribute
    var traits: ViewTraitCollection?

    init(traits: OptionalAttribute<ViewTraitCollection>) {
        _traits = traits
    }

    var value: ViewTraitCollection {
        var traits = traits ?? .init()
        traits.isSectionFooter = true
        return traits
    }
}

// MARK: - MakeSection

private struct MakeSection: Rule {
    var lists: [Attribute<any ViewList>]
    var isHierarchical: Bool
    @OptionalAttribute var traits: ViewTraitCollection?

    var value: any ViewList {
        ViewList.Section(
            id: attribute.identifier.rawValue,
            base: ViewList.Group(lists: lists.map { ($0.value, $0) }),
            traits: traits ?? .init(),
            isHierarchical: isHierarchical
        )
    }
}

// MARK: - GroupContainer

private struct GroupContainer: _VariadicView_MultiViewRoot {
    nonisolated static func _makeViewList(
        root: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        body(_Graph(), inputs)
    }
}
