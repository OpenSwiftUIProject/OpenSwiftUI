//
//  FocusBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import COpenSwiftUI
#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - FocusHost

protocol FocusHost: ViewRendererHost {
    var focusedItem: FocusItem? { get }
    var focusedValues: FocusedValues { get set }
    var currentAccessibilityFocusStore: AccessibilityFocusStore { get set }

    func focus(item: FocusItem)
    func focusDidChange()
}

// MARK: - FocusBridge

class FocusBridge {
    var flags: Flags = []
    weak var _host: (PlatformView & FocusBridgeProvider & FocusHost)?
    var focusStore = FocusStore()
    var currentEnvironment = EnvironmentValues()
    private var _focusedItem: FocusItem?
    weak var parentFocusBridge: FocusBridge?

    #if os(macOS)
    weak var headKeyView: NSView?
    weak var tailKeyView: NSView?
    var hostingViewProxyCache: KeyViewProxyCache?
    var keyViewLoopSeed: VersionSeed = .invalid
    lazy var navigator: FocusNavigator = .init(bridge: self)
    #elseif os(iOS) || os(visionOS)
    var requestedFocusItem: (any UIFocusItem)?
    var defaultFocusNamespace: Namespace.ID?
    #endif
    var ignoreTextFocusEvents = false

    private static var nextSeedValue: UInt32 = 1

    init() {
        _openSwiftUIEmptyStub()
    }

    // MARK: - Platform focus

    var host: (PlatformView & FocusBridgeProvider & FocusHost)? {
        if _host == nil {
            Log.focus?.log("Focus bridge \(String(describing: Unmanaged.passUnretained(self).toOpaque())) has no host.")
        }
        return _host
    }

    var focusedItem: FocusItem? {
        get {
            if _focusedItem?.isExpired == true {
                let oldItem = _focusedItem
                _focusedItem = nil
                didChangeFocusItem(from: oldItem, to: nil)
            }
            return _focusedItem
        }
        set {
            let newItem = updatedFocusItem(newValue)
            let oldItem = _focusedItem
            _focusedItem = newItem
            didChangeFocusItem(from: oldItem, to: _focusedItem)
        }
    }

    private func updatedFocusItem(_ item: FocusItem?) -> FocusItem? {
        guard var item else { return nil }
        item.seed = VersionSeed(value: Self.nextSeedValue)
        Self.nextSeedValue &+= 1
        return item
    }

    private func didChangeFocusItem(from oldItem: FocusItem?, to newItem: FocusItem?) {
        guard let host, FocusItem.isFocusChange(from: oldItem, to: newItem) else { return }
        if case let .view(item) = oldItem?.base {
            item.onFocusChange(false)
        }
        #if os(macOS)
        newItem?.focusDidChange(isFocused: true)
        let oldRing = oldItem?.responder?.focusRingView
        let newRing = newItem?.responder?.focusRingView
        oldRing?.focused = false
        oldRing?.hideActiveFirstResponderIndication()
        newRing?.focused = true
        if oldRing != nil {
            newRing?.showActiveFirstResponderIndication()
        }
        #else
        if case let .view(item) = newItem?.base {
            item.onFocusChange(true)
        }
        #endif
        host.invalidateProperties(.focusedItem)
    }

