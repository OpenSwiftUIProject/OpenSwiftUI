//
//  UnsafeAtomicLazy.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

#if OPENSWIFTUI_RELEASE_2021

internal import OpenSwiftUI_SPI

package struct UnsafeAtomicLazy<Data>: Destroyable {
    @UnsafeLockedPointer
    package var cache: Data?
    
    package init(cache: Data? = nil) {
        self.cache = cache
    }
    
    package func read(_ block: () -> Data) -> Data {
        fatalError("TODO") // StrokedPath.boundingRect
    }

    package func destroy() {
        _cache.destroy()
    }
}

#endif
