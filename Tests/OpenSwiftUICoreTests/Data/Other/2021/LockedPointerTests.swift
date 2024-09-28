//
//  LockedPointerTests.swift
//
//
//  Created by Kyle on 2023/10/19.
//

@testable import OpenSwiftUICore
import COpenSwiftUICore
import Testing

struct LockedPointerTests {
    @Test
    func alignmentOffset() {
        // The alignment of a struct type is the maximum alignment out of all its properties.
        // Between an Int and a Bool, the Int has a larger alignment value of 8, so the struct uses it.
        struct A {
            let v1: Int
            let v2: Bool
        }
        struct B {
            let v1: Bool
            let v2: Int
        }
        struct C {
            let v1: SIMD3<Int>
            let v2: Bool
        }
        
        #expect(MemoryLayout<A>.size == 9)
        #expect(MemoryLayout<A>.stride == 16)
        #expect(MemoryLayout<A>.alignment == 8)

        #expect(MemoryLayout<B>.size == 16)
        #expect(MemoryLayout<B>.stride == 16)
        #expect(MemoryLayout<B>.alignment == 8)
        
        #expect(MemoryLayout<C>.size == 33)
        #expect(MemoryLayout<C>.stride == 48)
        #expect(MemoryLayout<C>.alignment == 16)
        
        let p1 = LockedPointer(type: A.self)
        let p2 = LockedPointer(type: B.self)
        let p3 = LockedPointer(type: C.self)
        defer {
            p1.delete()
            p2.delete()
            p3.delete()
        }
        #expect(p1.rawValue.pointee.offset == 8)
        #expect(p2.rawValue.pointee.offset == 8)
        #expect(p3.rawValue.pointee.offset == 16)
    }

    @Test
    func locking() {
        #if canImport(os)
        let pointer = LockedPointer(type: Int.self)
        #expect(pointer.rawValue.pointee.lock._os_unfair_lock_opaque == 0)
        pointer.lock()
        #expect(pointer.rawValue.pointee.lock._os_unfair_lock_opaque != 0)
        pointer.unlock()
        #expect(pointer.rawValue.pointee.lock._os_unfair_lock_opaque == 0)
        #else
        let pointer = LockedPointer(type: Int.self)
        #expect(pointer.rawValue.pointee.lock == 0)
        pointer.lock()
        #expect(pointer.rawValue.pointee.lock != 0)
        pointer.unlock()
        #expect(pointer.rawValue.pointee.lock == 0)
        #endif
    }
}
