//
//  UnsafeHeterogeneousBuffer.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: 568350FE259575B5E1AAA52AD722AAAC (SwiftUICore)

package struct UnsafeHeterogeneousBuffer: Collection {
    var buf: UnsafeMutableRawPointer!
    var available: Int32
    var _count: Int32
    
    package typealias VTable = _UnsafeHeterogeneousBuffer_VTable
    package typealias Element = _UnsafeHeterogeneousBuffer_Element
    
    package struct Index: Equatable, Comparable {
        var index: Int32
        var offset: Int32
        
        package static func < (lhs: Index, rhs: Index) -> Bool {
            lhs.index < rhs.index
        }
        
        package static func == (a: Index, b: Index) -> Bool {
            a.index == b.index && a.offset == b.offset
        }
    }
    
    package struct Item {
        let vtable: _UnsafeHeterogeneousBuffer_VTable.Type
        let size: Int32
        var flags: UInt32
    }
    
    package var count: Int { Int(_count) }
    package var isEmpty: Bool { _count == 0 }
    
    package var startIndex: Index {
        Index(index: 0, offset: 0)
    }
    package var endIndex: Index {
        Index(index: _count, offset: 0)
    }
    
    package init() {
        buf = nil
        available = 0
        _count = 0
    }
    
    private mutating func allocate(_ bytes: Int) -> UnsafeMutableRawPointer {
        var size = 0
        for element in self {
            size += Int(element.item.pointee.size)
        }
        // Grow buffer if needed
        if Int(available) < bytes {
            growBuffer(by: bytes, capacity: size + Int(available))
        }
        let ptr = buf.advanced(by: size)
        available = available - Int32(bytes)
        return ptr
    }
    
    private mutating func growBuffer(by size: Int, capacity: Int) {
        let expectedSize = size + capacity
        var allocSize = Swift.max(capacity &* 2, 64)
        while allocSize < expectedSize {
            allocSize &*= 2
        }
        let allocatedBuffer = UnsafeMutableRawPointer.allocate(
            byteCount: allocSize,
            alignment: .zero
        )
        if let buf {
            var count = _count
            if count != 0 {
                var itemSize: Int32 = 0
                var oldBuffer = buf
                var newBuffer = allocatedBuffer
                repeat {
                    count &-= 1
                    let newItemPointer = newBuffer.assumingMemoryBound(to: Item.self)
                    let oldItemPointer = oldBuffer.assumingMemoryBound(to: Item.self)
                    
                    if count == 0 {
                        itemSize = 0
                    } else {
                        itemSize &+= oldItemPointer.pointee.size
                    }
                    newItemPointer.initialize(to: oldItemPointer.pointee)                    
                    oldItemPointer.pointee.vtable.moveInitialize(
                        elt: .init(item: newItemPointer),
                        from: .init(item: oldItemPointer)
                    )
                    let size = Int(oldItemPointer.pointee.size)
                    oldBuffer += size
                    newBuffer += size
                } while count != 0 || itemSize != 0
            }
            buf.deallocate()
        }
        buf = allocatedBuffer
        available += Int32(allocSize - capacity)
    }
    
    package func destroy() {
        defer { buf?.deallocate() }
        for element in self {
            element.item.pointee.vtable.deinitialize(elt: element)
        }
    }
    
    package func formIndex(after index: inout Index) {
        index = self.index(after: index)
    }
    
    package func index(after index: Index) -> Index {
        let item = self[index].item.pointee
        let newIndex = index.index &+ 1
        if newIndex == _count {
            return Index(index: newIndex, offset: 0)
        } else {
            let newOffset = index.offset &+ item.size
            return Index(index: newIndex, offset: newOffset)
        }
    }
    
    package subscript(index: Index) -> Element {
        .init(item: buf
            .advanced(by: Int(index.offset))
            .assumingMemoryBound(to: Item.self)
        )
    }
    
    @discardableResult
    package mutating func append<T>(_ value: T, vtable: VTable.Type) -> Index {
        let bytes = MemoryLayout<T>.size + MemoryLayout<UnsafeHeterogeneousBuffer.Item>.size
        let pointer = allocate(bytes)
        let element = _UnsafeHeterogeneousBuffer_Element(item: pointer.assumingMemoryBound(to: Item.self))
        element.item.initialize(to: Item(vtable: vtable, size: Int32(bytes), flags: 0))
        element.body(as: T.self).initialize(to: value)
        let index = Index(index: _count, offset: Int32(pointer - buf))
        _count += 1
        return index
    }
}

@_spi(ForOpenSwiftUIOnly)
public struct _UnsafeHeterogeneousBuffer_Element {
    var item: UnsafeMutablePointer<UnsafeHeterogeneousBuffer.Item>
    
    package func hasType<T>(_ type: T.Type) -> Bool {
        item.pointee.vtable.hasType(type)
    }
    
    package func vtable<T>(as type: T.Type) -> T.Type where T: _UnsafeHeterogeneousBuffer_VTable {
        address.assumingMemoryBound(to: Swift.type(of: type)).pointee
    }
    
    package func body<T>(as type: T.Type) -> UnsafeMutablePointer<T> {
        UnsafeMutableRawPointer(item.advanced(by: 1)).assumingMemoryBound(to: type)
    }
    
    package var flags: UInt32 {
        get { item.pointee.flags }
        nonmutating set { item.pointee.flags = newValue }
    }
    
    package var address: UnsafeRawPointer {
        UnsafeRawPointer(item)
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension _UnsafeHeterogeneousBuffer_Element: Sendable {}

@_spi(ForOpenSwiftUIOnly)
open class _UnsafeHeterogeneousBuffer_VTable {
    open class func hasType<T>(_ type: T.Type) -> Bool {
        false
    }
    
    open class func moveInitialize(elt: _UnsafeHeterogeneousBuffer_Element, from: _UnsafeHeterogeneousBuffer_Element) {
        _openSwiftUIBaseClassAbstractMethod()
    }
    
    open class func deinitialize(elt: _UnsafeHeterogeneousBuffer_Element) {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension _UnsafeHeterogeneousBuffer_VTable: Sendable {}
