//
//  StyleContext.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 2EF43D8D991A83294E93848563DD541B (SwiftUICore)

import OpenAttributeGraphShims
import OpenSwiftUI_SPI

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
        for query in repeat each queries {
            var visitor = QueryVisitor<Self>(accepts: false)
            query.visitStyle(&visitor)
            guard !visitor.accepts else {
                return true
            }
        }
        return false
    }

    package static func acceptsTop<Q>(_ query: Q.Type) -> Bool {
        accepts(query, at: 0)
    }
}

// MARK: - Concreate StyleContext

package struct WindowRootContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == WindowRootContext {
    package static var windowRoot: WindowRootContext {
        WindowRootContext()
    }
}

package struct AccessibilityRepresentableStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == AccessibilityRepresentableStyleContext {
    package static var accessibilityRepresentable: AccessibilityRepresentableStyleContext {
        AccessibilityRepresentableStyleContext()
    }
}

package struct AccessibilityQuickActionStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == AccessibilityQuickActionStyleContext {
    package static var accessibilityQuickAction: AccessibilityQuickActionStyleContext {
        AccessibilityQuickActionStyleContext()
    }
}

package struct ContainerStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == ContainerStyleContext {
    package static var container: ContainerStyleContext {
        ContainerStyleContext()
    }
}

package struct ContentListStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == ContentListStyleContext {
    package static var contentList: ContentListStyleContext {
        ContentListStyleContext()
    }
}

package struct DocumentStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == DocumentStyleContext {
    package static var document: DocumentStyleContext {
        DocumentStyleContext()
    }
}

package struct ControlGroupStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == ControlGroupStyleContext {
    package static var controlGroup: ControlGroupStyleContext {
        ControlGroupStyleContext()
    }
}

package struct DialogActionStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == DialogActionStyleContext {
    package static var dialogAction: DialogActionStyleContext {
        DialogActionStyleContext()
    }
}

package struct HostingConfigurationContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == HostingConfigurationContext {
    package static var hostingConfiguration: HostingConfigurationContext {
        HostingConfigurationContext()
    }
}

package struct MenuStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == MenuStyleContext {
    package static var menu: MenuStyleContext {
        MenuStyleContext()
    }
}

package struct MultimodalListContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == MultimodalListContext {
    package static var multimodalList: MultimodalListContext {
        MultimodalListContext()
    }
}

package struct MultimodalListGridContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == MultimodalListGridContext {
    package static var multimodalListGrid: MultimodalListGridContext {
        MultimodalListGridContext()
    }
}

package struct MultimodalListStackContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == MultimodalListStackContext {
    package static var multimodalListStack: MultimodalListStackContext {
        MultimodalListStackContext()
    }
}

package struct NoStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == NoStyleContext {
    package static var none: NoStyleContext {
        NoStyleContext()
    }
}

package struct ScrollViewStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == ScrollViewStyleContext {
    package static var scrollView: ScrollViewStyleContext {
        ScrollViewStyleContext()
    }
}

package struct TextInputSuggestionsContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == TextInputSuggestionsContext {
    package static var textInputSuggestions: TextInputSuggestionsContext {
        TextInputSuggestionsContext()
    }
}

package struct SectionHeaderStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == SectionHeaderStyleContext {
    package static var sectionHeader: SectionHeaderStyleContext {
        SectionHeaderStyleContext()
    }
}

package struct SheetStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == SheetStyleContext {
    package static var sheet: SheetStyleContext {
        SheetStyleContext()
    }
}

package struct SheetToolbarStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == SheetToolbarStyleContext {
    package static var sheetToolbar: SheetToolbarStyleContext {
        SheetToolbarStyleContext()
    }
}

package struct SidebarStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == SidebarStyleContext {
    package static var sidebar: SidebarStyleContext {
        SidebarStyleContext()
    }
}

package struct SwipeActionsStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == SwipeActionsStyleContext {
    package static var swipeActions: SwipeActionsStyleContext {
        SwipeActionsStyleContext()
    }
}

