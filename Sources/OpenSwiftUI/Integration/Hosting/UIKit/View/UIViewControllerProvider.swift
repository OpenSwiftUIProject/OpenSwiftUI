//
//  UIViewControllerProvider.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)

import UIKit

protocol UIViewControllerProvider: AnyObject {
    var uiViewController: UIViewController? { get }
}

extension UIViewControllerProvider {
    var containingViewController: UIViewController? {
        if let uiViewController {
            return uiViewController
        } else if let view = self as? UIView {
            return view._viewControllerForAncestor
        } else {
            return nil
        }
    }
}

#endif
