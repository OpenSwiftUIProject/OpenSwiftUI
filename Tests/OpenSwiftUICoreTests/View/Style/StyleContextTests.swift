//
//  StyleContextTests.swift
//  OpenSwiftUICoreTests
//
//  Author: Claude Code with Claude Sonnet 4.5

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing

@MainActor
@Suite
struct TupleStyleContextTests {
    @Test("Test TupleStyleContext accepts single context at index 0")
    func acceptsSingleContextAtIndexZero() {
        typealias SingleContext = TupleStyleContext<(WindowRootContext)>
        #expect(SingleContext.accepts(WindowRootContext.self, at: 0))
        #expect(!SingleContext.accepts(MenuStyleContext.self, at: 0))
        #expect(!SingleContext.accepts(ToolbarStyleContext.self, at: 0))
    }

    @Test("Test TupleStyleContext accepts multiple contexts at different indices")
    func acceptsMultipleContextsAtDifferentIndices() {
        typealias DoubleContext = TupleStyleContext<(WindowRootContext, MenuStyleContext)>
        #expect(DoubleContext.accepts(WindowRootContext.self, at: 0))
        #expect(DoubleContext.accepts(MenuStyleContext.self, at: 1))
        #expect(!DoubleContext.accepts(ToolbarStyleContext.self, at: 0))
    }

    @Test("Test TupleStyleContext accepts with tuple query type")
    func acceptsWithTupleQueryType() {
        typealias TripleContext = TupleStyleContext<(WindowRootContext, MenuStyleContext, ToolbarStyleContext)>
        typealias DoubleQuery = TupleStyleContext<(WindowRootContext, MenuStyleContext)>
        #expect(!TripleContext.accepts(DoubleQuery.self, at: 0))
        #expect(TripleContext.accepts(DoubleQuery.self, at: 1))
        #expect(TripleContext.accepts(DoubleQuery.self, at: 2))
    }

    @Test("Test TupleStyleContext rejects query when count exceeds context count")
    func rejectsQueryWhenCountExceedsContextCount() {
        typealias SingleContext = TupleStyleContext<(WindowRootContext)>
        typealias DoubleQuery = TupleStyleContext<(WindowRootContext, MenuStyleContext)>
        #expect(!SingleContext.accepts(DoubleQuery.self, at: 0))
    }

    @Test("Test TupleStyleContext accepts at valid query index")
    func acceptsAtValidQueryIndex() {
        typealias QuadContext = TupleStyleContext<(WindowRootContext, MenuStyleContext, ToolbarStyleContext, TableStyleContext)>
        #expect(QuadContext.accepts(MenuStyleContext.self, at: 1))
        #expect(QuadContext.accepts(ToolbarStyleContext.self, at: 2))
        #expect(QuadContext.accepts(TableStyleContext.self, at: 3))
    }

    @Test("Test TupleStyleContext with out of bounds query index")
    func outOfBoundsQueryIndex() {
        typealias DoubleContext = TupleStyleContext<(WindowRootContext, MenuStyleContext)>
        #expect(DoubleContext.accepts(ToolbarStyleContext.self, at: 2))
        #expect(DoubleContext.accepts(WindowRootContext.self, at: 5))
    }

    @Test("Test TupleStyleContext with homogeneous tuple")
    func acceptsWithHomogeneousTuple() {
        typealias HomogeneousContext = TupleStyleContext<(MenuStyleContext, MenuStyleContext, MenuStyleContext)>
        #expect(HomogeneousContext.accepts(MenuStyleContext.self, at: 0))
        #expect(HomogeneousContext.accepts(MenuStyleContext.self, at: 1))
        #expect(HomogeneousContext.accepts(MenuStyleContext.self, at: 2))
    }

