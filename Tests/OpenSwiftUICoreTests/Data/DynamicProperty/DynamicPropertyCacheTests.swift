//
//  DynamicPropertyCacheTests.swift
//  
//
//  Created by Kyle on 2024/1/24.
//

import XCTest
@testable import OpenSwiftUICore
import OpenGraphShims

final class DynamicPropertyCacheTests: XCTestCase {
    func testExample() throws {
        let a = MemoryLayout<DynamicPropertyCache.Fields>.size
        print(a)
        let b = MemoryLayout<DynamicPropertyCache.Fields.Layout>.size
        print(b)
        let c = MemoryLayout<DynamicPropertyCache.Fields?>.size
        print(c)
        let d = MemoryLayout<DynamicPropertyBehaviors>.size
        print(d)
        
        
        let t = OGTypeID(DynamicPropertyCache.Fields?.self)
        let result = t.forEachField(options: ._4) { name, index, type in
            let s = String(cString: name)
            print("\(s) \(index) \(type)")
            return true
        }
        var f: DynamicPropertyCache.Fields? = nil
        f = DynamicPropertyCache.Fields(layout: .product(.init()))
        f!.behaviors = .init(rawValue: 0x7)
        withUnsafeBytes(of: &f) { pointer in
            print(pointer.baseAddress!)
        }
        f = nil
        withUnsafeBytes(of: &f) { pointer in
            print(pointer.baseAddress!)
        }
        f = DynamicPropertyCache.Fields(layout: .sum(Int.self, []))
        f!.behaviors = .init(rawValue: 0x7)
        withUnsafeBytes(of: &f) { pointer in
            print(pointer.baseAddress!)
        }
        f = nil
        withUnsafeBytes(of: &f) { pointer in
            print(pointer.baseAddress!)
        }
        print(result)
    }
}
