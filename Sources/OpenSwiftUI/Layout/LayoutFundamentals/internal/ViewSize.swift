//
//  ViewSize.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

import Foundation

struct ViewSize: Equatable {
    var value: CGSize
    var _proposal: CGSize
    
    @inline(__always)
    static var zero: ViewSize { ViewSize(value: .zero, _proposal: .zero) }
}

extension CGSize {
    static let invalidValue: CGSize = CGSize(width: -.infinity, height: -.infinity)
}
