//
//  SafeAreaHelper.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP (Unimplemented)
//  ID: 36F4CE8257AE99191765DF6F47D9C4C0 (SwiftUI?)

protocol SafeAreaHelperDelegate: AnyObject {
    var _safeAreaInsets: PlatformEdgeInsets { get set }
    var defaultSafeAreaInsets: PlatformEdgeInsets { get }
    var containerView: PlatformView { get }
    var shouldEagerlyUpdatesSafeArea: Bool { get }
}

#if os(iOS)
import UIKit

extension UIView {
    final class SafeAreaHelper {
        private var pendingSafeAreaInsets: UIEdgeInsets?
        private var lastParentSafeAreaInsets: UIEdgeInsets?

        func updateSafeAreaInsets<Delegate>(
            _ insets: UIEdgeInsets?,
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
        ) -> UIEdgeInsets where Delegate: SafeAreaHelperDelegate {
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
