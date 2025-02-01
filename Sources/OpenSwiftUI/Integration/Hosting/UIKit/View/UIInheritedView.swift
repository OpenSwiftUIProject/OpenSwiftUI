//
//  UIInheritedView.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

#if os(iOS)
import OpenSwiftUI_SPI
import UIKit

final class _UIInheritedView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !UIViewIgnoresTouchEvents(self) else {
            return nil
        }
        for subview in subviews.reversed() {
            let convertedPoint = convert(point, to: subview)
            let result = subview.hitTest(convertedPoint, with: event)
            if let result {
                return result
            }
        }
        return nil
    }
}
#endif
