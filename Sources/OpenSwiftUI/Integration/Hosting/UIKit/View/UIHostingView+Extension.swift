//
//  UIHostingView+Render.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

#if os(iOS) || os(visionOS)
public import UIKit
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
public import OpenSwiftUICore

// MARK: - _UIHostingView + UIViewControllerProvider

extension _UIHostingView: UIViewControllerProvider {
    package var uiViewController: UIViewController? {
        viewController
    }
}

// MARK: - _UIHostingView + UIHostingViewBaseDelegate

extension _UIHostingView: UIHostingViewBaseDelegate {
    package var shouldDisableUIKitAnimations: Bool {
        guard allowUIKitAnimations == 0,
              !base.allowUIKitAnimationsForNextUpdate,
              !isInSizeTransition,
              !isResizingSheet,
              !isRotatingWindow,
              !isTabSidebarMorphing
        else {
            return false
        }
        return true
    }

    package func sceneActivationStateDidChange() {
        _openSwiftUIUnimplementedWarning()
    }
}

// MARK: - _UIHostingView + HostingViewProtocol

@_spi(Private)
extension _UIHostingView: HostingViewProtocol {
    public func convertAnchor<Value>(_ anchor: Anchor<Value>) -> Value {
        anchor.convert(to: viewGraph.transform)
    }
}

// MARK: - _UIHostingView + TestHost [6.4.41]

extension _UIHostingView: TestHost {
    package func setTestSize(_ size: CGSize) {
        let newSize: CGSize
        if size == CGSize.deviceSize {
            let screenSize = UIDevice.current.screenSize
            let idiom = UIDevice.current.userInterfaceIdiom
            if idiom == .pad, screenSize.width < screenSize.height {
                newSize = CGSize(width: screenSize.height, height: screenSize.width)
            } else {
                if idiom == .phone, screenSize.height < screenSize.width {
                    newSize = CGSize(width: screenSize.height, height: screenSize.width)
                } else {
                    newSize = screenSize
                }
            }
        } else {
            newSize = size
        }
        if bounds.size != newSize {
            allowFrameChanges = true
            bounds.size = newSize
            allowFrameChanges = false
        }
    }

    package func setTestSafeAreaInsets(_ insets: EdgeInsets) {
        explicitSafeAreaInsets = insets

    }

    package var testSize: CGSize { bounds.size }

    package var viewCacheIsEmpty: Bool {
        Update.locked {
            renderer.viewCacheIsEmpty
        }
    }

    package func forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {
        let tree = preferenceValue(_IdentifiedViewsKey.self)
        tree.forEach { proxy in
            var proxy = proxy
            proxy.adjustment = { [weak self] rect in
                guard let self else { return }
                rect = convert(rect, from: nil)
            }
            body(proxy)
        }
    }

    package func forEachDescendantHost(body: (any TestHost) -> Void) {
        forEachDescendantHost { (view: UIView) in
            if let testHost = view as? any TestHost {
                body(testHost)
            }
        }
    }

    package func renderForTest(interval: Double) {
        _renderForTest(interval: interval)
    }

    package var attributeCountInfo: AttributeCountTestInfo {
        preferenceValue(AttributeCountInfoKey.self)
    }

    public func _renderForTest(interval: Double) {
        func shouldContinue() -> Bool {
            if propertiesNeedingUpdate == [], !CoreTesting.needsRender {
                false
            } else {
                times >= 0
            }
        }
        advanceTimeForTest(interval: interval)
        _base.canAdvanceTimeAutomatically = false
        var times = 16
        repeat {
            times -= 1
            CoreTesting.needsRender = false
            updateGraph { host in
                host.flushTransactions()
            }
            RunLoop.flushObservers()
            render(targetTimestamp: nil)
            CATransaction.flush()
        } while shouldContinue()
        CoreTesting.needsRender = false
        _base.canAdvanceTimeAutomatically = true
    }
}

extension UIDevice {
    package var screenSize: CGSize {
        #if !os(visionOS) || OPENSWIFTUI_INTERNAL_XR_SDK
        let screenBounds = UIScreen.main.bounds
        let screenWidth = screenBounds.width
        let screenHeight = screenBounds.height
        let orientation = UIDevice.current.orientation
        let finalWidth: CGFloat
        let finalHeight: CGFloat
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            // In landscape, swap dimensions to ensure width > height
            finalWidth = max(screenWidth, screenHeight)
            finalHeight = min(screenWidth, screenHeight)
        case .portrait, .portraitUpsideDown:
            // In portrait, keep original dimensions (height > width)
            finalWidth = screenWidth
            finalHeight = screenHeight
        default:
            // For other orientations, keep original dimensions
            finalWidth = screenWidth
            finalHeight = screenHeight
        }
        return CGSize(width: finalWidth, height: finalHeight)
        #else
        return .zero
        #endif
    }
}

extension UIView {
    func forEachDescendantHost(body: (UIView) -> Void) {
        body(self)
        for view in subviews {
            view.forEachDescendantHost(body: body)
        }
    }
}

