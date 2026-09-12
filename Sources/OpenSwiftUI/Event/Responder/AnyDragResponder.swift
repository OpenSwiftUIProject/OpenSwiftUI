//
//  AnyDragResponder.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - AnyDragResponder

protocol AnyDragResponder: ViewResponder {
    var isDragEnabled: Bool { get }
}

// MARK: - PrimitiveDragResponder

class PrimitiveDragResponder: DefaultLayoutViewResponder, AnyDragResponder {
    var isDragEnabled: Bool = false
}
