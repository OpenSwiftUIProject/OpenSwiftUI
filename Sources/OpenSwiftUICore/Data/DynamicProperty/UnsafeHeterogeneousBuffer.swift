//
//  UnsafeHeterogeneousBuffer.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 568350FE259575B5E1AAA52AD722AAAC (SwiftUICore)


/// UnsafeHeterogeneousBuffer -> [buf]
///                        [available,_count]
/// buf -> [element1, element2, element3, ...]
/// element -> [Item, Value] / [vtable, size+flags, value...]0
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
        let remainingCapacity = Int(available)
        var remainingItemCount = _count
        
        // Calculate total size of existing items
        let totalSize: Int
        if remainingItemCount == 0 {
            totalSize = 0
        } else {
            var currentOffset: Int = 0
            var currentSize: Int = 0
            repeat {
                // Get size of current item
                let itemSize = buf
                    .advanced(by: currentOffset)
                    .assumingMemoryBound(to: Item.self)
                    .pointee
                    .size
                currentOffset &+= Int(itemSize)
                remainingItemCount &-= 1
                
                // Reset offset when all items processed
                currentOffset = remainingItemCount == 0 ? 0 : currentOffset
                currentSize &+= Int(itemSize)
            } while remainingItemCount != 0
            totalSize = Int(currentSize)
        }
        
        // Grow buffer if needed
        if remainingCapacity < bytes {
            growBuffer(by: bytes, capacity: totalSize + remainingCapacity)
        }
        let ptr = buf.advanced(by: totalSize)
        available = available - Int32(bytes)
        return ptr
    }
    
    private mutating func growBuffer(by: Int, capacity: Int) {
        print("Hello \(by) \(capacity)")
    }
    
    package func destroy() {
        defer { buf?.deallocate() }
        guard _count != 0 else {
            return
        }
        // TODO
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
        buf.advanced(by: Int(index.offset))
            .assumingMemoryBound(to: Element.self)
            .pointee
    }
    
    @discardableResult
    package mutating func append<T>(_ value: T, vtable: VTable.Type) -> Index {
        let bytes = MemoryLayout<T>.size + MemoryLayout<UnsafeHeterogeneousBuffer.Item>.size
        let elementPtr = allocate(bytes)
        let size = Int32(bytes)
        let element = elementPtr
            .assumingMemoryBound(to: _UnsafeHeterogeneousBuffer_Element.self)
            .pointee
        element.item.initialize(to: .init(vtable: vtable, size: size, flags: 0)) // VERIFY ME
        // Store the value via move_init
        let index = Index(index: _count, offset: Int32(elementPtr - buf))
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
        preconditionFailure("")
    }
    
    open class func deinitialize(elt: _UnsafeHeterogeneousBuffer_Element) {
        preconditionFailure("")
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension _UnsafeHeterogeneousBuffer_VTable: Sendable {}
