//
//  ViewSize.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

import Foundation

package struct ViewSize: Equatable {
    var value: CGSize
    var _proposal: CGSize
    
    @inline(__always)
    static var zero: ViewSize { ViewSize(value: .zero, _proposal: .zero) }
}

extension CGSize {
    static let invalidValue: CGSize = CGSize(width: -.infinity, height: -.infinity)
}
