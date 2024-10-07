//
//  UnsafePointer+ExtensionTests.swift
//  OpenSwiftUICoreTests

import Testing
import OpenSwiftUICore

struct UnsafePointer_ExtensionTests {
    @Test
    func nullPointer() {
        #expect(UnsafePointer<Int64>.null == UnsafePointer(bitPattern: Int(bitPattern: 0xffff_ffff_ffff_fff8)))
        #expect(UnsafePointer<Int32>.null == UnsafePointer(bitPattern: Int(bitPattern: 0xffff_ffff_ffff_fffc)))
        #expect(UnsafePointer<Int16>.null == UnsafePointer(bitPattern: Int(bitPattern: 0xffff_ffff_ffff_fffe)))
        #expect(UnsafePointer<Int8>.null == UnsafePointer(bitPattern: Int(bitPattern: 0xffff_ffff_ffff_ffff)))
        #expect(UnsafePointer<Bool>.null == UnsafePointer(bitPattern: Int(bitPattern: 0xffff_ffff_ffff_ffff)))
    }
}
