//
//  ProposedSize.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

import Foundation

public struct _ProposedSize: Hashable {
    var width: CGFloat?
    var height: CGFloat?
    
    static let unspecified = _ProposedSize(width: nil, height: nil)
    
    @inline(__always)
    static var zero: _ProposedSize {
        _ProposedSize(width: .zero, height: .zero)
    }
    
    @inline(__always)
    static var infinity: _ProposedSize {
        _ProposedSize(width: .infinity, height: .infinity)
    }
    
    @inline(__always)
    init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.width = width
        self.height = height
    }
    
    @inline(__always)
    init(size: CGSize) {
        width = size.width
        height = size.height
    }
}
