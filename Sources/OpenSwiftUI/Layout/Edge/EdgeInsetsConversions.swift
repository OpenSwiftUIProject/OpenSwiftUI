//
//  EdgeInsetsConversions.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

#if canImport(Darwin)
// MARK: - EdgeInsets + Conversion

#if canImport(UIKit)
public import UIKit
#elseif canImport(AppKit)
public import AppKit
#endif

extension EdgeInsets {
    /// Create edge insets from the equivalent NSDirectionalEdgeInsets.
    @available(watchOS, unavailable)
    public init(_ nsEdgeInsets: NSDirectionalEdgeInsets) {
        self.init(
            top: nsEdgeInsets.top,
            leading: nsEdgeInsets.leading,
            bottom: nsEdgeInsets.bottom,
            trailing: nsEdgeInsets.trailing
        )
    }
}

extension NSDirectionalEdgeInsets {
    /// Create edge insets from the equivalent EdgeInsets.
    @available(watchOS, unavailable)
    public init(_ edgeInsets: EdgeInsets) {
        self.init(
            top: edgeInsets.top,
            leading: edgeInsets.leading,
            bottom: edgeInsets.bottom,
            trailing: edgeInsets.trailing
        )
    }
}
#endif
