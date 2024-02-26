//
//  _ProposedSize.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#if canImport(Darwin)
import CoreGraphics
#else
import Foundation
#endif

struct _ProposedSize: Hashable {
    var width: CGFloat?
    var height: CGFloat?
}
