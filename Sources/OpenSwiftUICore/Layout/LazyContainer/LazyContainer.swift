//
//  LazyContainer.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

struct IsInLazyContainer: ViewInputBoolFlag  {}

extension _GraphInputs {
    @inline(__always)
    package var isInLazyContainer: Bool {
        get { self[IsInLazyContainer.self]  }
        set { self[IsInLazyContainer.self] = newValue }
    }
}

extension _ViewInputs {
    package mutating func coreConfigureForLazyContainer() {
        isInLazyContainer = true
    }

    package var isInLazyContainer: Bool {
        get { base.isInLazyContainer }
        set { base.isInLazyContainer = newValue }
    }
}

extension _ViewListInputs {
    package var isInLazyContainer: Bool {
        get { base.isInLazyContainer }
        set { base.isInLazyContainer = newValue }
    }
}