    func moveFocus(to item: FocusItem, designatedPlatformResponder: PlatformView?) {
        #if os(macOS)
        guard FocusItem.isFocusChange(from: focusedItem, to: item), let host else { return }
        var target: NSView?
        switch item.base {
        case let .platformResponder(view):
            if let view = view.base, item.isFocusable {
                let first = _SemanticFeature_v5.isEnabled ? view.firstFocusableDescendant : view
                if host.window?.keyViewSelectionDirection == .selectingPrevious,
                   let last = item.responder?.lastValidKeyViewInSubtree {
                    target = last
                } else {
                    target = first?.firstFocusableDescendant
                }
            }
        case .view:
            focusedItem = item
            target = designatedPlatformResponder ?? host
        case .platformItem:
            break
        }
        guard let target else { return }
        Update.enqueueAction(reason: nil) { [weak host, weak target] in
            guard let window = host?.window else { return }
            if window.firstResponder === target {
                NSWindow._postActiveFirstResponderChanged()
            } else {
                window.makeFirstResponder(target)
            }
        }
        #elseif os(iOS) || os(visionOS)
        guard FocusItem.isFocusChange(from: focusedItem, to: item), let host else { return }
        if focusedItem == nil, parentFocusBridge != nil,
           let representedItem = Self.representedFocusItem(item, in: host) {
            parentFocusBridge?.moveFocus(
                to: FocusItem(base: .platformItem(WeakBox(representedItem)), prefersFocusSystem: false),
                designatedPlatformResponder: nil
            )
            return
        }
        guard canAcceptFocus else { return }
        var target = item.platformResponder
        if let view = target {
            if item.isFocusable {
                target = _SemanticFeature_v5.isEnabled ? view.firstFocusableDescendant : view
            } else {
                target = nil
            }
        }
        if case .view = item.base {
            focusedItem = item
            target = designatedPlatformResponder ?? host
        }
        if let target {
            Update.enqueueAction(reason: nil) { [weak target] in
                target?.becomeFirstResponder()
            }
        } else if case let .platformItem(item) = item.base, let item = item.base {
            requestedFocusItem = item
            host.setNeedsFocusUpdate()
            UIFocusSystem.focusSystem(for: item)?.requestFocusUpdate(to: host)
        }
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }

    var canAcceptFocus: Bool {
        get {
            #if os(iOS) || os(visionOS)
            if host?.as((any UIViewControllerProvider).self)?.uiViewController == nil,
               let parentFocusBridge {
                return parentFocusBridge.canAcceptFocus
            }
            #endif
            return flags.contains(.canAcceptFocus)
        }
        set {
            guard newValue != flags.contains(.canAcceptFocus) else { return }
            if newValue {
                flags.insert(.canAcceptFocus)
            } else {
                flags.remove(.canAcceptFocus)
            }
            focusStore.seed = .empty
            host?.invalidateProperties(.focusStore)
        }
    }

    // MARK: - Flags

    struct Flags: OptionSet {
        var rawValue: Int

        static let resettingFocus: Flags = .init(rawValue: 1 << 0)
        static let canAcceptFocus: Flags = .init(rawValue: 1 << 1)
    }

    #if os(macOS)
    enum NavigationDirection {
        case next
        case previous
    }
    #endif
}

// MARK: - FocusBridgeProvider

protocol FocusBridgeProvider: AnyObject {
    var focusBridge: FocusBridge { get }
}

// MARK: - Environment and preferences [TBA]

extension FocusBridge {
    func updateEnvironment(_ environment: inout EnvironmentValues) {
        guard let host else { return }
        parentFocusBridge = environment.focusBridge
        environment.focusBridge = self
        #if os(iOS) || os(visionOS)
        if !environment.isFocused {
            environment.isFocused = isHostContainedInFocusedItem
        }
        if let window = host.window {
            environment.isPlatformFocusSystemEnabled = UIFocusSystem.focusSystem(for: window) != nil
        }
        #endif
        environment[ResetFocusKey.self] = _ResetFocusAction(bridge: self)
        #if os(macOS)
        environment._focusSystem = _FocusSystem(onResetToDefault: { [weak self] in
            self?.resetFocus(in: nil)
        })
        #endif
        if currentEnvironment.preferenceBridge != nil, environment.preferenceBridge == nil {
            host.viewGraph.addPreference(FocusedValueList.Key.self)
            host.viewGraph.addPreference(FocusStoreList.Key.self)
            host.viewGraph.addPreference(AccessibilityFocusStoreList.Key.self)
            #if os(macOS)
            host.viewGraph.addPreference(KeyViewLoopSeedKey.self)
            #endif
        } else if currentEnvironment.preferenceBridge == nil, environment.preferenceBridge != nil {
            host.viewGraph.removePreference(FocusedValueList.Key.self)
            host.viewGraph.removePreference(FocusStoreList.Key.self)
            host.viewGraph.removePreference(AccessibilityFocusStoreList.Key.self)
            #if os(macOS)
            host.viewGraph.removePreference(KeyViewLoopSeedKey.self)
            #endif
        }
        currentEnvironment = environment
    }

