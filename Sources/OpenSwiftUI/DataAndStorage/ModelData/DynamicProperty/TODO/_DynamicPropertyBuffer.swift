//
//  _DynamicPropertyBuffer.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/24.
//  Lastest Version: iOS 15.5
//  Status: Complete

public struct _DynamicPropertyBuffer {
    var buf: UnsafeMutableRawPointer
    var size: Int32
    var _count: Int32

    func append<Box: DynamicPropertyBox>(_ box: Box, fieldOffset: Int) {
    }

    func addFields<Value>(_ fields: DynamicPropertyCache.Fields, container: _GraphValue<Value>, inputs: inout _GraphInputs, baseOffset: Int) {
        
    }
}
