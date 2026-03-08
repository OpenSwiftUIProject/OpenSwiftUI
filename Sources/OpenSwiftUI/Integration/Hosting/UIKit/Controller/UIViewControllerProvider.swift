//
//  UIViewControllerProvider.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)
public import UIKit
import COpenSwiftUI

// MARK: - UIViewControllerProvider

package protocol UIViewControllerProvider: AnyObject {
    var uiViewController: UIViewController? { get }
}

extension UIViewControllerProvider {
    package var containingViewController: UIViewController? {
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