    func preferencesDidChange(_ preferences: PreferenceValues) {
        guard let host else { return }
        let list = preferences[FocusStoreList.Key.self].value
        var version = DisplayList.Version()
        for item in list.items {
            version.combine(with: item.version)
        }
        if !focusStore.seed.matches(VersionSeed(value: UInt32(version.value))) {
            _ = host.responderNode
            focusStore = FocusStore(list)
            host.invalidateProperties(.focusStore)
        }
        let valuesList = preferences[FocusedValueList.Key.self].value
        let valuesSeed = VersionSeed(value: UInt32(valuesList.version.value))
        if !host.focusedValues.seed.matches(valuesSeed) {
            var values = FocusedValues()
            values.seed = valuesSeed
            for item in valuesList.items {
                item.update(&values)
            }
            host.focusedValues = values
            #if os(macOS)
            // TODO: Update exported service types when service requestors are available.
            #else
            _ = host.isRootHost
            #endif
        }
        let accessibilityList = preferences[AccessibilityFocusStoreList.Key.self].value
        if host.currentAccessibilityFocusStore.version != accessibilityList.version {
            host.currentAccessibilityFocusStore = AccessibilityFocusStore(accessibilityList)
        }
        #if os(macOS)
        let seed = preferences[KeyViewLoopSeedKey.self].value
        if !keyViewLoopSeed.matches(seed) {
            keyViewLoopSeed = seed
            if !seed.isInvalid {
                invalidateKeyViewLoop()
            }
        }
        #endif
    }
}

#if os(iOS) || os(visionOS)
// MARK: - UIKit focus

extension FocusBridge {
    var acceptsFirstResponder: Bool {
        guard let host, canAcceptFocus else { return false }
        var result = false
        host.responderNode?.visitFocusResponders { responder in
            guard let item = responder.focusItem,
                  case .view = item.base,
                  item.isFocusable else { return .next }
            result = true
            return .cancel
        }
        return result
    }

    func firstResponderDidChange(to firstResponder: UIResponder?, rootResponder: ResponderNode?) {
        guard let host else { return }
        guard let view = firstResponder as? UIView else {
            focusedItem = nil
            return
        }
        let currentView: UIView? = focusedItem.map { $0.platformResponder ?? host }
        if view === currentView { return }
        if view === host {
            hostDidBecomeFirstResponder(in: nil)
            return
        }
        let ancestor = focusViewProvider(containing: view)?.focusView
        if let provider = view as? any PlatformFocusResponderProvider {
            focusedItem = FocusItem(
                base: .platformResponder(WeakBox(view)),
                prefersFocusSystem: false,
                responder: provider.focusViewResponder
            )
            return
        }
        var result: FocusItem?
        rootResponder?.visitFocusResponders { responder in
            guard let item = responder.focusItem else { return .next }
            if item.isFocusable, (item.platformResponder ?? host) === view {
                result = item
                return .cancel
            }
            if let container = item.platformResponder,
               ancestor?.isDescendant(of: container) == true {
                result = FocusItem(
                    base: .platformResponder(WeakBox(view)),
                    prefersFocusSystem: false,
                    responder: responder
                )
                return .cancel
            }
            return .next
        }
        focusedItem = result
    }

    func hostDidBecomeFirstResponder(in namespace: Namespace.ID?) {
        guard let host else { return }
        if !flags.contains(.resettingFocus) {
            _ = host.window?.firstResponder
        }
        if let item = focusedItem {
            moveFocus(to: item, designatedPlatformResponder: nil)
        }
    }

    func focusDidChange_PhoneWatch(rootResponder: ResponderNode?) {
        guard canAcceptFocus else { return }
        var result: FocusItem?
        rootResponder?.visitFocusResponders { responder in
            guard let item = responder.focusItem, item.isFocusable else { return .next }
            if (item.platformResponder ?? host)?.isFirstResponder == true {
                result = item
                return .cancel
            }
            return .next
        }
        let oldItem = focusedItem
        focusedItem = result
        if focusedItem != nil {
            let item = focusedItem
            let host = host
            onNextMainRunLoop {
                (item?.platformResponder ?? host)?.becomeFirstResponder()
            }
        } else if oldItem?.platformResponder != nil {
            (oldItem?.platformResponder ?? host)?.resignFirstResponder()
        }
    }

    private func focusViewProvider(containing view: UIView) -> (any PlatformFocusViewProvider)? {
        var ancestor = view.superview
        while let current = ancestor {
            if let provider = current as? any PlatformFocusViewProvider {
                return provider
            }
            ancestor = current.superview
        }
        return nil
    }
}
#endif

