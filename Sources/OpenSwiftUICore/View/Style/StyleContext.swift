//
//  StyleContext.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 2EF43D8D991A83294E93848563DD541B (SwiftUICore)

// MARK: - StyleContext

package protocol StyleContext {
    static func accepts<Q>(_: Q.Type, at: Int) -> Bool

    static func acceptsAny<each Q>(_ queries: repeat (each Q).Type) -> Bool where repeat each Q: StyleContext

    static func visitStyle<V>(_ visitor: inout V) where V: StyleContextVisitor
}

extension StyleContext {
    package static func visitStyle<V>(_ visitor: inout V) where V: StyleContextVisitor {
        visitor.visit(Self.self)
    }

    package static func accepts<Q>(_ query: Q.Type, at: Int) -> Bool {
        Self.self == query
    }

    package static func acceptsAny<each Q>(_ queries: repeat (each Q).Type) -> Bool where repeat each Q: StyleContext {
        var visitor = QueryVisitor<Self>()
        for query in repeat each queries {
            query.visitStyle(&visitor)
            guard !visitor.accepts else {
                return true
            }
        }
        return visitor.accepts
    }

    package static func acceptsTop<Q>(_ query: Q.Type) -> Bool {
        accepts(query, at: 0)
    }
}

// TODO

// MARK: - StyleContextAcceptsPredicate [WIP]

package struct StyleContextAcceptsPredicate<Query>: ViewInputPredicate {
    package init() {}

    package static func evaluate(inputs: _GraphInputs) -> Bool {
        preconditionFailure("TODO")
    }
}

package struct StyleContextAcceptsAnyPredicate<each Query>: ViewInputPredicate where repeat each Query: StyleContext {
    package init() {}

    package static func evaluate(inputs: _GraphInputs) -> Bool {
        preconditionFailure("TODO")
    }
}

// TODO

// MARK: - StyleContextVisitor

package protocol StyleContextVisitor {
    mutating func visit<C>(_ context: C.Type) where C: StyleContext
}

// MARK: - QueryVisitor

private struct QueryVisitor<Context>: StyleContextVisitor where Context: StyleContext {
    var accepts: Bool = false

    mutating func visit<C>(_ context: C.Type) where C : StyleContext {
        accepts = accepts ? true : Context.self == context
    }
}
