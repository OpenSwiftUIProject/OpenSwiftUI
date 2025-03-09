//
//  VariadicView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 00F12C0E37A19C593ECA0DBD3BE26541 (SwiftUI)
//  ID: DC167C463E6601B3880A23A75ACAA63B (SwiftUICore)

package import OpenGraphShims

// MARK: - _VariadicView

/// A type of structured content that is passed as an argument to a
/// `Root`'s result builder, creating a `Tree` that conditionally conforms
/// to protocols like `View`.
///
/// For example, `View`s  can be passed to a `Layout` result builder
/// creating a `View`:
///
///     HStack {
///         Image(name: "envelope")
///         Text("Your time away request has been approved")
///         Spacer()
///         Text(timestamp, format: .dateTime).layoutPriority(1)
///     }
///     
public enum _VariadicView {
    /// A type that creates a `Tree`, managing content subtrees passed as
    /// result builder arguments.
    ///
    /// For example, a layout arranges an arbitrary number of children:
    ///
    ///     HStack {
    ///         Image(name: "envelope")
    ///         Text("Your time away request has been approved")
    ///         Spacer()
    ///         Text(timestamp, format: .dateTime).layoutPriority(1)
    ///     }
    ///     
    public typealias Root = _VariadicView_Root

    /// A type of root that creates a View when its result builder is invoked with View.
    public typealias ViewRoot = _VariadicView_ViewRoot

    /// An ad hoc collection of the children of a variadic view.
    public typealias Children = _VariadicView_Children

    public typealias UnaryViewRoot = _VariadicView_UnaryViewRoot

    public typealias MultiViewRoot = _VariadicView_MultiViewRoot

    package typealias AnyImplicitRoot = _VariadicView_AnyImplicitRoot

    package typealias ImplicitRoot = _VariadicView_ImplicitRoot

    package typealias ImplicitRootVisitor = _VariadicView_ImplicitRootVisitor

    /// A rooted tuple of content subtrees.
    ///
    /// A `Tree` is created by invoking the `Root` result builder with an
    /// arbitrary number of content subtrees.
    ///
    /// Depending on the type of `Root` and `Content`, `Tree` will
    /// conditionally conform to protocols like `View`.
    @frozen
    public struct Tree<Root, Content> where Root: _VariadicView.Root {
        public var root: Root
        public var content: Content

        @inlinable
        init(root: Root, content: Content) {
            self.root = root
            self.content = content
        }

        @inlinable
        public init(_ root: Root, @ViewBuilder content: () -> Content) {
            self.root = root
            self.content = content()
        }
    }
}

@available(*, unavailable)
extension _VariadicView.Tree: Sendable {}

@available(*, unavailable)
extension _VariadicView: Sendable {}

// MARK: - _VariadicView.Root

/// A type that creates a `Tree`, managing content subtrees passed to a result builder.
///
/// - SeeAlso: _VariadicView.Root.
public protocol _VariadicView_Root {
    static var _viewListOptions: Int { get }
}

extension _VariadicView.Root {
    public static var _viewListOptions: Int { 0 }

    package static var viewListOptions: _ViewListInputs.Options {
        .init(rawValue: _viewListOptions)
    }

    public static func _viewListCount(
        inputs _: _ViewListCountInputs,
        body _: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        nil
    }
}

// MARK: - ViewListOptionsInput

package struct ViewListOptionsInput: ViewInput {
    package static let defaultValue: _ViewListInputs.Options = []
}

extension _GraphInputs {
    @inline(__always)
    var viewListOptions: _ViewListInputs.Options {
        get { self[ViewListOptionsInput.self] }
        set { self[ViewListOptionsInput.self] = newValue }
    }
}

extension _ViewInputs {
    @inline(__always)
    var viewListOptions: _ViewListInputs.Options {
        get { self[ViewListOptionsInput.self] }
        set { self[ViewListOptionsInput.self] = newValue }
    }
}

extension _ViewListInputs {
    @inline(__always)
    var viewListOptions: _ViewListInputs.Options {
        get { self[ViewListOptionsInput.self] }
        set { self[ViewListOptionsInput.self] = newValue }
    }
}

