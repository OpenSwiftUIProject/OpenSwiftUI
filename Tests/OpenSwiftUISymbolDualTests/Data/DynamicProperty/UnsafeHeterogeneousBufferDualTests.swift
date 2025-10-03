//
//  UnsafeHeterogeneousBufferDualTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
@_spi(ForOpenSwiftUIOnly)
@testable
import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

extension UnsafeHeterogeneousBuffer {
    @_silgen_name("OpenSwiftUITestStub_UnsafeHeterogeneousBuffer_Init")
    init(swiftUI: Void)

    @_silgen_name("OpenSwiftUITestStub_UnsafeHeterogeneousBuffer_Destroy")
    func swiftUI_destroy()

    @_silgen_name("OpenSwiftUITestStub_UnsafeHeterogeneousBuffer_Append")
    mutating func swiftUI_append<T>(_ value: T, vtable: VTable.Type) -> Index

    var swiftUI_isEmpty: Bool {
        @_silgen_name("OpenSwiftUITestStub_UnsafeHeterogeneousBuffer_IsEmpty")
        get
    }

    @_silgen_name("OpenSwiftUITestStub_UnsafeHeterogeneousBuffer_IndexOffsetBy")
    func swiftUI_index(_ index: Index, offsetBy n: Int) -> Index

    subscript(swiftUI index: Index) -> Element {
        @_silgen_name("OpenSwiftUITestStub_UnsafeHeterogeneousBuffer_Subscript")
        get
    }
}

struct UnsafeHeterogeneousBufferDualTests {
    private final class VTable<Value>: _UnsafeHeterogeneousBuffer_VTable {
        override class func hasType<T>(_ type: T.Type) -> Bool {
            Value.self == T.self
        }
        
        override class func moveInitialize(elt: _UnsafeHeterogeneousBuffer_Element, from: _UnsafeHeterogeneousBuffer_Element) {
            let dest = elt.body(as: Value.self)
            let source = from.body(as: Value.self)
            dest.initialize(to: source.move())
        }
        
        override class func deinitialize(elt: _UnsafeHeterogeneousBuffer_Element) {
            elt.body(as: Value.self).deinitialize(count: 1)
        }
    }
    
    @Test
    func structBuffer() {
        var buffer = UnsafeHeterogeneousBuffer(swiftUI: ())
        defer { buffer.swiftUI_destroy() }
        #expect(buffer.swiftUI_isEmpty == true)

        do {
            let index = buffer.swiftUI_append(UInt32(1), vtable: VTable<Int32>.self)
            #expect(buffer.swiftUI_isEmpty == false)
            #expect(index == buffer.index(atOffset: 0))
            #expect(index.index == 0)
            #expect(index.offset == 0)
            #expect(buffer.available == 32)
            #expect(buffer.count == 1)
            let element = buffer[swiftUI: index]
            #expect(element.body(as: UInt32.self).pointee == 1)
        }
        
        do {
            let index = buffer.swiftUI_append(Int(-1), vtable: VTable<Int>.self)
            #expect(buffer.swiftUI_isEmpty == false)
            #expect(index == buffer.index(atOffset: 1))
            #expect(index.index == 1)
            #expect(index.offset == 32)
            #expect(buffer.available == 0)
            #expect(buffer.count == 2)
            let element = buffer[swiftUI: index]
            #expect(element.body(as: Int.self).pointee == -1)
        }
        
        do {
            let index = buffer.swiftUI_append(Double.infinity, vtable: VTable<Double>.self)
            #expect(buffer.swiftUI_isEmpty == false)
            #expect(index == buffer.index(atOffset: 2))
            #expect(index.index == 2)
            #expect(index.offset == 64)
            #expect(buffer.available == 32)
            #expect(buffer.count == 3)
            let element = buffer[swiftUI: index]
            #expect(element.body(as: Double.self).pointee == Double.infinity)
        }
    }
    
    @Test
    func classBuffer() async throws {
        final class DeinitBox {
            let deinitBlock: () -> Void
            
            init(deinitBlock: @escaping () -> Void) {
                self.deinitBlock = deinitBlock
            }
            
            deinit {
                deinitBlock()
            }
        }
        
        await confirmation { confirm in
            var buffer = UnsafeHeterogeneousBuffer(swiftUI: ())
            defer { buffer.swiftUI_destroy() }
            #expect(buffer.swiftUI_isEmpty == true)
            let box = DeinitBox { confirm() }
            let index = buffer.swiftUI_append(box, vtable: VTable<DeinitBox>.self)
            let element = buffer[swiftUI: index]
            #expect(element.body(as: DeinitBox.self).pointee === box)
        }
    }
}
#endif
