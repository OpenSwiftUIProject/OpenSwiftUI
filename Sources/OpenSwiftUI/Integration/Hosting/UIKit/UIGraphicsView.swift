//
//  UIGraphicsView.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

#if os(iOS)
import OpenSwiftUI_SPI
import UIKit

class _UIGraphicsView: UIView {    
    override func _shouldAnimateProperty(withKey key: String) -> Bool {
        if layer.hasBeenCommitted() {
            super._shouldAnimateProperty(withKey: key)
        } else {
            false
        }
    }
}
#endif
