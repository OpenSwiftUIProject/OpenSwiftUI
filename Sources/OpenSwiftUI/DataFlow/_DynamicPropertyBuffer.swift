//
//  _DynamicPropertyBuffer.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/24.
//  Lastest Version: iOS 15.5
//  Status: Complete

import Foundation

public struct _DynamicPropertyBuffer {
    var buf: UnsafeMutableRawPointer
    var size: Int32
    var _count: Int32
}
