//
//  _ProposedSize.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/12/17.
//  Lastest Version: iOS 15.5
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
