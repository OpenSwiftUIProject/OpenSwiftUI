//
//  FocusNavigatorTests.swift
//  OpenSwiftUITests

#if os(macOS)
import AppKit
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@MainActor
@Suite(.tags(.aigc))
struct FocusNavigatorTests {
    @Test
    func spatialOrderUsesRowsAndLayoutDirection() {
        Semantics.v3.test {
            let root = Node()
            let left = Node(x: 0, y: 0)
            let right = Node(x: 20, y: 0)
            let below = Node(x: 0, y: 20)
            root.children = [below, right, left]
            #expect(responders(sequence(root)) == [left, right, below].map(ObjectIdentifier.init))
            #expect(responders(sequence(root, layoutDirection: .rightToLeft)) == [right, left, below].map(ObjectIdentifier.init))
            #expect(responders(sequence(root, heading: .previous)) == [below, right, left].map(ObjectIdentifier.init))
        }
        Semantics.v2.test {
            let root = Node()
            let upper = Node(x: 0, y: 0)
            let lower = Node(x: 0, y: 20)
            root.children = [upper, lower]
            #expect(responders(sequence(root)) == [lower, upper].map(ObjectIdentifier.init))
        }
    }

    @Test
    func cohortUsesSharedDirectionOrAncestorFallback() {
        Semantics.v3.test {
            let root = Node()
            let left = Node(x: 0, y: 0)
            let right = Node(x: 20, y: 0)
            root.children = [left, right]
            left.effectiveLayoutDirection = .rightToLeft
            right.effectiveLayoutDirection = .rightToLeft
            #expect(responders(sequence(root)) == [right, left].map(ObjectIdentifier.init))
            right.effectiveLayoutDirection = .leftToRight
            #expect(responders(sequence(root)) == [left, right].map(ObjectIdentifier.init))
            root.effectiveLayoutDirection = .rightToLeft
            #expect(responders(sequence(root)) == [right, left].map(ObjectIdentifier.init))
        }
    }

    @Test
    func iterationStartsAfterBaseAndKeepsCohortSnapshot() {
        Semantics.v3.test {
            let root = Node()
            let first = Node(x: 0, y: 0)
            let second = Node(x: 20, y: 0)
            let inserted = Node(x: 10, y: 0)
            root.children = [first, second]
            var iterator = sequence(root)
            #expect(iterator.next()?.responder === first)
            root.children = [first, inserted, second]
            #expect(iterator.next()?.responder === second)
            #expect(iterator.next() == nil)
            var forward = sequence(first)
            #expect(forward.next()?.responder === inserted)
            var backward = sequence(second, heading: .previous)
            #expect(backward.next()?.responder === inserted)
            var wrapped = sequence(second, options: .wrapAround)
            #expect(wrapped.next()?.responder === first)
        }
    }

    @Test
    func wrappingStopsWhenNoItemCanReceiveFocus() {
        Semantics.v4.test {
            for heading in [FocusBridge.NavigationDirection.next, .previous] {
                let root = Node()
                var empty = sequence(root, heading: heading, options: .wrapAround)
                #expect(empty.next() == nil)

                let rejected = Node(x: 0, y: 0, options: .fromMouse)
                root.children = [rejected]
                var nonNavigable = sequence(rejected, heading: heading, options: .wrapAround)
                #expect(nonNavigable.next() == nil)

                rejected.item?.isFocusable = false
                var disabled = sequence(rejected, heading: heading, options: .wrapAround)
                #expect(disabled.next() == nil)
            }
        }
    }

    @Test
    func navigationFiltersKeyboardAndClientFocusSeparately() {
        Semantics.v4.test {
            let root = Node()
            let mouse = Node(x: 0, y: 0, options: .fromMouse)
            let client = Node(x: 20, y: 0, options: .fromClientUpdate)
            let keyboard = Node(x: 40, y: 0)
            root.children = [mouse, client, keyboard]
            #expect(responders(sequence(root)) == [ObjectIdentifier(keyboard)])
            #expect(responders(sequence(root, options: .includeAll)) == [mouse, client, keyboard].map(ObjectIdentifier.init))
            var initial = sequence(root, options: .evaluateDefaultFocus)
            #expect(initial.next()?.responder === client)
        }
    }

    @Test
    func cohortPrunesNonfocusableAndBlockedDescendants() {
        Semantics.v4.test {
            let root = Node()
            let disabled = Node(x: 0, y: 0)
            disabled.item?.isFocusable = false
            let disabledChild = Node(x: 10, y: 0)
            disabled.children = [disabledChild]
            let container = Node(x: 20, y: 0, options: [.fromKeyboard, .preventNavigationToSubviews])
            container.children = [Node(x: 30, y: 0)]
            let sibling = Node(x: 40, y: 0)
            root.children = [disabled, container, sibling]
            #expect(responders(sequence(root, options: .includeAll)) == [container, sibling].map(ObjectIdentifier.init))
        }
    }