    @Test("Test TupleStyleContext with different context types")
    func acceptsWithDifferentContextTypes() {
        typealias MixedContext = TupleStyleContext<(
            WindowRootContext,
            MenuStyleContext,
            ToolbarStyleContext,
            ScrollViewStyleContext,
            SheetStyleContext
        )>
        #expect(MixedContext.accepts(WindowRootContext.self, at: 0))
        #expect(MixedContext.accepts(MenuStyleContext.self, at: 1))
        #expect(MixedContext.accepts(ToolbarStyleContext.self, at: 2))
        #expect(MixedContext.accepts(ScrollViewStyleContext.self, at: 3))
        #expect(MixedContext.accepts(SheetStyleContext.self, at: 4))
        #expect(!MixedContext.accepts(TableStyleContext.self, at: 0))
    }

    @Test("Test TupleStyleContext accepts nested tuple query")
    func acceptsNestedTupleQuery() {
        typealias LargeContext = TupleStyleContext<(
            WindowRootContext,
            MenuStyleContext,
            ToolbarStyleContext,
            TableStyleContext,
            SheetStyleContext
        )>
        typealias TripleQuery = TupleStyleContext<(MenuStyleContext, ToolbarStyleContext, TableStyleContext)>
        #expect(LargeContext.accepts(TripleQuery.self, at: 1))
        #expect(!LargeContext.accepts(TripleQuery.self, at: 0))
        #expect(LargeContext.accepts(TripleQuery.self, at: 3))
    }

    @Test("Test TupleStyleContext accepts with accessibility contexts")
    func acceptsWithAccessibilityContexts() {
        typealias AccessibilityContext = TupleStyleContext<(
            AccessibilityRepresentableStyleContext,
            AccessibilityQuickActionStyleContext
        )>
        #expect(AccessibilityContext.accepts(AccessibilityRepresentableStyleContext.self, at: 0))
        #expect(AccessibilityContext.accepts(AccessibilityQuickActionStyleContext.self, at: 1))
    }

    @Test("Test TupleStyleContext accepts with container and list contexts")
    func acceptsWithContainerAndListContexts() {
        typealias ContainerContext = TupleStyleContext<(
            ContainerStyleContext,
            ContentListStyleContext,
            MultimodalListContext
        )>
        #expect(ContainerContext.accepts(ContainerStyleContext.self, at: 0))
        #expect(ContainerContext.accepts(ContentListStyleContext.self, at: 1))
        #expect(ContainerContext.accepts(MultimodalListContext.self, at: 2))
    }

    @Test("Test TupleStyleContext with sidebar and inspector contexts")
    func acceptsWithSidebarAndInspectorContexts() {
        typealias SidebarContext = TupleStyleContext<(SidebarStyleContext, InspectorStyleContext)>
        #expect(SidebarContext.accepts(SidebarStyleContext.self, at: 0))
        #expect(SidebarContext.accepts(InspectorStyleContext.self, at: 1))
        #expect(!SidebarContext.accepts(WindowRootContext.self, at: 0))
    }

    @Test("Test TupleStyleContext with sheet and dialog contexts")
    func acceptsWithSheetAndDialogContexts() {
        typealias SheetContext = TupleStyleContext<(
            SheetStyleContext,
            SheetToolbarStyleContext,
            DialogActionStyleContext
        )>
        #expect(SheetContext.accepts(SheetStyleContext.self, at: 0))
        #expect(SheetContext.accepts(SheetToolbarStyleContext.self, at: 1))
        #expect(SheetContext.accepts(DialogActionStyleContext.self, at: 2))
    }
}

@MainActor
@Suite
struct StyleContextVisitorTests {
    private struct CollectingVisitor: StyleContextVisitor {
        var visitedTypes: [String] = []

        mutating func visit<C>(_ context: C.Type) where C: StyleContext {
            visitedTypes.append(String(describing: context))
        }
    }

    @Test("Test TupleStyleContext visitStyle with single context")
    func visitStyleWithSingleContext() {
        typealias SingleContext = TupleStyleContext<(WindowRootContext)>
        var visitor = CollectingVisitor()
        SingleContext.visitStyle(&visitor)
        #expect(visitor.visitedTypes.contains("WindowRootContext"))
    }

