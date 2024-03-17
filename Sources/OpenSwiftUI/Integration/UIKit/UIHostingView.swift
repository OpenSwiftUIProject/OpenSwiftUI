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
    var inheritedEnvironment: EnvironmentValues?
    var environmentOverride: EnvironmentValues?
    weak var viewController: UIHostingController<Content>?
    var isEnteringForeground = false
    
    public init(rootView: Content) {
        // TODO
        _rootView = rootView
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
}

extension _UIHostingView: ViewRendererHost {
    
}

extension UITraitCollection {
    var baseEnvironment: EnvironmentValues {
        // TODO
        EnvironmentValues()
    }
}
#endif
