//
//  IsInHostingConfiguration.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUICore

struct IsInHostingConfiguration: ViewInputBoolFlag {}

extension _GraphInputs {
    @inline(__always)
    var isInHostingConfiguration: Bool {
        get { IsInHostingConfiguration.evaluate(inputs: self) }
        set { self[IsInHostingConfiguration.self] = newValue }
    }
}

extension _ViewInputs {
    @inline(__always)
    var isInHostingConfiguration: Bool {
        get { base.isInHostingConfiguration }
        set { base.isInHostingConfiguration = newValue }
    }
}
