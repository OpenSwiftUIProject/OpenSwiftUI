//
//  PlatformViewHost.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: BAC0C59DB8B5BCCA55C0A700794CB41E (SwiftUI)

#if canImport(Darwin)
import OpenSwiftUICore
import Foundation
import OpenSwiftUI_SPI

// MARK: - PlatformViewHost [WIP]

#if canImport(AppKit)
import AppKit
typealias PlatformEdgeInsets = NSEdgeInsets
typealias PlatformConstraintBasedLayoutHostingView = _NSConstraintBasedLayoutHostingView
#elseif canImport(UIKit)
import UIKit
typealias PlatformEdgeInsets = UIEdgeInsets
typealias PlatformConstraintBasedLayoutHostingView = _UIConstraintBasedLayoutHostingView
#endif

class PlatformViewHost<Representable>: PlatformConstraintBasedLayoutHostingView, AnyPlatformViewProviderHost where Representable: PlatformViewRepresentable {
    var importer: EmptyPreferenceImporter

    var environment: EnvironmentValues

    var viewPhase: _GraphInputs.Phase

    let representedViewProvider: Representable.PlatformViewProvider

    weak var host: ViewRendererHost?

    enum ViewControllerParentingMode {
        case willMoveToSuperview
        case didMoveToWindow
    }

    var viewHierarchyMode: ViewControllerParentingMode?

    var focusedValues: FocusedValues

    weak var responder: PlatformViewResponder?

//    let safeAreaHelper: UIView.SafeAreaHelper

    private var _safeAreaInsets: PlatformEdgeInsets

    var inLayoutSizeThatFits: Bool

    var cachedImplementsFittingSize: Bool?

    var layoutInvalidator: PlatformViewLayoutInvalidator?

    var invalidationPending: Bool

    var cachedLayoutTraits: _LayoutTraits?

    init(
        importer: EmptyPreferenceImporter,
        environment: EnvironmentValues,
        viewPhase: _GraphInputs.Phase,
        representedViewProvider: Representable.PlatformViewProvider
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didAddSubview(_ subview: PlatformView) {
        super.didAddSubview(subview)
        _openSwiftUIUnimplementedFailure()
    }

    func layoutTraits() -> _LayoutTraits {
        _openSwiftUIUnimplementedFailure()
    }

    /*override*/ func _setHostsLayoutEngine(_ a: Bool) {
        guard enableUnifiedLayout() else {
            return
        }
        // super._setHostsLayoutEngine(a)
    }

    func updateSafeAreaInsets(_ insets: PlatformEdgeInsets?) {
        // TODO
        _openSwiftUIUnimplementedWarning()
    }
}

func enableUnifiedLayout() -> Bool {
    isLinkedOnOrAfter(.maximal) || EnableUnifiedLayoutFeature.isEnabled
}

// MARK: - EnableUnifiedLayoutFeature

private struct EnableUnifiedLayoutFeature: UserDefaultKeyedFeature {
    static var key: String {
        "org.OpenSwiftUIProject.OpenSwiftUI.EnableUnifiedLayout"
    }

    static var cachedValue: Bool?
}
#endif
