//
//  UIGraphicsView.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

#if os(iOS)
import OpenSwiftUI_SPI
import UIKit

class _UIGraphicsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func _shouldAnimateProperty(withKey key: String) -> Bool {
        if layer.hasBeenCommitted() {
            super._shouldAnimateProperty(withKey: key)
        } else {
            false
        }
    }
}
#endif
