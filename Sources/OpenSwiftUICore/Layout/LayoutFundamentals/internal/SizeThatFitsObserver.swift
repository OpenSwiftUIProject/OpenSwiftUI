//
//  SizeThatFitsObserver.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

import Foundation

struct SizeThatFitsObserver {
    var proposal: _ProposedSize
    var callback: (CGSize, CGSize) -> Void
}
