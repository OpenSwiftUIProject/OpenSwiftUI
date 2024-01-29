//
//  DynamicPropertyBuffer.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/24.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 68550FF604D39F05971FE35A26EE75B0

internal import OpenGraphShims

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
    
    func destroy() {
        // TODO
    }
    
    func reset() {
        // TODO
    }
    
    func getState<Value>(type: Value.Type) -> Binding<Value>? {
        // TODO
        return nil
    }
    
    func update(container: UnsafeMutableRawPointer, phase: _GraphInputs.Phase) -> Bool {
        // TODO
        return false
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

// MARK: - BoxVTable

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

// MARK: - EnumVTable

private struct EnumBox {
    var cases: [(tag: Int, links: _DynamicPropertyBuffer)]
    var active: (tag: Swift.Int, index: Swift.Int)?
}

private class EnumVTable<Enum>: BoxVTableBase {
    override class func moveInitialize(ptr destination: UnsafeMutableRawPointer, from: UnsafeMutableRawPointer) {
        let fromBoxPointer = from.assumingMemoryBound(to: EnumBox.self)
        let destinationBoxPointer = destination.assumingMemoryBound(to: EnumBox.self)
        destinationBoxPointer.initialize(to: fromBoxPointer.move())
    }
        
    override class func deinitialize(ptr: UnsafeMutableRawPointer) {
        let boxPointer = ptr.assumingMemoryBound(to: EnumBox.self)
        for (_, links) in boxPointer.pointee.cases {
            links.destroy()
        }
    }
    
    override class func reset(ptr: UnsafeMutableRawPointer) {
        let boxPointer = ptr.assumingMemoryBound(to: EnumBox.self)
        guard let (_, index) = boxPointer.pointee.active else {
            return
        }
        boxPointer.pointee.cases[index].links.reset()
        boxPointer.pointee.active = nil
    }
    
    
    override class func update(ptr: UnsafeMutableRawPointer, property: UnsafeMutableRawPointer, phase: _GraphInputs.Phase) -> Bool {
        var isUpdated = false
        withUnsafeMutablePointerToEnumCase(of: property.assumingMemoryBound(to: Enum.self)) { tag, type, pointer in
            let boxPointer = ptr.assumingMemoryBound(to: EnumBox.self)
            if let (activeTag, index) = boxPointer.pointee.active, activeTag != tag {
                boxPointer.pointee.cases[index].links.reset()
                boxPointer.pointee.active = nil
                isUpdated = true
            } 
            if boxPointer.pointee.active == nil {
                guard let matchedIndex = boxPointer.pointee.cases.firstIndex(where: { $0.tag == tag }) else {
                    return
                }
                boxPointer.pointee.active = (tag, matchedIndex)
                isUpdated = true
            }
            if let (_, index) = boxPointer.pointee.active {
                isUpdated = boxPointer.pointee.cases[index].links.update(container: pointer, phase: phase)
            }
        }
        return isUpdated
    }
    
    override class func getState<Value>(ptr: UnsafeMutableRawPointer, type: Value.Type) -> Binding<Value>? {
        let boxPointer = ptr.assumingMemoryBound(to: EnumBox.self)
        guard let (_, index) = boxPointer.pointee.active else {
            return nil
        }
        return boxPointer.pointee.cases[index].links.getState(type: type)
    }
}
