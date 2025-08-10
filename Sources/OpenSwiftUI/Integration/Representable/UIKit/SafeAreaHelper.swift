//
//  SafeAreaHelper.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP (Unimplemented)
//  ID: 36F4CE8257AE99191765DF6F47D9C4C0 (SwiftUI?)

#if os(iOS)
import UIKit

protocol SafeAreaHelperDelegate: AnyObject {
    var _safeAreaInsets: UIEdgeInsets { get set }
    var defaultSafeAreaInsets: UIEdgeInsets { get }
    var containerView: UIView { get }
    var shouldEagerlyUpdatesSafeArea: Bool { get }
}

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
