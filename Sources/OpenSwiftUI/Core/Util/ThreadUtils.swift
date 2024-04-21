//
//  ThreadUtils.swift
//  
//
//  Created by Kyle on 2024/4/21.
//

import Foundation

@inline(__always)
func performOnMainThread(_ block: @escaping () -> Void) {
    #if os(WASI)
    // See #76: Thread and RunLoopMode.common is not available on WASI currently
    block()
    #else
    if Thread.isMainThread {
        block()
    } else {
        RunLoop.main.perform(inModes: [.common], block: block)
    }
    #endif
}
