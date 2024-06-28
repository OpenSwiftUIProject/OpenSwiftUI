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
    public typealias Root = _VariadicView_Root
    public typealias ViewRoot = _VariadicView_ViewRoot
    public typealias Children = _VariadicView_Children
//    public typealias UnaryViewRoot = _VariadicView_UnaryViewRoot
//    public typealias MultiViewRoot = _VariadicView_MultiViewRoot

    @frozen
    public struct Tree<Root: _VariadicView_Root, Content> {
        public var root: Root
        public var content: Content
        @inlinable
        init(root: Root, content: Content) {
            self.root = root
            self.content = content
        }

        @inlinable public init(_ root: Root, @ViewBuilder content: () -> Content) {
            self.root = root
            self.content = content()
        }
    }
}

extension _VariadicView_ViewRoot {
    func bodyError() -> Never {
        fatalError("body() should not be called on \(Self.self)")
    }
}

extension _VariadicView_ViewRoot where Body == Never {
    public func body(children: _VariadicView.Children) -> Never {
        bodyError()
    }
}
