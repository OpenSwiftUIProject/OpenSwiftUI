//
//  FallbackDelegateBox.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

public import Foundation
#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif

class AnyFallbackDelegateBox {
    var delegate: NSObject? {
        nil
    }

    func addDelegate(to env: inout EnvironmentValues) {
        _openSwiftUIEmptyStub()
    }
}

#if canImport(Darwin)
public typealias PlatformApplicationDelegateBase = NSObject
#else
public protocol PlatformApplicationDelegateBase: NSObject {
    init()
}
#endif

class FallbackDelegateBox<Delegate>: AnyFallbackDelegateBox where Delegate: PlatformApplicationDelegateBase {
    enum DelegateStorage {
        case type(_ type: Delegate.Type)
        case instance(_ delegate: Delegate)
    }

    var storage: DelegateStorage


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

// TODO
