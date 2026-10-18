//
//  FocusNavigator.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3CB6EB205666430ABD7FC458DE8E3793 (SwiftUI)

#if os(macOS)
import AppKit
import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - FocusNavigator

struct FocusNavigator {
    weak var bridge: FocusBridge?

    func defaultFocusItem(for responder: any BaseFocusResponder) -> FocusItem? {
        guard let layoutDirection = bridge?.currentEnvironment.layoutDirection else { return nil }
        var sequence = FocusNavigationSequence(
            defaultLayoutDirection: layoutDirection,
            heading: .next,
            base: responder,
            options: .evaluateDefaultFocus
        )
        return sequence.next()
    }

    var firstNavigableItem: FocusItem? {
        var sequence = navigationSequence(toward: .next)
        return sequence?.next()
    }

    var lastNavigableItem: FocusItem? {
        var sequence = navigationSequence(toward: .previous)
        return sequence?.next()
    }

    private func navigationSequence(
        toward direction: FocusBridge.NavigationDirection,
        options: FocusNavigationSequence.Options? = nil
    ) -> FocusNavigationSequence? {
        guard let layoutDirection = bridge?.currentEnvironment.layoutDirection,
              let responder = bridge?.host?.responderNode else {
            return nil
        }
        var defaultOptions: FocusNavigationSequence.Options = []
        if let bridge, let host = bridge.host,
           bridge.flags.contains(.resettingFocus)
                || host.window.map({ !$0.isVisible || $0._keyViewRedirectionDisabled }) == true {
            defaultOptions = .evaluateDefaultFocus
        }
        return FocusNavigationSequence(
            defaultLayoutDirection: layoutDirection,
            heading: direction,
            base: responder,
            options: options ?? defaultOptions
        )
    }

    var lastHostNavigableItem: FocusItem? {
        guard let sequence = navigationSequence(toward: .next, options: []) else { return nil }
        var result: FocusItem?
        for item in sequence {
            if case .platformResponder = item.base { break }
            result = item
        }
        return result
    }

    var allItems: FocusNavigationSequence? {
        navigationSequence(toward: .next, options: .includeAll)
    }

    func focusItemByNavigating(
        toward direction: FocusBridge.NavigationDirection,
        options: FocusNavigationSequence.Options
    ) -> FocusItem? {
        guard let layoutDirection = bridge?.currentEnvironment.layoutDirection,
              let responder = bridge?.host?.focusedItem?.responder else { return nil }
        var sequence = FocusNavigationSequence(
            defaultLayoutDirection: layoutDirection,
            heading: direction,
            base: responder,
            options: options
        )
        return sequence.next()
    }

    static func comparator(
        _ layoutDirection: LayoutDirection
    ) -> (FocusNavigationCohortElement, FocusNavigationCohortElement) -> Bool {
        { compareResponders($0.frame, $1.frame, layoutDirection: layoutDirection) }
    }

    private static func compareResponders(
        _ lhs: CGRect,
        _ rhs: CGRect,
        layoutDirection: LayoutDirection
    ) -> Bool {
        if _SemanticFeature_v3.isEnabled {
            if lhs.maxY <= rhs.minY { return true }
            if rhs.maxY <= lhs.minY { return false }
        } else {
            if rhs.maxY <= lhs.minY { return true }
            if lhs.maxY <= rhs.minY { return false }
        }
        if lhs.minX != rhs.minX, layoutDirection == .leftToRight {
            return lhs.minX < rhs.minX
        }
        if lhs.maxX != rhs.maxX, layoutDirection == .rightToLeft {
            return lhs.maxX > rhs.maxX
        }
        return _SemanticFeature_v3.isEnabled ? lhs.minY <= rhs.minY : lhs.maxY >= rhs.maxY
    }
}

// MARK: - FocusNavigationSequence

struct FocusNavigationSequence: Sequence, IteratorProtocol {
    var iteratorCache: [ObjectIdentifier: FocusSectionIterator] = [:]
    var frameCache: [ObjectIdentifier: CGRect] = [:]
    var alreadyEvaluated: Set<EvaluateDefaultFocusAction> = []
    var defaultLayoutDirection: LayoutDirection
    var heading: FocusBridge.NavigationDirection
    var base: ResponderNode
    var options: Options

    struct Options: OptionSet {
        var rawValue: Int

        static let includeAll: Options = .init(rawValue: 1 << 0)
        static let wrapAround: Options = .init(rawValue: 1 << 1)
        static let skipSections: Options = .init(rawValue: 1 << 2)
        static let restrictToSubtree: Options = .init(rawValue: 1 << 3)
        static let evaluateDefaultFocus: Options = .init(rawValue: 1 << 4)
    }

