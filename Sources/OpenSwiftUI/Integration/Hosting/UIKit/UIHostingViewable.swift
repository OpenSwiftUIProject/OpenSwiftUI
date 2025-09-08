//
//  UIHostingViewable.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

#if os(iOS) || os(visionOS)
public import Foundation
import UIKit

/// Abstract the bits UV needs to know about UIHostingController so it doesn't
/// need to rely on UIHostingController existing in the SDK, which it can't in
/// the watchOS SDK
@available(macOS, unavailable)
public protocol _UIHostingViewable: AnyObject {
    var rootView: AnyView { get set }
    func _render(seconds: Double)
    func _forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void)
    func sizeThatFits(in size: CGSize) -> CGSize
    var _disableSafeArea: Bool { get set }
    var _rendererConfiguration: _RendererConfiguration { get set }
    var _rendererObject: AnyObject? { get }
}

@available(macOS, unavailable)
extension UIHostingController: _UIHostingViewable where Content == AnyView {}

@available(macOS, unavailable)
public func _makeUIHostingController(_ view: AnyView) -> any NSObject & _UIHostingViewable {
    UIHostingController(rootView: view)
}

final class _UISecureHostingController<Content>: UIHostingController<Content> where Content: View {
    override init(rootView: Content) {
        super.init(rootView: rootView)
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    override var _canShowWhileLocked: Bool {
        true
    }
}

@available(macOS, unavailable)
public func _makeUIHostingController(_ view: AnyView, tracksContentSize: Bool, secure: Bool = false) -> NSObject & _UIHostingViewable {
    let hostingController: UIHostingController<AnyView>
    if secure {
        hostingController = _UISecureHostingController(rootView: view)
    } else {
        hostingController = UIHostingController(rootView: view)
    }
    if tracksContentSize {
        hostingController.sizingOptions = .preferredContentSize
    }
    return hostingController
}

@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
public func _makeWatchKitUIHostingController(_ view: AnyView) -> any NSObject & _UIHostingViewable {
    fatalError("TODO")
}

#endif