extension _ViewListCountInputs {
    @inline(__always)
    var viewListOptions: _ViewListInputs.Options {
        get { self[ViewListOptionsInput.self] }
        set { self[ViewListOptionsInput.self] = newValue }
    }
}

// MARK: - _VariadicView.ViewRoot

/// A type of root that creates a `View` when its result builder is invoked with
///  `View`.
///
/// - SeeAlso: _VariadicView.ViewRoot.
/// - Note: Requirements mirror `View`'s.
public protocol _VariadicView_ViewRoot: _VariadicView.Root {
    static func _makeView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewListOutputs
    ) -> _ViewOutputs

    static func _makeViewList(
        root: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs

    static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int?

    associatedtype Body: View

    @ViewBuilder
    func body(children: _VariadicView.Children) -> Body
}

extension _VariadicView.ViewRoot where Body == Never {
    public func body(children: _VariadicView.Children) -> Never {
        preconditionFailure("body() should not be called on \(Self.self).")
    }
}

// MARK: - _VariadicView.UnaryViewRoot

public protocol _VariadicView_UnaryViewRoot: _VariadicView.ViewRoot {}

extension _VariadicView.UnaryViewRoot {
    nonisolated public static func _makeViewList(
        root: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        let weakRoot = WeakAttribute(root.value)
        return .unaryViewList(viewType: Self.self, inputs: inputs) { inputs in
            guard let attribute = weakRoot.attribute else {
                return .init()
            }
            return _makeView(root: _GraphValue(attribute), inputs: inputs) { graph, inputs in
                body(graph, _ViewListInputs(inputs.base))
            }
        }
    }

    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        1
    }
}

// MARK: - _VariadicView.MultiViewRoot

public protocol _VariadicView_MultiViewRoot: _VariadicView.ViewRoot {}

extension _VariadicView.MultiViewRoot {
    nonisolated public static func _makeView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewListOutputs
    ) -> _ViewOutputs {
        withoutActuallyEscaping(body) { escapingBody in
            .multiView(inputs: inputs) { graph, inputs in
                let listOutputs = escapingBody(graph, inputs)
                let list = listOutputs.makeAttribute(inputs: _ViewListInputs(inputs.base))
                let fields = DynamicPropertyCache.fields(of: Self.self)
                var inputs = inputs
                let (body, buffer) = makeBody(root: root, list: list, inputs: &inputs.base, fields: fields)
                let implicitRootBodyInputs = inputs.implicitRootBodyInputs
                let outputs = Body.makeDebuggableViewList(view: body, inputs: implicitRootBodyInputs)
                if let buffer {
                    buffer.traceMountedProperties(to: body, fields: fields)
                }
                return outputs
            }
        }
    }

    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }
}

// MARK: - _VariadicView.Children

/// An ad hoc collection of the children of a variadic view.
public struct _VariadicView_Children {
    package var list: any ViewList

    package var contentSubgraph: Subgraph

    package var transform: ViewList.SublistTransform

    package init(_ list: any ViewList, contentSubgraph: Subgraph, transform: ViewList.SublistTransform = .init()) {
        self.list = list
        self.contentSubgraph = contentSubgraph
        self.transform = transform
    }

    package var content: ViewList.Backing {
        ViewList.Backing(self)
    }
}

@available(*, unavailable)
extension _VariadicView.Children: Sendable {}

// MARK: - _VariadicView.ViewRoot + View Extension

