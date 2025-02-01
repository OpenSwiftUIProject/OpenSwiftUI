//
//  UIHostingViewable.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP

#if os(iOS)
public import Foundation
import UIKit

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

@available(macOS, unavailable)
public func _makeUIHostingController(_ view: AnyView, tracksContentSize: Bool, secure: Bool = false) -> NSObject & _UIHostingViewable {
    let hostingController: UIHostingController<AnyView>
    if secure {
        hostingController = _UISecureHostingController(rootView: view)
    } else {
        hostingController = UIHostingController(rootView: view)
    }
    if tracksContentSize {
        // TODO: hostingController.sizingOption
    }
    return hostingController
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

#endif
