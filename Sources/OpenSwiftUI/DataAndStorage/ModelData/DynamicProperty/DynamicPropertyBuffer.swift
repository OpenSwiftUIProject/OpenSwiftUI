//
//  DynamicPropertyBuffer.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/24.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 68550FF604D39F05971FE35A26EE75B0

private let nullPtr: UnsafeMutableRawPointer = Unmanaged.passUnretained(unsafeBitCast(0, to: AnyObject.self)).toOpaque()

public struct _DynamicPropertyBuffer {
    var buf: UnsafeMutableRawPointer
    var size: Int32
    var _count: Int32
    
    init() {
        buf = nullPtr
        size = 0
        _count = 0
    }
    
    init<Value>(
        fields: DynamicPropertyCache.Fields,
        container: _GraphValue<Value>,
        inputs: inout _GraphInputs,
        baseOffset: Int
    ) {
        self.init()
        addFields(fields, container: container, inputs: &inputs, baseOffset: baseOffset)
    }

    mutating func addFields<Value>(
        _ fields: DynamicPropertyCache.Fields,
        container: _GraphValue<Value>,
        inputs: inout _GraphInputs,
        baseOffset: Int
    ) {
        switch fields.layout {
        case let .product(fieldArray):
            for field in fieldArray {
                field.type._makeProperty(
                    in: &self,
                    container: container,
                    fieldOffset: field.offset + baseOffset,
                    inputs: &inputs
                )
            }
        case let .sum(_, taggedFields):
            guard !taggedFields.isEmpty else {
                return
            }
            // TODO
        }
    }
    
    func append(_: some DynamicPropertyBox, fieldOffset _: Int) {
        // TODO
    }
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
    class func moveInitialize(
        ptr _: UnsafeMutableRawPointer,
        from _: UnsafeMutableRawPointer
    ) {
        fatalError()
    }
    
    class func deinitialize(ptr _: UnsafeMutableRawPointer) {}

    class func reset(ptr _: UnsafeMutableRawPointer) {}

    class func update(
        ptr _: UnsafeMutableRawPointer,
        property _: UnsafeMutableRawPointer,
        phase _: _GraphInputs.Phase
    ) -> Bool {
        false
    }
    
    class func getState<Value>(
        ptr _: UnsafeMutableRawPointer,
        type _: Value.Type
    ) -> Binding<Value>? {
        nil
    }
}

private class BoxVTable<Box: DynamicPropertyBox>: BoxVTableBase {
    override class func moveInitialize(ptr destination: UnsafeMutableRawPointer, from: UnsafeMutableRawPointer) {
        let fromBoxPointer = from.assumingMemoryBound(to: Box.self)
        let destinationBoxPointer = destination.assumingMemoryBound(to: Box.self)
        destinationBoxPointer.initialize(to: fromBoxPointer.move())
    }
    
    override class func deinitialize(ptr: UnsafeMutableRawPointer) {
        let boxPointer = ptr.assumingMemoryBound(to: Box.self)
        boxPointer.pointee.destroy()
        boxPointer.deinitialize(count: 1)
    }
    
    override class func reset(ptr: UnsafeMutableRawPointer) {
        let boxPointer = ptr.assumingMemoryBound(to: Box.self)
        boxPointer.pointee.reset()
    }
    
    override class func update(
        ptr: UnsafeMutableRawPointer,
        property: UnsafeMutableRawPointer,
        phase: _GraphInputs.Phase
    ) -> Bool {
        let boxPointer = ptr.assumingMemoryBound(to: Box.self)
        let propertyPointer = property.assumingMemoryBound(to: Box.Property.self)
        let isUpdated = boxPointer.pointee.update(property: &propertyPointer.pointee, phase: phase)
        if isUpdated {
            // TODO: OSSignpost
        }
        return isUpdated
    }
    
    override class func getState<Value>(ptr: UnsafeMutableRawPointer, type: Value.Type) -> Binding<Value>? {
        let boxPointer = ptr.assumingMemoryBound(to: Box.self)
        return boxPointer.pointee.getState(type: type)
    }
}
