//
//  ThreadUtils.swift
//  
//
//  Created by Kyle on 2024/4/21.
//

import Foundation

@inline(__always)
func performOnMainThread(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        RunLoop.main.perform(inModes: [.common], block: block)
    }
}