extension _VariadicView.ViewRoot {
    nonisolated public static func _makeView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewListOutputs
    ) -> _ViewOutputs {
        makeView(root: root, inputs: inputs, body: body)
    }

    nonisolated public static func _makeViewList(
        root: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        makeViewList(root: root, inputs: inputs, body: body)
    }

    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        Body._viewListCount(inputs: inputs)
    }

    nonisolated static func makeView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewListOutputs
    ) -> _ViewOutputs {
        let listOutputs = body(_Graph(), inputs)
        let list = listOutputs.makeAttribute(inputs: _ViewListInputs(inputs.base))
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (body, buffer) = makeBody(root: root, list: list, inputs: &inputs.base, fields: fields)
        let outputs = Body.makeDebuggableView(view: body, inputs: inputs)
        if let buffer {
            buffer.traceMountedProperties(to: body, fields: fields)
        }
        return outputs
    }

    nonisolated static func makeViewList(
        root: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        let listOutputs = body(_Graph(), inputs)
        let list = listOutputs.makeAttribute(inputs: _ViewListInputs(inputs.base))
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (body, buffer) = makeBody(root: root, list: list, inputs: &inputs.base, fields: fields)
        let outputs = Body.makeDebuggableViewList(view: body, inputs: inputs)
        if let buffer {
            buffer.traceMountedProperties(to: body, fields: fields)
        }
        return outputs
    }

    nonisolated fileprivate static func makeBody(
        root: _GraphValue<Self>,
        list: Attribute<any ViewList>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        let kind = Metadata(Self.self).kind
        switch kind {
        case .struct, .enum, .optional, .tuple:
            let accessor = ViewRootBodyAccessor<Self>(list: list, contentSubgraph: .current!)
            return accessor.makeBody(container: root, inputs: &inputs, fields: fields)
        default:
            preconditionFailure("views root must be value types (either a struct or an enum); \(Self.self) is a class.")
        }
    }
}

// MARK: - ViewRootBodyAccessor

private struct ViewRootBodyAccessor<Root>: BodyAccessor where Root: _VariadicView.ViewRoot {
    typealias Container = Root

    typealias Body = Root.Body

    @Attribute var list: any ViewList

    var contentSubgraph: Subgraph

    func updateBody(of container: Container, changed: Bool) {
        let (list, listChanged) = $list.changedValue()
        guard changed || listChanged else {
            return
        }
        let children = _VariadicView.Children(list, contentSubgraph: contentSubgraph)
        setBody {
            container.body(children: children)
        }
    }
}

// MARK: - _VariadicView.Tree + View

extension _VariadicView.Tree: View where Root: _VariadicView.ViewRoot, Content: View {
    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var inputs = inputs
        inputs.viewListOptions = Root.viewListOptions
        return Root._makeView(
            root: view[offset: {.of(&$0.root)}],
            inputs: inputs
        ) { graph, inputs in
            return Content.makeDebuggableViewList(
                view: view[offset: {.of(&$0.content)}],
                inputs: _ViewListInputs(inputs.base, options: inputs.viewListOptions)
            )
        }
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        inputs.viewListOptions = Root.viewListOptions
        return Root._makeViewList(
            root: view[offset: {.of(&$0.root)}],
            inputs: inputs
        ) { graph, inputs in
            var inputs = inputs
            inputs.options.formUnion(inputs.viewListOptions)
            return Content.makeDebuggableViewList(
                view: view[offset: {.of(&$0.content)}],
                inputs: inputs
            )
        }
    }

    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        var inputs = inputs
        inputs.viewListOptions = Root.viewListOptions
        return Root._viewListCount(inputs: inputs) { inputs in
            var inputs = inputs
            inputs.options.formUnion(inputs.viewListOptions)
            return Content._viewListCount(inputs: inputs)
        }
    }
}

extension _VariadicView.Tree: PrimitiveView where Root: _VariadicView.ViewRoot, Content: View {}

extension _VariadicView.Tree: UnaryView where Root: _VariadicView.ViewRoot, Content: View {}

// MARK: - _VariadicView.AnyImplicitRoot

package protocol _VariadicView_AnyImplicitRoot {
    static func visitType<V>(visitor: inout V) where V: _VariadicView.ImplicitRootVisitor
}

// MARK: - _VariadicView.ImplicitRoot

package protocol _VariadicView_ImplicitRoot: _VariadicView.AnyImplicitRoot, _VariadicView.ViewRoot {
    static var implicitRoot: Self { get }
}

// MARK: - _VariadicView.ImplicitRootVisitor

package protocol _VariadicView_ImplicitRootVisitor {
    mutating func visit<R>(type: R.Type) where R: _VariadicView.ImplicitRoot
}