    @Test
    func defaultFocusEvaluatesOnceAndFallsBackToOriginalItem() {
        Semantics.v4.test {
            let root = Node()
            let original = Node(x: 0, y: 0)
            let target = Node()
            let preferred = Node(x: 20, y: 0)
            target.children = [preferred]
            root.children = [original]
            var calls = 0
            let action = EvaluateDefaultFocusAction(namespace: .init(id: 1), priority: .automatic) {
                calls += 1
                return target
            }
            original.evaluateDefaultFocus = action
            preferred.evaluateDefaultFocus = action
            var iterator = sequence(root, options: .evaluateDefaultFocus)
            #expect(iterator.next()?.responder === preferred)
            #expect(calls == 1)

            target.children = []
            var fallback = sequence(root, options: .evaluateDefaultFocus)
            #expect(fallback.next()?.responder === original)
            #expect(calls == 2)
        }
    }

    @Test
    func defaultFocusActionCanRemoveItsCurrentItem() {
        Semantics.v4.test {
            let root = Node()
            let removed = Node(x: 0, y: 0)
            let next = Node(x: 20, y: 0)
            root.children = [removed, next]
            removed.evaluateDefaultFocus = EvaluateDefaultFocusAction(
                namespace: .init(id: 1),
                priority: .automatic
            ) {
                removed.item = nil
                return nil
            }
            var iterator = sequence(root, options: .evaluateDefaultFocus)
            #expect(iterator.next()?.responder === next)
        }
    }

    @Test
    func sectionIteratorStopsAtBothBoundaries() {
        let first = Node(x: 0, y: 0)
        let second = Node(x: 20, y: 0)
        let cohort = [first, second].map { FocusNavigationCohortElement(responder: $0, frame: $0.frame!) }
        var forward = FocusSectionIterator(section: nil, cohort: cohort, heading: .next, baseIndex: -1)
        #expect(forward.next()?.responder === first)
        #expect(forward.next()?.responder === second)
        #expect(forward.next() == nil)
        #expect(forward.next() == nil)
        var backward = FocusSectionIterator(section: nil, cohort: cohort, heading: .previous, baseIndex: cohort.count)
        #expect(backward.next()?.responder === second)
        #expect(backward.next()?.responder === first)
        #expect(backward.next() == nil)
        #expect(backward.next() == nil)
    }

    private func sequence(
        _ base: ResponderNode,
        layoutDirection: LayoutDirection = .leftToRight,
        heading: FocusBridge.NavigationDirection = .next,
        options: FocusNavigationSequence.Options = []
    ) -> FocusNavigationSequence {
        FocusNavigationSequence(defaultLayoutDirection: layoutDirection, heading: heading, base: base, options: options)
    }

    private func responders(_ sequence: FocusNavigationSequence) -> [ObjectIdentifier] {
        sequence.compactMap { $0.responder.map(ObjectIdentifier.init) }
    }

    private final class Node: ResponderNode, FocusResponder {
        weak var parent: Node?
        var children: [Node] = [] {
            didSet {
                for child in oldValue where child.parent === self { child.parent = nil }
                for child in children { child.parent = self }
            }
        }
        var item: FocusItem.ViewItem?
        var frame: CGRect?
        var isEnabled: Bool { true }
        var effectiveLayoutDirection: LayoutDirection?
        var firstKeyViewInSubtree: NSView?
        var lastKeyViewInSubtree: NSView?
        var focusAccessibilityNode: AccessibilityNode?
        var keyPressHandlers: [KeyPress.Handler] = []
        var evaluateDefaultFocus: EvaluateDefaultFocusAction?
        var focusRingView: (NSView & FocusRingDelegate)? { nil }
        var delegatesFocusEffect: Bool { false }
        func setFocusRingView(_ view: (NSView & FocusRingDelegate)?) {}

        override init() { super.init() }

        init(x: CGFloat, y: CGFloat, options: FocusableOptions = .fromKeyboard) {
            item = .init(id: .invalid, isFocusable: true, options: options, onFocusChange: { _ in }, delegatesFocusEffect: false)
            frame = CGRect(x: x, y: y, width: 10, height: 10)
            super.init()
        }

        var focusItem: FocusItem? {
            item.map { FocusItem(base: .view($0), prefersFocusSystem: false, responder: self) }
        }

        override var nextResponder: ResponderNode? { parent }

        override func visit(applying visitor: (ResponderNode) -> ResponderVisitorResult) -> ResponderVisitorResult {
            switch visitor(self) {
            case .next:
                for child in children where child.visit(applying: visitor) == .cancel { return .cancel }
                return .next
            case .skipToNextSibling: return .next
            case .cancel: return .cancel
            }
        }
    }
}
#endif
