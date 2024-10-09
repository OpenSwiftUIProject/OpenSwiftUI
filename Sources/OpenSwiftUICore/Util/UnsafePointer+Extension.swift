//
//  UnsafePointer+Extension.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

extension UnsafePointer {
    package subscript() -> Pointee {
        @_transparent
        unsafeAddress {
            self
        }
    }
    
    @_transparent
    package static var null: UnsafePointer<Pointee> {
        UnsafePointer(bitPattern: Int(bitPattern: UInt.max - 0xff) | (-MemoryLayout<Pointee>.alignment))!
    }
}

extension UnsafeMutablePointer {
    package subscript() -> Pointee {
        @_transparent
        unsafeAddress { UnsafePointer(self) }
        @_transparent
        nonmutating unsafeMutableAddress { self }
    }
    
    @_transparent
    package static var null: UnsafeMutablePointer<Pointee> {
        UnsafeMutablePointer(bitPattern: Int(bitPattern: UInt.max - 0xff) | (-MemoryLayout<Pointee>.alignment))!
    }
}

extension UnsafeBufferPointer {
    @_transparent
    package var startAddress: UnsafePointer<Element> {
        baseAddress ?? .null
    }
}


extension UnsafeMutableBufferPointer {
    @_transparent
    package var startAddress: UnsafeMutablePointer<Element> {
        baseAddress ?? .null
    }
}