#if os(macOS)
// MARK: - AppKit focus

extension FocusBridge {
    func resetFocus(in namespace: Namespace.ID?) {
        guard let host else { return }
        let firstResponder = host.window?.firstResponder as? NSView
        let hostIsFirstResponder = firstResponder === host
            || (firstResponder as? KeyViewProxy)?.host === host
        guard !flags.contains(.resettingFocus) else { return }
        let hasFocusedItem = focusedItem != nil
        guard hostIsFirstResponder || hasFocusedItem else { return }
        flags.insert(.resettingFocus)
        if hostIsFirstResponder {
            hostDidBecomeFirstResponder(in: namespace)
        } else {
            host.window?.makeFirstResponder(host)
        }
        flags.remove(.resettingFocus)
    }

    var isKeyViewRedirectionDisabled: Bool {
        guard let host else { return false }
        return flags.contains(.resettingFocus)
            || host.window.map { !$0.isVisible || $0._keyViewRedirectionDisabled } == true
    }

    var hostAcceptsFirstResponder: Bool {
        guard isKeyViewRedirectionDisabled,
              let responder = navigator.firstNavigableItem?.responder else { return false }
        return !responder.isInVisibleRect
    }

    var designatedFocusRingView: NSView? {
        focusedItem?.responder?.focusRingView
    }

    var sortedCandidateKeyViews: AnySequence<NSView>? {
        guard let sequence = navigator.allItems else { return nil }
        return AnySequence {
            var iterator = sequence.makeIterator()
            var previous: NSView?
            return AnyIterator {
                while let item = iterator.next() {
                    guard let view = item.responder?.firstKeyViewInSubtree,
                          view !== previous else { continue }
                    previous = view
                    return view
                }
                return nil
            }
        }
    }

    var needsPanelToBecomeKey: Bool {
        var result = false
        host?.responderNode?.visitFocusResponders { responder in
            guard let item = responder.focusItem, item.receivesFocusFromMouse else { return .next }
            if case let .platformItem(view) = item.base, view.base != nil {
                return .next
            }
            result = true
            return .cancel
        }
        return result
    }

    func hostHierarchyDidChange() {
        guard let host else { return }
        canAcceptFocus = host.window != nil
        if let window = host.window {
            if window.contentView === host {
                window.autorecalculatesKeyViewLoop = true
            }
        } else {
            hostingViewProxyCache?.recycle()
        }
    }

    func invalidateKeyViewLoop() {
        guard let host else { return }
        if let window = host.window, window.autorecalculatesKeyViewLoop {
            window._setKeyViewLoopNeedsRecalc(true)
        } else {
            let next = tailKeyView?.nextKeyView
            updateDefaultKeyViewLoop()?.nextKeyView = next
        }
    }

    func updateDefaultKeyViewLoop() -> NSView? {
        var previous: NSView? = host
        let cache: KeyViewProxyCache
        if let hostingViewProxyCache {
            cache = hostingViewProxyCache
        } else {
            cache = KeyViewProxyCache(bridge: self)
            hostingViewProxyCache = cache
        }
        cache.recycle()
        if var sequence = navigator.allItems {
            while let item = sequence.next() {
                switch item.base {
                case let .platformResponder(view):
                    guard let view = view.base else { continue }
                    let first: NSView = focusViewProvider(containing: view, includingSelf: true) ?? view
                    previous?._primitiveSetNextKeyView(first)
                    let last = first._recursiveSetDefaultKeyViewLoop()
                    item.responder?.firstKeyViewInSubtree = first
                    item.responder?.lastKeyViewInSubtree = last
                    previous = last
                case .view:
                    let proxy = cache.dequeue()
                    if let responder = item.responder {
                        proxy.focusResponder = responder
                        responder.firstKeyViewInSubtree = proxy
                        proxy.frame = sequence.frameCache[ObjectIdentifier(responder)] ?? .zero
                    }
                    previous?._primitiveSetNextKeyView(proxy)
                    previous = proxy
                case .platformItem:
                    break
                }
            }
        }
        tailKeyView = previous
        return previous
    }

