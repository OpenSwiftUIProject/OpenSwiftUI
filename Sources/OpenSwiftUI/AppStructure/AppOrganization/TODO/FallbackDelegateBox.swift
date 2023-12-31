//
//  FallbackDelegateBox.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: WIP

#if canImport(Darwin)
import Foundation
#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif

class AnyFallbackDelegateBox {
    var delegate: NSObject? { nil }
    func addDelegate(to _: inout EnvironmentValues) {}
}

class FallbackDelegateBox<Delegate: NSObject>: AnyFallbackDelegateBox {
    // 0x10
    var storage: DelegateStorage
    
    enum DelegateStorage {
        case type(_ type: Delegate.Type)
        case instance(_ delegate: Delegate)
    }
    
    init(_ delegate: Delegate?) {
        let storage: DelegateStorage = if let delegate {
            .instance(delegate)
        } else {
            .type(Delegate.self)
        }
        self.storage = storage
        super.init()
    }
    
    override var delegate: NSObject? {
        switch storage {
        case let .type(type):
            let delegate = type.init()
            storage = .instance(delegate)
            return delegate
        case let .instance(delegate):
            return delegate
        }
    }
}
#endif
