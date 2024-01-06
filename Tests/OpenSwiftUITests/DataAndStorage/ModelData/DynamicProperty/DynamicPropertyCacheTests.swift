//
//  DynamicPropertyCacheTests.swift
//  
//
//  Created by Kyle on 2024/1/24.
//

import XCTest
@testable import OpenSwiftUI
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
        var f: DynamicPropertyCache.Fields? = DynamicPropertyCache.Fields(layout: .product(.init()))
        f!.behaviors = .init(rawValue: 0x7)
        withUnsafeBytes(of: &f) { pointer in
            let b = pointer.baseAddress!
            print(b)
        }
        f = nil
        withUnsafeBytes(of: &f) { pointer in
            let b = pointer.baseAddress!
            print(b)
        }
        
        print(result)
    }
}
