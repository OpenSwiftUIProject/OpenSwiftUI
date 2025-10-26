//
//  AnyStyleContext.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 95C35B9B1549B6F41E131C274C6E343F (SwiftUICore)

// MARK: - AnyStyleContextType

package struct AnyStyleContextType: Equatable {
    private let base: any AnyStyleContextTypeBox.Type

    private init(base: any AnyStyleContextTypeBox.Type) {
        self.base = base
    }

    package init<C>(_ context: C.Type = C.self) where C: StyleContext {
        base = StyleContextTypeBox<C>.self
    }

    package static func == (lhs: AnyStyleContextType, rhs: AnyStyleContextType) -> Bool {
        lhs.base.isEqual(to: rhs.base)
    }

    package func acceptsTop<Q>(_ query: Q.Type) -> Bool {
        base.acceptsTop(query)
    }

    package func pushing<N>(_ newContext: N.Type) -> AnyStyleContextType where N: StyleContext {
        AnyStyleContextType(base: base.pushing(newContext))
    }

    package func acceptsAny<each Q>(_ queries: repeat (each Q).Type) -> Bool where repeat each Q: StyleContext {
        base.acceptsAny(repeat each queries)
    }
}

// MARK: - AnyStyleContextTypeBox

private protocol AnyStyleContextTypeBox {
    static func isEqual(to other: AnyStyleContextTypeBox.Type) -> Bool

    static func acceptsTop<Q>(_ query: Q.Type) -> Bool

    static func acceptsAny<each Q>(_ queries: repeat (each Q).Type) -> Bool where repeat each Q: StyleContext

    static func pushing<N>(_ newContext: N.Type) -> AnyStyleContextTypeBox.Type where N: StyleContext
}

// MARK: - StyleContextTypeBox

private struct StyleContextTypeBox<Context>: AnyStyleContextTypeBox where Context: StyleContext {
    static func isEqual(to other: AnyStyleContextTypeBox.Type) -> Bool {
        other is StyleContextTypeBox<Context>.Type
    }

    static func acceptsTop<Q>(_ query: Q.Type) -> Bool {
        Context.acceptsTop(query)
    }

    static func acceptsAny<each Q>(_ queries: repeat (each Q).Type) -> Bool where repeat each Q: StyleContext {
        Context.acceptsAny(repeat each queries)
    }

    static func pushing<N>(_ newContext: N.Type) -> AnyStyleContextTypeBox.Type where N: StyleContext {
        StyleContextTypeBox<TupleStyleContext<(N, Context)>>.self
    }
}