    @Test("Test TupleStyleContext visitStyle with multiple contexts")
    func visitStyleWithMultipleContexts() {
        typealias TripleContext = TupleStyleContext<(WindowRootContext, MenuStyleContext, ToolbarStyleContext)>
        var visitor = CollectingVisitor()
        TripleContext.visitStyle(&visitor)
        #expect(visitor.visitedTypes.contains("WindowRootContext"))
        #expect(visitor.visitedTypes.contains("MenuStyleContext"))
        #expect(visitor.visitedTypes.contains("ToolbarStyleContext"))
    }
}

@MainActor
@Suite
struct ConcreteStyleContextTests {
    @Test("Test WindowRootContext accepts itself")
    func windowRootContextAcceptsItself() {
        #expect(WindowRootContext.accepts(WindowRootContext.self, at: 0))
        #expect(!WindowRootContext.accepts(MenuStyleContext.self, at: 0))
    }

    @Test("Test NoStyleContext accepts itself")
    func noStyleContextAcceptsItself() {
        #expect(NoStyleContext.accepts(NoStyleContext.self, at: 0))
        #expect(!NoStyleContext.accepts(WindowRootContext.self, at: 0))
    }

    @Test("Test acceptsTop convenience method")
    func acceptsTopConvenienceMethod() {
        #expect(WindowRootContext.acceptsTop(WindowRootContext.self))
        #expect(!WindowRootContext.acceptsTop(MenuStyleContext.self))

        typealias DoubleContext = TupleStyleContext<(WindowRootContext, MenuStyleContext)>
        #expect(DoubleContext.acceptsTop(WindowRootContext.self))
        #expect(!DoubleContext.acceptsTop(MenuStyleContext.self))
    }

    @Test("Test concrete context initialization")
    func concreteContextInitialization() {
        _ = WindowRootContext()
        _ = AccessibilityRepresentableStyleContext()
        _ = AccessibilityQuickActionStyleContext()
        _ = ContainerStyleContext()
        _ = ContentListStyleContext()
        _ = DocumentStyleContext()
        _ = ControlGroupStyleContext()
        _ = DialogActionStyleContext()
        _ = HostingConfigurationContext()
        _ = MenuStyleContext()
        _ = MultimodalListContext()
        _ = MultimodalListGridContext()
        _ = MultimodalListStackContext()
        _ = NoStyleContext()
        _ = ScrollViewStyleContext()
        _ = TextInputSuggestionsContext()
        _ = SectionHeaderStyleContext()
        _ = SheetStyleContext()
        _ = SheetToolbarStyleContext()
        _ = SidebarStyleContext()
        _ = SwipeActionsStyleContext()
        _ = TableStyleContext()
        _ = ToolbarStyleContext()
        _ = InspectorStyleContext()
        _ = MenuBarExtraWindowStyleContext()
    }

    @Test("Test concrete context static accessors")
    func concreteContextStaticAccessors() {
        _ = WindowRootContext.windowRoot
        _ = AccessibilityRepresentableStyleContext.accessibilityRepresentable
        _ = AccessibilityQuickActionStyleContext.accessibilityQuickAction
        _ = ContainerStyleContext.container
        _ = ContentListStyleContext.contentList
        _ = DocumentStyleContext.document
        _ = ControlGroupStyleContext.controlGroup
        _ = DialogActionStyleContext.dialogAction
        _ = HostingConfigurationContext.hostingConfiguration
        _ = MenuStyleContext.menu
        _ = MultimodalListContext.multimodalList
        _ = MultimodalListGridContext.multimodalListGrid
        _ = MultimodalListStackContext.multimodalListStack
        _ = NoStyleContext.none
        _ = ScrollViewStyleContext.scrollView
        _ = TextInputSuggestionsContext.textInputSuggestions
        _ = SectionHeaderStyleContext.sectionHeader
        _ = SheetStyleContext.sheet
        _ = SheetToolbarStyleContext.sheetToolbar
        _ = SidebarStyleContext.sidebar
        _ = SwipeActionsStyleContext.swipeActions
        _ = TableStyleContext.table
        _ = ToolbarStyleContext.toolbar
        _ = InspectorStyleContext.inspector
        _ = MenuBarExtraWindowStyleContext.menuBarExtraWindow
    }
}
