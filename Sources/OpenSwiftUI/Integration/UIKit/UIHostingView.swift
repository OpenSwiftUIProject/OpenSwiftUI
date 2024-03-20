//
//  UIHostingView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: FAF0B683EB49BE9BABC9009857940A1E

#if os(iOS)
import UIKit

@available(macOS, unavailable)
@available(watchOS, unavailable)
@MainActor(unsafe)
open class _UIHostingView<Content>: UIView where Content: View {
    private var _rootView: Content
    var viewGraph: ViewGraph
    var isRendering: Bool = false
    var inheritedEnvironment: EnvironmentValues?
    var environmentOverride: EnvironmentValues?
    weak var viewController: UIHostingController<Content>?
    var displayLink: DisplayLink?
    var lastRenderTime: Time = .zero
    var canAdvanceTimeAutomatically = true
    var allowLayoutWhenNotVisible = false
    var isEnteringForeground = false
    
    public init(rootView: Content) {
        // TODO
        _rootView = rootView
        viewGraph = ViewGraph(rootViewType: Content.self, requestedOutputs: []) // Fixme
        // TODO
        // FIXME
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var rootView: Content {
        get { _rootView }
        set {
            _rootView = newValue
            invalidateProperties(.init(rawValue: 1), mayDeferUpdate: true)
        }
    }
    
    
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    final public func _viewDebugData() -> [_ViewDebug.Data] {
        // TODO
        []
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard updatesWillBeVisible || allowLayoutWhenNotVisible else {
            return
        }
        guard canAdvanceTimeAutomatically else {
            return
        }
        Update.lock.withLock {
            cancelAsyncRendering()
            let interval: Double
            if let displayLink, displayLink.willRender {
                interval = .zero
            } else {
                interval = renderInterval(timestamp: .now) / UIAnimationDragCoefficient()
            }
            render(interval: interval)
            allowLayoutWhenNotVisible = false
        }
    }
    
    var updatesWillBeVisible: Bool {
        guard let window,
              let scene = window.windowScene else {
            return false
        }
        let environment = inheritedEnvironment ?? traitCollection.baseEnvironment
        switch scene.activationState {
        case .unattached, .foregroundActive, .foregroundInactive:
            return true
        case .background:
            fallthrough
        @unknown default:
            if isEnteringForeground {
                return true
            }
            return environment.scenePhase != .background
        }
    }
    
    func cancelAsyncRendering() {
        Update.lock.withLock {
            displayLink?.cancelAsyncRendering()
        }
    }
    
    private func renderInterval(timestamp: Time) -> Double {
        if lastRenderTime == .zero || lastRenderTime > timestamp {
            lastRenderTime = timestamp - .microseconds(1)
        }
        let interval = timestamp - lastRenderTime
        lastRenderTime = timestamp
        return interval.seconds
    }
}

extension _UIHostingView: ViewRendererHost {
}

extension UITraitCollection {
    var baseEnvironment: EnvironmentValues {
        // TODO
        EnvironmentValues()
    }
}

@_silgen_name("UIAnimationDragCoefficient")
private func UIAnimationDragCoefficient() -> Double

#endif
