//
//  EquatableView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 93C51C71D9D4CBAB391E78A2AAC640D6 (SwiftUI)

import OpenGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - EquatableView

/// A view type that compares itself against its previous value and prevents its
/// child updating if its new value is the same as its old value.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct EquatableView<Content>: View, UnaryView, PrimitiveView where Content: Equatable, Content: View {
    public var content: Content
    
    @inlinable
    public init(content: Content) {
        self.content = content
    }
    
    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let child = Child(view: view.value)
        return Content.makeDebuggableView(
            view: _GraphValue(child),
            inputs: inputs
        )
    }
    
    private struct Child: Rule, AsyncAttribute {
        @Attribute var view: EquatableView
        
        typealias Value = Content

        var value: Value {
            view.content
        }
        
        static var comparisonMode: ComparisonMode {
            .equatableAlways
        }
    }
}

@available(*, unavailable)
extension EquatableView: Sendable {}

extension View where Self: Equatable {
    /// Prevents the view from updating its child view when its new value is the
    /// same as its old value.
    @inlinable
    nonisolated public func equatable() -> EquatableView<Self> {
        EquatableView(content: self)
    }
}

// MARK: - EquatableProxyView

package struct EquatableProxyView<Content, Token>: View, UnaryView, PrimitiveView where Content: View, Token: Equatable {
    package var content: Content

    package var token: Token

    package init(content: Content, token: Token) {
        self.content = content
        self.token = token
    }

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        let child = Child(view: view.value, lastToken: nil)
        return Content.makeDebuggableView(
            view: _GraphValue(child),
            inputs: inputs
        )
    }
    
    private struct Child: StatefulRule, AsyncAttribute {
        @Attribute var view: EquatableProxyView
        var lastToken: Token?

        init(view: Attribute<EquatableProxyView>, lastToken: Token?) {
            self._view = view
            self.lastToken = lastToken
        }
        
        typealias Value = Content

        mutating func updateValue() {
            guard hasValue && lastToken == view.token else {
                value = view.content
                lastToken = view.token
                return
            }
        }
    }
}

extension View {
    /// Prevents the view from updating its child view when its new value is the
    /// same as its old value.
    nonisolated package func equatableProxy<Token>(_ token: Token) -> EquatableProxyView<Self, Token> where Token: Equatable {
        EquatableProxyView(content: self, token: token)
    }
}