    func hostDidBecomeFirstResponder(in namespace: Namespace.ID?) {
        guard let host else { return }
        if !isKeyViewRedirectionDisabled {
            if host.window?.keyViewSelectionDirection != .directSelection {
                hostDidBecomeFirstResponder_macOS_watchOS()
            }
        } else {
            if !_SemanticFeature_v4.isEnabled,
               let item = defaultFocusItem(for: host.responderNode, in: namespace) {
                moveFocus(to: item, designatedPlatformResponder: nil)
            } else {
                hostDidBecomeFirstResponder_macOS_watchOS()
            }
        }
    }

    func defaultFocusItem(
        for responder: @autoclosure () -> ResponderNode?,
        in namespace: Namespace.ID?
    ) -> FocusItem? {
        guard let responder = responder() else { return nil }
        if let base = responder as? any BaseFocusResponder, namespace == nil {
            return navigator.defaultFocusItem(for: base)
        }
        guard let responder = responder as? ViewResponder else { return nil }
        let items = visitDefaultFocusItems(for: responder, in: namespace)
        return items.preferred ?? items.fallback
    }

    private func visitDefaultFocusItems(
        for responder: ViewResponder,
        in namespace: Namespace.ID?
    ) -> (preferred: FocusItem?, fallback: FocusItem?) {
        var preferred: FocusItem?
        var fallback: FocusItem?
        if let item = (responder as? any FocusResponder)?.focusItem, item.isFocusable {
            fallback = item
        }
        for child in responder.children {
            if let base = child as? any BaseFocusResponder,
               base.prefersDefaultFocus,
               base.defaultFocusNamespace == namespace {
                let items = visitDefaultFocusItems(for: child, in: namespace)
                preferred = preferred ?? items.preferred ?? items.fallback
            } else if let childNamespace = (child as? FocusNamespaceViewResponder)?.namespace,
                      childNamespace != namespace {
                if namespace != nil {
                    let items = visitDefaultFocusItems(for: child, in: namespace)
                    preferred = preferred ?? items.preferred
                }
                let items = visitDefaultFocusItems(for: child, in: childNamespace)
                fallback = fallback ?? items.preferred ?? items.fallback
            } else {
                let items = visitDefaultFocusItems(for: child, in: namespace)
                preferred = preferred ?? items.preferred
                fallback = fallback ?? items.fallback
            }
        }
        return (preferred, fallback)
    }

    private func hostDidBecomeFirstResponder_macOS_watchOS() {
        guard let host else { return }
        switch host.window!.keyViewSelectionDirection {
        case .selectingPrevious:
            if let item = navigator.lastHostNavigableItem {
                moveFocus(to: item, designatedPlatformResponder: nil)
            }
        case .selectingNext:
            selectFirstNavigableView()
        default:
            break
        }
    }

    func selectFirstNavigableView() {
        guard let item = navigator.firstNavigableItem, let responder = item.responder else { return }
        if isKeyViewRedirectionDisabled, !responder.isInVisibleRect { return }
        moveFocus(to: item, designatedPlatformResponder: nil)
    }

