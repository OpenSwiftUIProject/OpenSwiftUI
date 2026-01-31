//
//  InitialSceneSizeState.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUICore

enum InitialSceneSizeState {
    case unset(_ProposedSize)
    case none
    case setting
    case set
}
