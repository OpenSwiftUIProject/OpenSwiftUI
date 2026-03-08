//
//  UnsafeHeterogeneousBufferTests.swift
//  OpenSwiftUICoreTests

#if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
@_private(sourceFile: "UnsafeHeterogeneousBuffer.swift")
#endif
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing

struct UnsafeHeterogeneousBufferTests {
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
        var buffer = UnsafeHeterogeneousBuffer()
        defer { buffer.destroy() }
        #expect(buffer.isEmpty == true)
        
        do {
            let index = buffer.append(UInt32(1), vtable: VTable<Int32>.self)
            #expect(buffer.isEmpty == false)
            #expect(index == buffer.index(atOffset: 0))
            #if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
            #expect(index.index == 0)
            #expect(index.offset == 0)
            #expect(buffer.available == 32)
            #endif
            #expect(buffer.count == 1)
            let element = buffer[index]
            #expect(element.body(as: UInt32.self).pointee == 1)
        }
        
        do {
            let index = buffer.append(Int(-1), vtable: VTable<Int>.self)
            #expect(buffer.isEmpty == false)
            #expect(index == buffer.index(atOffset: 1))
            #if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
            #expect(index.index == 1)
            #expect(index.offset == 32)
            #expect(buffer.available == 0)
            #endif
            #expect(buffer.count == 2)
            let element = buffer[index]
            #expect(element.body(as: Int.self).pointee == -1)
        }
        
        do {
            let index = buffer.append(Double.infinity, vtable: VTable<Double>.self)
            #expect(buffer.isEmpty == false)
            #expect(index == buffer.index(atOffset: 2))
            #if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
            #expect(index.index == 2)
            #expect(index.offset == 64)
            #expect(buffer.available == 32)
            #endif
            #expect(buffer.count == 3)
            let element = buffer[index]
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
            var buffer = UnsafeHeterogeneousBuffer()
            defer { buffer.destroy() }
            #expect(buffer.isEmpty == true)
            let box = DeinitBox { confirm() }
            let index = buffer.append(box, vtable: VTable<DeinitBox>.self)
            let element = buffer[index]
            #expect(element.body(as: DeinitBox.self).pointee === box)
        }
    }
}
