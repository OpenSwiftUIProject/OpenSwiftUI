//
//  UIGraphicsView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#if os(iOS)
internal import OpenSwiftUI_SPI
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
