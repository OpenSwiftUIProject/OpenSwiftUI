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

// MARK: - PlatformViewHost [WIP]

class PlatformViewHost<Representable>: /*_UIConstraintBasedLayoutHostingView*/ PlatformView
    where Representable: PlatformViewRepresentable {
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

    //    var _safeAreaInsets: UIEdgeInsets

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
}

// MARK: - EnableUnifiedLayoutFeature

private struct EnableUnifiedLayoutFeature: UserDefaultKeyedFeature {
    static var key: String {
        "org.OpenSwiftUIProject.OpenSwiftUI.EnableUnifiedLayout"
    }

    static var cachedValue: Bool?
}
#endif