    func hostProxyDidBecomeFirstResponder(_ proxy: KeyViewProxy) {
        guard proxy.focusBridge === self, let host else { return }
        let direction: NavigationDirection
        switch host.window!.keyViewSelectionDirection {
        case .selectingNext: direction = .next
        case .selectingPrevious: direction = .previous
        default: return
        }
        let item: FocusItem?
        if focusedItem == nil {
            item = direction == .next ? navigator.firstNavigableItem : navigator.lastNavigableItem
        } else {
            item = navigator.focusItemByNavigating(toward: direction, options: .wrapAround)
        }
        if let item {
            moveFocus(to: item, designatedPlatformResponder: proxy)
        } else if direction == .previous {
            if host.previousValidKeyView != nil {
                host.forwardToChain(#selector(NSWindow.selectPreviousKeyView(_:)), from: host)
            } else if let item = navigator.lastNavigableItem {
                moveFocus(to: item, designatedPlatformResponder: nil)
            }
        } else if host.nextValidKeyView != nil {
            host.forwardToChain(#selector(NSWindow.selectNextKeyView(_:)), from: host)
        } else {
            selectFirstNavigableView()
        }
    }

    func selectKeyView(sender: Any?, receiver: NSView, direction: NavigationDirection) {
        guard let host else { return }
        if let item = navigator.focusItemByNavigating(toward: direction, options: []) {
            guard let window = host.window else { return }
            let oldDirection = window.keyViewSelectionDirection
            window._setKeyViewSelectionDirection(direction == .next ? .selectingNext : .selectingPrevious)
            moveFocus(to: item, designatedPlatformResponder: receiver)
            window._setKeyViewSelectionDirection(oldDirection)
            return
        }
        let next = direction == .next ? receiver.nextValidKeyView : receiver.previousValidKeyView
        if next == nil || (next as? any FocusBridgeProvider)?.focusBridge === self {
            if direction == .previous {
                if let item = navigator.lastNavigableItem {
                    moveFocus(to: item, designatedPlatformResponder: nil)
                }
            } else {
                selectFirstNavigableView()
            }
        } else {
            host.forwardToChain(
                direction == .next
                    ? #selector(NSWindow.selectNextKeyView(_:))
                    : #selector(NSWindow.selectPreviousKeyView(_:)),
                from: sender
            )
        }
    }

    func firstResponderDidChange(to firstResponder: NSResponder?, rootResponder: ResponderNode?) {
        guard let host, isValidFirstResponderChange(to: firstResponder) else { return }
        let view = firstResponder as? NSView
        guard let view = view?.window?._accessibilityViewCorrectedForFieldEditor(view) else {
            focusedItem = nil
            return
        }
        let currentView: NSView? = focusedItem.map { item in
            if case let .platformResponder(view) = item.base, let view = view.base {
                return view
            }
            return host
        }
        if view === currentView { return }
        if view === host {
            hostDidBecomeFirstResponder(in: nil)
            return
        }
        if let proxy = view as? KeyViewProxy, proxy.host === host {
            hostProxyDidBecomeFirstResponder(proxy)
            return
        }
        let ancestor = focusViewProvider(containing: view, includingSelf: false)?.focusView
        if let provider = view as? any PlatformFocusResponderProvider {
            focusedItem = FocusItem(
                base: .platformResponder(WeakBox(view)),
                prefersFocusSystem: false,
                responder: provider.focusViewResponder
            )
            return
        }
        var result: FocusItem?
        rootResponder?.visitFocusResponders { responder in
            guard let item = responder.focusItem else { return .next }
            if item.isFocusable {
                let target: NSView
                if case let .platformResponder(view) = item.base, let view = view.base {
                    target = view
                } else {
                    target = host
                }
                if target === view {
                    result = item
                    return .cancel
                }
            }
            if case let .platformResponder(container) = item.base,
               let container = container.base, ancestor?.isDescendant(of: container) == true {
                result = FocusItem(
                    base: .platformResponder(WeakBox(view)),
                    prefersFocusSystem: false,
                    responder: responder
                )
                return .cancel
            }
            return .next
        }
        focusedItem = result
    }

    private func isValidFirstResponderChange(to firstResponder: NSResponder?) -> Bool {
        guard let host else { return false }
        guard firstResponder === host.window,
              host.window?.keyViewSelectionDirection != .directSelection,
              case let .platformResponder(view) = focusedItem?.base,
              view.base is NSTextField else { return true }
        host.window?.queueFirstResponderChange(for: host)
        return false
    }

    private func focusViewProvider(
        containing view: NSView,
        includingSelf: Bool
    ) -> (any PlatformFocusViewProvider)? {
        var ancestor = includingSelf ? view : view.superview
        while let current = ancestor {
            if let provider = current as? any PlatformFocusViewProvider {
                return provider
            }
            ancestor = current.superview
        }
        return nil
    }
}

extension FocusResponder {
    var lastValidKeyViewInSubtree: NSView? {
        guard let last = lastKeyViewInSubtree,
              case let .platformResponder(view) = focusItem?.base,
              let view = view.base else { return nil }
        let candidate = last.canBecomeKeyView ? last : last.previousValidKeyView
        guard let candidate, candidate.isDescendant(of: view) else { return nil }
        return candidate
    }
}

extension NSResponder {
    fileprivate func forwardToChain(_ selector: Selector, from sender: Any?) {
        var responder = nextResponder
        while let current = responder {
            if current.responds(to: selector) {
                current.perform(selector, with: sender)
                return
            }
            responder = current.nextResponder
        }
    }
}
#endif