package struct TableStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == TableStyleContext {
    package static var table: TableStyleContext {
        TableStyleContext()
    }
}

package struct ToolbarStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == ToolbarStyleContext {
    package static var toolbar: ToolbarStyleContext {
        ToolbarStyleContext()
    }
}

package struct InspectorStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == InspectorStyleContext {
    package static var inspector: InspectorStyleContext {
        InspectorStyleContext()
    }
}

package struct MenuBarExtraWindowStyleContext: StyleContext {
    package init() {}
}

extension StyleContext where Self == MenuBarExtraWindowStyleContext {
    package static var menuBarExtraWindow: MenuBarExtraWindowStyleContext {
        MenuBarExtraWindowStyleContext()
    }
}

// MARK: View + StyleContext

@available(OpenSwiftUI_v1_0, *)
extension View {
    package func styleContext<C>(_ context: C) -> some View where C: StyleContext {
        modifier(StyleContextWriter<C>())
    }

    package func styleContext<C, P>(_ context: C, if predicate: P) -> some View where C: StyleContext, P: ViewInputPredicate {
        modifier(StyleContextWriter<C>().requiring(P.self))
    }

    package func styleContext<C, P>(_ context: C, in requiredContext: P) -> some View where C: StyleContext, P: StyleContext {
        modifier(StyleContextWriter<C>().requiring(P.self))
    }

    /// Sets the style context of `self` to the default context.
    nonisolated public func _defaultContext() -> some View {
        modifier(DefaultStyleContextWriter())
    }
}

// MARK: - StyleContextWriter

package struct StyleContextWriter<Context>: PrimitiveViewModifier, _GraphInputsModifier where Context: StyleContext {
    package init() {}

    package static func _makeInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) {
        inputs.styleContext = inputs.styleContext.pushing(Context.self)
    }
}

// MARK: - DefaultStyleContextWriter

package struct DefaultStyleContextWriter: PrimitiveViewModifier, _GraphInputsModifier {
    package static func _makeInputs(
        modifier: _GraphValue<DefaultStyleContextWriter>,
        inputs: inout _GraphInputs
    ) {
        inputs.styleContext = StyleContextInput.defaultValue
    }
}

// MARK: - StyleContextInput

package struct StyleContextInput: ViewInput {
    package static let defaultValue = AnyStyleContextType(NoStyleContext.self)
}

extension _GraphInputs {
    @inline(__always)
    var styleContext: AnyStyleContextType {
        get { self[StyleContextInput.self] }
        set { self[StyleContextInput.self] = newValue }
    }
}

// MARK: - StyleContextAcceptsPredicate

package struct StyleContextAcceptsPredicate<Query>: ViewInputPredicate {
    package init() {}

    package static func evaluate(inputs: _GraphInputs) -> Bool {
        inputs.styleContext.acceptsTop(Query.self)
    }
}

// MARK: - StyleContextAcceptsAnyPredicate

package struct StyleContextAcceptsAnyPredicate<each Query>: ViewInputPredicate where repeat each Query: StyleContext {
    package init() {}

    package static func evaluate(inputs: _GraphInputs) -> Bool {
        inputs.styleContext.acceptsAny(repeat (each Query).self)
    }
}

// MARK: - _GraphInputs + StyleContext

extension _GraphInputs {
    package var isDefaultStyleContext: Bool {
        styleContext == StyleContextInput.defaultValue
    }

    package func accepts<each C>(_ context: repeat each C) -> Bool where repeat each C: StyleContext {
        styleContext.acceptsAny(repeat (each C).self)
    }

    package mutating func pushStyleContext<C>(_ context: C) where C: StyleContext {
        styleContext = styleContext.pushing(C.self)
    }

    package mutating func resetStyleContext() {
        styleContext = StyleContextInput.defaultValue
    }

    package func printStyleContext() {
        print(styleContext)
    }
}

// MARK: - _ViewListCountInputs + StyleContext

