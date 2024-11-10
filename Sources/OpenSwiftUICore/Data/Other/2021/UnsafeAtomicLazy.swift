//
//  UnsafeAtomicLazy.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

#if OPENSWIFTUI_RELEASE_2021

import OpenSwiftUI_SPI

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
