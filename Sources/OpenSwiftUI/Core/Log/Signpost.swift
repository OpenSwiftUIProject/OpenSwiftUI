//
//  Signpost.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 34756F646CF7AC3DBE2A8E0B344C962F

#if canImport(os)
import os.signpost
#endif

struct Signpost {
    private let style: Style
    private let stability: Stability
    
    // TODO
    var isEnabled: Bool {
        switch stability {
        case .disabled, .verbose, .debug:
            return false
        case .published:
            return true
        }
    }
    
    static let viewHost = Signpost(style: .kdebug(0), stability: .published)
}

extension Signpost {
    private enum Style {
        case kdebug(UInt8)
        case os_log(StaticString)
    }
    
    private enum Stability: Hashable {
        case disabled
        case verbose
        case debug
        case published
    }
}


