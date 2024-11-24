//  FixedRoundedRect.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

import Foundation

@usableFromInline
struct FixedRoundedRect: Equatable {
    var rect: CGRect
    var cornerSize: CGSize
    var style: RoundedCornerStyle
    
    func contains(_ roundedRect: FixedRoundedRect) -> Bool {
        guard rect.insetBy(dx: -0.001, dy: -0.001).contains(roundedRect.rect) else {
            return false
        }
        guard !(cornerSize.width <= roundedRect.cornerSize.width && cornerSize.height <= roundedRect.cornerSize.height) else {
            return true
        }
        let minCornerWidth = min(abs(rect.size.width) / 2, cornerSize.width)
        let minCornerHeight = min(abs(rect.size.height) / 2, cornerSize.height)
        let factor = 0.292893 // 1 - cos(45 * Double.pi / 180)
        return rect.insetBy(dx: minCornerWidth * factor, dy: minCornerHeight * factor).contains(roundedRect.rect)
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        preconditionFailure("TODO")
    }
}
