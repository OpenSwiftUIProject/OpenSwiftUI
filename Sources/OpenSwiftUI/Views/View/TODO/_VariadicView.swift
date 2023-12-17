public enum _VariadicView {
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

public protocol _VariadicView_Root {
    static var _viewListOptions: Int { get }
}

// FIXME
extension _VariadicView_Root {
  public static var _viewListOptions: Int {
      0
  }
}

protocol _VariadicView_ViewRoot: _VariadicView_Root, View {
    associatedtype Body
}

extension _HStackLayout: _VariadicView_Root {}
