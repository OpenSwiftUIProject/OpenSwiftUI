//
//  ObservableObjectDescriptor.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import COpenSwiftUI
#if OPENSWIFTUI_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif

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

// MARK: - ObservableObjectDescriptor

struct ObservableObjectDescriptor: ProtocolDescriptor {
    static var descriptor: UnsafeRawPointer {
        _observableObjectProtocolDescriptor()
    }
}

// MARK: - TypeConformance + ObservableObjectDescriptor

extension TypeConformance where P == ObservableObjectDescriptor {
    func visitType<V>(visitor: UnsafeMutablePointer<V>) where V: ObservableObjectTypeVisitor {
        visitor.pointee.visit(type: unsafeExistentialMetatype((any ObservableObject.Type).self))
    }
}
