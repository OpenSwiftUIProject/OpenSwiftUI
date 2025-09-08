//
//  SafeAreaHelper.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP (Unimplemented)
//  ID: 36F4CE8257AE99191765DF6F47D9C4C0 (SwiftUI?)

#if canImport(Darwin)

protocol SafeAreaHelperDelegate: AnyObject {
    var _safeAreaInsets: PlatformEdgeInsets { get set }
    var defaultSafeAreaInsets: PlatformEdgeInsets { get }
    var containerView: PlatformView { get }
    var shouldEagerlyUpdatesSafeArea: Bool { get }
}

#if os(iOS) || os(visionOS)
import UIKit
typealias PlatformEdgeInsets = UIEdgeInsets
#elseif os(macOS)
import AppKit
typealias PlatformEdgeInsets = NSEdgeInsets
extension NSEdgeInsets {
    static var zero: NSEdgeInsets {
        NSEdgeInsetsZero
    }
}
#endif

extension PlatformView {
    final class SafeAreaHelper {
        private var pendingSafeAreaInsets: PlatformEdgeInsets?
        private var lastParentSafeAreaInsets: PlatformEdgeInsets?

        func updateSafeAreaInsets<Delegate>(
            _ insets: PlatformEdgeInsets?,
            delegate: Delegate
        ) where Delegate: SafeAreaHelperDelegate {
            _openSwiftUIUnimplementedWarning()
        }

        func prepareForSafeAreaPropagation<Delegate>(
            delegate: Delegate
        ) where Delegate: SafeAreaHelperDelegate {
            _openSwiftUIUnimplementedWarning()
        }

        func resolvedSafeAreaInsets<Delegate>(
            delegate: Delegate
        ) -> PlatformEdgeInsets where Delegate: SafeAreaHelperDelegate {
            _openSwiftUIUnimplementedWarning()
            return .zero
        }

        private func adjustSafeAreaIfNeeded<Delegate>(
            delegate: Delegate
        ) where Delegate: SafeAreaHelperDelegate {
            _openSwiftUIUnimplementedWarning()
        }
    }
}

#endif