// MARK: - _UIHostingView + ViewRendererHost [WIP]

extension _UIHostingView: ViewRendererHost {
    // MARK: - GraphDelegate conformance

    @_spi(ForOpenSwiftUIOnly)
    public func preferencesDidChange() {
        _openSwiftUIUnimplementedWarning()
    }

    @_spi(ForOpenSwiftUIOnly)
    @available(OpenSwiftUI_v6_0, *)
    public func beginTransaction() {
        onMainThread { [weak self] in
            // TODO: UIKitUpdateCycle
        }
    }

    // MARK: - ViewGraphDelegate conforamnce

    package func `as`<T>(_ type: T.Type) -> T? {
        guard let value = base.as(type) else {
            // TODO: FocuHost, PlatformItemListHost
            if UIViewControllerProvider.self == type {
                return unsafeBitCast(self as any UIViewControllerProvider, to: T.self)
            // TODO: PointerHost, WindowLayoutHost,
            } else if UIView.self == type {
                return unsafeBitCast(self as UIView, to: T.self)
            // TODO: CurrentEventProvider, FallbackResponderProvider, ContainerBackgroundHost, RootTransformUpdater
            } else if ViewRendererHost.self == type {
                return unsafeBitCast(self as any ViewRendererHost, to: T.self)
            // TODO: ViewGraphRenderObserver, ToolbarInputFeatureDelegate
            } else {
                return nil
            }
        }
        return value
    }

    package func requestUpdate(after delay: Double) {
        base.requestUpdate(after: delay)
    }

    // MARK: - ViewRendererHost conformance

    package func updateRootView() {
        let rootView = makeRootView()
        viewGraph.setRootView(rootView)
    }

    package func updateEnvironment() {
        var environment = base.startUpdateEnvironment()
        // WIP
        _openSwiftUIUnimplementedWarning()
        environment.displayScale = traitCollection.displayScale
        if let displayGamut = DisplayGamut(rawValue: traitCollection.displayGamut.rawValue) {
            environment.displayGamut = displayGamut
        }
        environment.feedbackCache = feedbackCache
        viewGraph.setEnvironment(environment)
    }

    package func updateTransform() {
        _openSwiftUIUnimplementedWarning()
    }

    package func updateSize() {
        base.updateSize()
    }
    
    package func updateSafeArea() {
        let changed = viewGraph.setSafeAreaInsets(hostSafeAreaElements)
        if changed {
            invalidateIntrinsicContentSize()
        }
    }

    package func updateContainerSize() {
        base.updateContainerSize()
    }

    package func updateFocusStore() {
        _openSwiftUIUnimplementedWarning()
    }

    package func updateFocusedItem() {
        _openSwiftUIUnimplementedWarning()
    }

    package func updateFocusedValues() {
        _openSwiftUIUnimplementedWarning()
    }

    package func updateAccessibilityEnvironment() {
        _openSwiftUIUnimplementedWarning()
    }
}

// MARK: - _UIHostingView + EventGraphHost

extension _UIHostingView: EventGraphHost {
    package var eventBindingManager: EventBindingManager {
        base.eventBindingManager
    }

    package var focusedResponder: ResponderNode? {
        responderNode
    }
}

// MARK: - _UIHostingView + ViewGraphRenderObserver

extension _UIHostingView: ViewGraphRenderObserver {
    package func didRender() {
        viewController?.didRender()
    }
}

// MARK: - _UIHostingView + UIKitAnimationCooperating

package protocol UIKitAnimationCooperating {
    func beginAllowUIKitAnimations()
    func endAllowUIKitAnimations()
}

extension _UIHostingView {
    package func beginAllowUIKitAnimations() {
        allowUIKitAnimations &+= 1
    }

    package func endAllowUIKitAnimations() {
        allowUIKitAnimations = max(allowUIKitAnimations - 1, 0)
    }
}

// MARK: - _UIHostingView + RootTransformProvider [WIP]

extension _UIHostingView: RootTransformProvider {
    package func rootTransform() -> ViewTransform {
        _openSwiftUIUnimplementedWarning()
        return .init()
    }
}

// MARK: - _UIHostingView + Alignment

extension _UIHostingView {

    @_spi(Private)
    @available(OpenSwiftUI_v6_0, *)
    @available(macOS, unavailable)
    public func horizontalAlignment(_ guide: HorizontalAlignment) -> CGFloat {
        alignment(of: guide, at: bounds.size)
    }

    @_spi(Private)
    @available(OpenSwiftUI_v6_0, *)
    @available(macOS, unavailable)
    public func verticalAlignment(_ guide: VerticalAlignment) -> CGFloat {
        alignment(of: guide, at: bounds.size)
    }
}

// MARK: - _makeUIHostingView

@available(OpenSwiftUI_v2_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
public func _makeUIHostingView<Content>(_ view: Content) -> NSObject where Content: View {
    _UIHostingView(rootView: view)
}

#endif

