//
//  _DynamicPropertyBuffer.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/24.
//  Lastest Version: iOS 15.5
//  Status: Complete
//  ID: 68550FF604D39F05971FE35A26EE75B0

public struct _DynamicPropertyBuffer {
    var buf: UnsafeMutableRawPointer
    var size: Int32
    var _count: Int32
    
    init(fields _: DynamicPropertyCache.Fields, container _: _GraphValue<some Any>, inputs _: inout _GraphInputs, baseOffset _: Int) {
        fatalError("")
    }

    func append(_: some DynamicPropertyBox, fieldOffset _: Int) {}

    func addFields(_: DynamicPropertyCache.Fields, container _: _GraphValue<some Any>, inputs _: inout _GraphInputs, baseOffset _: Int) {}
}

extension _DynamicPropertyBuffer {
    private struct Item {
        var vtable: BoxVTableBase.Type
        var size: Int32
        var _fieldOffsetAndLastChanged: UInt32
        
        init(vtable: BoxVTableBase, size: Int, fieldOffset: Int) {
            
            fatalError("TODO")
            
//            self.vtable = vtable
//            self.size = size
//            self._fieldOffsetAndLastChanged = _fieldOffsetAndLastChanged
//            if size < 0 {
//                
//            } else {
//                
//            }
        }
    }
}

// MARK: - BoxVTableBase

private class BoxVTableBase {
    static func moveInitialize(ptr _: UnsafeMutableRawPointer, from _: UnsafeMutableRawPointer) {
        fatalError()
    }
    
    static func deinitialize(ptr _: UnsafeMutableRawPointer) {}

    static func reset(ptr _: UnsafeMutableRawPointer) {}

    static func update(ptr _: UnsafeMutableRawPointer, property _: UnsafeMutableRawPointer, phase _: _GraphInputs.Phase) -> Bool {
        false
    }
    
    static func getState<Value>(ptr _: UnsafeMutableRawPointer, type _: Value.Type) -> Binding<Value>? {
        nil
    }
}
