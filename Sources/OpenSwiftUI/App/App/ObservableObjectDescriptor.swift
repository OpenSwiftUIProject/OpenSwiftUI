//
//  ObservableObjectDescriptor.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import COpenSwiftUI

struct ObservableObjectDescriptor: ProtocolDescriptor {
    static var descriptor: UnsafeRawPointer {
        _observableObjectProtocolDescriptor()
    }
}
