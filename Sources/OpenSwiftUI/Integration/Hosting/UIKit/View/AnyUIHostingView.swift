//
//  AnyUIHostingView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

package protocol AnyUIHostingView: AnyObject {
    var eventBridge: UIKitEventBindingBridge { get set }
    var debugName: String? { get }
}
#endif