extension _VariadicView.ImplicitRoot {
    package static func visitType<V>(visitor: inout V) where V: _VariadicView.ImplicitRootVisitor {
        visitor.visit(type: Self.self)
    }
}

// MARK: - ImplicitRootType

private struct ImplicitRootType: ViewInput {
    static let defaultValue: _VariadicView_AnyImplicitRoot.Type = CoreGlue.shared.defaultImplicitRootType.value
}

// MARK: - _ViewInputs + ImplicitRoot

extension _ViewInputs {
    package var implicitRootType: any _VariadicView.AnyImplicitRoot.Type {
        get { self[ImplicitRootType.self] }
        set { self[ImplicitRootType.self] = newValue }
    }

    package var implicitRootBodyInputs: _ViewListInputs {
        let options = viewListOptions
        return _ViewListInputs(
            base,
            options: options.union(_SemanticFeature_v2.isEnabled ? [] : .disableTransitions)
        )
    }
}

// MARK: - _ViewListInputs + ImplicitRoot

extension _ViewListInputs {
    package var implicitRootType: any _VariadicView.AnyImplicitRoot.Type {
        get { self[ImplicitRootType.self] }
        set { self[ImplicitRootType.self] = newValue }
    }
}

// MARK: - MakeViewRoot

private struct MakeViewRoot: _VariadicView.ImplicitRootVisitor {
    var inputs: _ViewInputs

    var body: (_Graph, _ViewInputs) -> _ViewListOutputs

    var outputs: _ViewOutputs?

    mutating func visit<R>(type: R.Type) where R : _VariadicView_ImplicitRoot {
        let attribute = inputs.intern(R.implicitRoot, id: .implicitRoot)
        inputs.viewListOptions = R.viewListOptions
        let root = _GraphValue(attribute)
        outputs = R._makeView(
            root: _GraphValue(attribute),
            inputs: inputs,
            body: body
        )
    }
}

// MARK: - MakeModifiedRoot

private struct MakeModifiedRoot<Modifier>: _VariadicView.ImplicitRootVisitor where Modifier: ViewModifier {
    var modifier: _GraphValue<Modifier>

    var inputs: _ViewInputs

    var body: (_Graph, _ViewInputs) -> _ViewListOutputs

    var outputs: _ViewOutputs?

    mutating func visit<R>(type: R.Type) where R : _VariadicView_ImplicitRoot {
        let attribute = inputs.intern(R.implicitRoot, id: .implicitRoot)
        inputs.viewListOptions = R.viewListOptions
        let body = body
        outputs = Modifier.makeDebuggableView(
            modifier: modifier,
            inputs: inputs
        ) { graph, inputs in
            R._makeView(
                root: _GraphValue(attribute),
                inputs: inputs,
                body: body
            )
        }
    }
}

// MARK: - _ViewOutputs + multiView

extension _ViewOutputs {
    package static func multiView(
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewListOutputs
    ) -> _ViewOutputs {
        let implicitRootType = inputs.implicitRootType
        var visitor = MakeViewRoot(inputs: inputs, body: body)
        implicitRootType.visitType(visitor: &visitor)
        return visitor.outputs!
    }

    fileprivate static func multiView<Modifier> (
        applying modifier: _GraphValue<Modifier>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewListOutputs
    ) -> _ViewOutputs where Modifier: ViewModifier {
        let implicitRootType = inputs.implicitRootType
        var visitor = MakeModifiedRoot(modifier: modifier, inputs: inputs, body: body)
        implicitRootType.visitType(visitor: &visitor)
        return visitor.outputs!
    }
}

// MARK: - View + ImplicitRoot

extension View {
    nonisolated package static func makeImplicitRoot(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        .multiView(inputs: inputs) { _, inputs in
            makeDebuggableViewList(view: view, inputs: inputs.implicitRootBodyInputs)
        }
    }
}

// MARK: - ViewModifier + ImplicitRoot

extension ViewModifier {
    nonisolated package static func makeImplicitRoot(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewOutputs {
        .multiView(
            applying: modifier,
            inputs: inputs
        ) { graph, inputs in
            body(graph, inputs.implicitRootBodyInputs)
        }
    }
}