extension _ViewListCountInputs {
    package mutating func resetStyleContext() {
        customInputs[StyleContextInput.self] = StyleContextInput.defaultValue
    }
}

// MARK: - StyleContextPrintingModifier

package typealias StyleContextPrintingModifier = EmptyModifier

// MARK: - TupleStyleContext

package struct TupleStyleContext<T>: StyleContext {
    package static func acceptsAny<each Q>(_ queries: repeat (each Q).Type) -> Bool where repeat each Q: StyleContext {
        let desc = StyleContextDescriptor.tupleDescription(TupleType(T.self))
        var visitor = QueryVisitor<repeat each Q>(accepts: false)
        for (_, descriptor) in desc.contentTypes {
            descriptor.visitType(visitor: &visitor)
        }
        return false
    }

    package static func visitStyle<V>(_ visitor: inout V) where V: StyleContextVisitor {
        let desc = StyleContextDescriptor.tupleDescription(TupleType(T.self))
        for (_, descriptor) in desc.contentTypes {
            descriptor.visitType(visitor: &visitor)
        }
    }

    package static func accepts<Q>(_ query: Q.Type, at queryIndex: Int) -> Bool {
        let selfDesc = StyleContextDescriptor.tupleDescription(TupleType(T.self))
        let queryDesc = StyleContextDescriptor.tupleDescription(TupleType(Q.self))
        let selfCount = selfDesc.contentTypes.count
        let queryCount = queryDesc.contentTypes.count
        guard selfCount >= queryCount else {
            return false
        }
        var visitor = QueryAtIndexVisitor<Q>(
            index: queryIndex,
            queryDesc: queryDesc,
            accepts: true
        )
        for (index, descriptor) in selfDesc.contentTypes {
            guard index >= queryIndex, index < queryCount else {
                continue
            }
            descriptor.visitType(visitor: &visitor)
        }
        return visitor.accepts
    }

    private struct QueryAtIndexVisitor<U>: StyleContextVisitor {
        var index: Int
        var queryDesc: TupleTypeDescription<StyleContextDescriptor>
        var accepts: Bool

        mutating func visit<C>(_ context: C.Type) where C: StyleContext {
            var visitor = ContextAcceptsVisitor<C>(accepts: false)
            queryDesc.contentTypes[index].1.visitType(visitor: &visitor)
            accepts = accepts && visitor.accepts
            index &+= 1
        }
    }

    private struct QueryVisitor<each U>: StyleContextVisitor where repeat each U: StyleContext {
        var accepts: Bool

        mutating func visit<C>(_ context: C.Type) where C: StyleContext {
            accepts = accepts ? true : C.acceptsAny(repeat (each U).self)
        }
    }

    private struct ContextAcceptsVisitor<U>: StyleContextVisitor where U: StyleContext {
        var accepts: Bool

        mutating func visit<C>(_ context: C.Type) where C: StyleContext {
            accepts = U.accepts(context, at: 0)
        }
    }
}

// MARK: - StyleContextVisitor

package protocol StyleContextVisitor {
    mutating func visit<C>(_ context: C.Type) where C: StyleContext
}

// MARK: - StyleContextDescriptor

package struct StyleContextDescriptor: TupleDescriptor {
    package static var typeCache: [ObjectIdentifier: TupleTypeDescription<StyleContextDescriptor>] = [:]

    package static var descriptor: UnsafeRawPointer {
        _styleContextProtocolDescriptor()
    }
}

extension TypeConformance where P == StyleContextDescriptor {
    package func visitType<V>(visitor: UnsafeMutablePointer<V>) where V: StyleContextVisitor {
        visitor.pointee.visit(unsafeExistentialMetatype((any StyleContext.Type).self))
    }
}

// MARK: - QueryVisitor

private struct QueryVisitor<Context>: StyleContextVisitor where Context: StyleContext {
    var accepts: Bool

    mutating func visit<C>(_ context: C.Type) where C: StyleContext {
        accepts = accepts ? true : Context.self == context
    }
}
