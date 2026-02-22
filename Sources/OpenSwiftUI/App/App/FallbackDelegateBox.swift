//
//  FallbackDelegateBox.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation
#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif
import OpenObservation

class AnyFallbackDelegateBox {
    var delegate: NSObject? {
        nil
    }

    func addDelegate(to env: inout EnvironmentValues) {
        _openSwiftUIEmptyStub()
    }
}

#if canImport(Darwin)
// NSObject on Cocoa platform has a init() method. We use PlatformApplicationDelegateBase to align them.
typealias PlatformApplicationDelegateBase = NSObject
#else
protocol PlatformApplicationDelegateBase: NSObject {
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

// MARK: - ObservableObjectFallbackDelegateBox

class ObservableObjectFallbackDelegateBox<Delegate>: AnyFallbackDelegateBox where Delegate: PlatformApplicationDelegateBase, Delegate: ObservableObject {
    var typedDelegate: Delegate

    override init() {
        self.typedDelegate = Delegate()
        super.init()
    }

    override var delegate: NSObject? {
        typedDelegate
    }

    override func addDelegate(to env: inout EnvironmentValues) {
        let keyPath = Delegate.environmentStore
        env[keyPath: keyPath] = typedDelegate
    }
}

// MARK: - UnsafeObservableObjectFallbackDelegateBox

class UnsafeObservableObjectFallbackDelegateBox<Delegate>: AnyFallbackDelegateBox where Delegate: ObservableObject {
    var typedDelegate: Delegate

    init(_ delegate: Delegate) {
        self.typedDelegate = delegate
        super.init()
    }

    override var delegate: NSObject? {
        typedDelegate as? NSObject
    }

    override func addDelegate(to env: inout EnvironmentValues) {
        let keyPath = Delegate.environmentStore
        env[keyPath: keyPath] = typedDelegate
    }
}

// MARK: - ObservableFallbackDelegateBox

class ObservableFallbackDelegateBox<Delegate>: AnyFallbackDelegateBox where Delegate: PlatformApplicationDelegateBase, Delegate: Observable {
    var typedDelegate: Delegate

    override init() {
        self.typedDelegate = Delegate()
        super.init()
    }

    override var delegate: NSObject? {
        typedDelegate
    }

    override func addDelegate(to env: inout EnvironmentValues) {
        env[objectType: Delegate.self] = typedDelegate
    }
}

// MARK: - ObjectFallbackDelegateBox

class ObjectFallbackDelegateBox<Delegate>: AnyFallbackDelegateBox where Delegate: AnyObject {
    var typedDelegate: Delegate

    init(_ delegate: Delegate) {
        self.typedDelegate = delegate
        super.init()
    }

    override var delegate: NSObject? {
        typedDelegate as? NSObject
    }

    override func addDelegate(to env: inout EnvironmentValues) {
        env[objectType: type(of: typedDelegate)] = typedDelegate
    }
}

// MARK: - ObservableObjectTypeVisitor

protocol ObservableObjectTypeVisitor {
    mutating func visit<T>(type: T.Type) where T: ObservableObject
}

// MARK: - MakeObservableObjectDelegateBox

struct MakeObservableObjectDelegateBox: ObservableObjectTypeVisitor {
    var value: Any
    var box: AnyFallbackDelegateBox?

    mutating func visit<T>(type: T.Type) where T: ObservableObject {
        guard let delegate = value as? T else { return }
        box = UnsafeObservableObjectFallbackDelegateBox<T>(delegate)
    }
}

