//
//  ProposedSize.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

import Foundation

struct _ProposedSize: Hashable {
    var width: CGFloat?
    var height: CGFloat?
    
    static let unspecified = _ProposedSize(width: nil, height: nil)
}
