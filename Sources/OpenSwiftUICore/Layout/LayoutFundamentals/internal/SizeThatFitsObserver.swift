//
//  SizeThatFitsObserver.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

import Foundation

struct SizeThatFitsObserver {
    var proposal: _ProposedSize
    var callback: (CGSize, CGSize) -> Void
}