    mutating func next() -> FocusItem? {
        var section = base is FocusStateBindingResponder ? base : base.focusGroupingResponder ?? base
        var stack = [iterator(responder: section, start: base)]
        var didWrap = false
        while var current = stack.popLast() {
            while let element = current.next() {
                let responder = element.responder
                frameCache[ObjectIdentifier(responder)] = element.frame
                if responder is FocusSectionResponder, !options.contains(.skipSections) {
                    stack.append(current)
                    stack.append(iterator(responder: responder, start: nil))
                    break
                }
                guard let responder = responder as? any FocusResponder,
                      responder.focusItem != nil else { continue }
                let item = responder.focusItem!
                let canReceiveClientFocus: Bool
                if case let .view(view) = item.base {
                    canReceiveClientFocus = view.options.contains(.fromClientUpdate)
                } else {
                    canReceiveClientFocus = true
                }
                guard item.isNavigable || options.contains(.includeAll)
                        || (options.contains(.evaluateDefaultFocus) && item.isFocusable && canReceiveClientFocus)
                else { continue }
                if options.contains(.evaluateDefaultFocus),
                   let action = responder.evaluateDefaultFocus,
                   !alreadyEvaluated.contains(action),
                   let target = action.onEvaluate?() {
                    alreadyEvaluated.insert(action)
                    stack.append(current)
                    stack.append(FocusSectionIterator(
                        section: nil,
                        cohort: [element],
                        heading: .next,
                        baseIndex: -1
                    ))
                    stack.append(iterator(responder: target, start: nil))
                    break
                }
                base = responder
                if let item = responder.focusItem { return item }
            }
            guard stack.isEmpty else { continue }
            if !options.contains(.restrictToSubtree), let parent = section.focusGroupingResponder {
                stack.append(iterator(responder: parent, start: section))
                section = parent
            } else if options.contains(.wrapAround), !didWrap {
                // Bound retries when no item can receive focus.
                didWrap = true
                let cohort = section.focusNavigationCohort(defaultLayoutDirection)
                stack.append(FocusSectionIterator(
                    section: section,
                    cohort: cohort,
                    heading: heading,
                    baseIndex: heading == .previous ? cohort.count : -1
                ))
            }
        }
        return nil
    }

    private mutating func iterator(responder: ResponderNode, start: ResponderNode?) -> FocusSectionIterator {
        let id = ObjectIdentifier(responder)
        var iterator: FocusSectionIterator
        if let cached = iteratorCache[id] {
            iterator = cached
        } else {
            let cohort = responder.focusNavigationCohort(defaultLayoutDirection)
            iterator = FocusSectionIterator(
                section: responder,
                cohort: cohort,
                heading: heading,
                baseIndex: heading == .previous ? cohort.count : -1
            )
            iteratorCache[id] = iterator
        }
        if let section = iterator.section,
           let start = start as? any BaseFocusResponder,
           start !== section,
           let index = iterator.cohort.firstIndex(where: { $0.responder === start }) {
            iterator.baseIndex = index
        }
        return iterator
    }
}

struct FocusNavigationCohortElement {
    var responder: any BaseFocusResponder
    var frame: CGRect
}

struct FocusSectionIterator: IteratorProtocol {
    var section: ResponderNode?
    var cohort: [FocusNavigationCohortElement]
    var heading: FocusBridge.NavigationDirection
    var baseIndex: Int?

    mutating func next() -> FocusNavigationCohortElement? {
        guard let baseIndex else { return nil }
        let index = baseIndex + (heading == .previous ? -1 : 1)
        guard cohort.indices.contains(index) else {
            self.baseIndex = nil
            return nil
        }
        self.baseIndex = index
        return cohort[index]
    }
}

// MARK: - ResponderNode + Focus Navigation

extension ResponderNode {
    var focusGroupingResponder: ResponderNode? {
        var result: ResponderNode?
        guard let nextResponder else { return nil }
        for responder in nextResponder.sequence {
            result = responder
            if responder is FocusSectionResponder { break }
        }
        return result
    }

    func focusNavigationCohort(_ defaultLayoutDirection: LayoutDirection) -> [FocusNavigationCohortElement] {
        var cohort: [FocusNavigationCohortElement] = []
        var layoutDirection: LayoutDirection?
        var hasMixedLayoutDirections = false
        visitBaseFocusResponders { responder in
            guard responder !== self, let frame = responder.frame else { return .next }
            if _SemanticFeature_v4.isEnabled,
               let responder = responder as? any FocusResponder,
               let item = responder.viewItem,
               !item.isFocusable {
                return .skipToNextSibling
            }
            cohort.append(FocusNavigationCohortElement(responder: responder, frame: frame))
            if !hasMixedLayoutDirections {
                if let layoutDirection, let direction = responder.effectiveLayoutDirection,
                   layoutDirection != direction {
                    hasMixedLayoutDirections = true
                } else if layoutDirection == nil {
                    layoutDirection = responder.effectiveLayoutDirection
                }
            }
            if responder is FocusSectionResponder {
                return .skipToNextSibling
            }
            if let responder = responder as? any FocusResponder,
               responder.viewItem?.options.contains(.preventNavigationToSubviews) == true {
                return .skipToNextSibling
            }
            return .next
        }
        if layoutDirection == nil || hasMixedLayoutDirections {
            layoutDirection = firstAncestor(ofType: (any BaseFocusResponder).self)?.effectiveLayoutDirection
                ?? defaultLayoutDirection
        }
        cohort.sort(by: FocusNavigator.comparator(layoutDirection!))
        return cohort
    }
}
#endif
