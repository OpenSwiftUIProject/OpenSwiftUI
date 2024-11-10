//
//  ModifiedContent.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

extension View {
    @inlinable
    public func modifier<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        .init(content: self, modifier: modifier)
    }
}

/// A value with a modifier applied to it.
@frozen
public struct ModifiedContent<Content, Modifier> {
    public typealias Body = Never
    
    /// The content that the modifier transforms into a new view or new
    /// view modifier.
    public var content: Content
    
    /// The view modifier.
    public var modifier: Modifier

    /// A structure that the defines the content and modifier needed to produce
    /// a new view or view modifier.
    ///
    /// If `content` is a ``View`` and `modifier` is a ``ViewModifier``, the
    /// result is a ``View``. If `content` and `modifier` are both view
    /// modifiers, then the result is a new ``ViewModifier`` combining them.
    ///
    /// - Parameters:
    ///     - content: The content that the modifier changes.
    ///     - modifier: The modifier to apply to the content.
    @inlinable
    public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }
}

extension ModifiedContent: Equatable where Content: Equatable, Modifier: Equatable {
    public static func == (a: ModifiedContent<Content, Modifier>, b: ModifiedContent<Content, Modifier>) -> Bool {
        a.content == b.content && a.modifier == b.modifier
    }
}

extension ModifiedContent: View where Content: View, Modifier: ViewModifier {
    public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        _ViewDebug.makeView(
            view: view[offset: { .of(&$0.modifier) }],
            inputs: inputs
        ) { modifier, inputs in
            Modifier._makeView(
                modifier: modifier,
                inputs: inputs
            ) { _, inputs in
                _ViewDebug.makeView(
                    view: view[offset: { .of(&$0.content) }],
                    inputs: inputs
                ) { view, inputs in
                    Content._makeView(view: view, inputs: inputs)
                }
            }
        }
    }
    
    public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        Modifier.makeDebuggableViewList(
            modifier: view[offset: { .of(&$0.modifier) }],
            inputs: inputs
        ) { _, inputs in
            Content.makeDebuggableViewList(
                view: view[offset: { .of(&$0.content) }],
                inputs: inputs
            )
        }
    }
    
    public static func _viewListCount(
        inputs: _ViewListCountInputs
    ) -> Int? {
        Modifier._viewListCount(inputs: inputs) { inputs in
            Content._viewListCount(inputs: inputs)
        }
    }
    
    public var body: ModifiedContent<Content, Modifier>.Body {
        bodyError()
    }
}

extension ModifiedContent: ViewModifier where Content: ViewModifier, Modifier: ViewModifier {
//    public static func _makeView(modifier: _GraphValue<ModifiedContent<Content, Modifier>>, inputs: _ViewInputs, body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> _ViewOutputs {
//
//    }
//    public static func _makeViewList(modifier: _GraphValue<ModifiedContent<Content, Modifier>>, inputs: _ViewListInputs, body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> _ViewListOutputs {
//
//    }
//    public static func _viewListCount(inputs: _ViewListCountInputs, body: (_ViewListCountInputs) -> Int?) -> Int? {
//
//    }
}

extension ViewModifier {
    /// Returns a new modifier that is the result of concatenating
    /// `self` with `modifier`.
    @inlinable
    @inline(__always)
    public func concat<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        .init(content: self, modifier: modifier)
    }
}
