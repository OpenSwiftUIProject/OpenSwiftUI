//
//  UnsafeAtomicLazy.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

struct UnsafeAtomicLazy<Data>: Destroyable {
    @AtomicBox
    var cache: Data?
    
    func read(_ block: () -> Data) -> Data {
        fatalError("TODO") // StrokedPath.boundingRect
    }

    func destroy() {
//        _cache.destroy()
    }
}
