//
//  Signpost.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 34756F646CF7AC3DBE2A8E0B344C962F

internal import OpenGraphShims
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
    
    static let render = Signpost(style: .kdebug(0), stability: .published)
    static let renderUpdate = Signpost(style: .kdebug(0), stability: .published)
    static let viewHost = Signpost(style: .kdebug(9), stability: .published)
    static let bodyInvoke = Signpost(style: .kdebug(5), stability: .published)
    
    @_transparent
    @inline(__always)
    func traceInterval<R>(
        object: AnyObject? = nil,
        _ message: StaticString?,
        closure: () -> R
    ) -> R {
        guard isEnabled else {
            return closure()
        }
        // TODO
        return closure()
    }
    
    @_transparent
    @inline(__always)
    func traceInterval<R>(
        object: AnyObject? = nil,
        _ message: StaticString?,
        _ arguments: @autoclosure () -> [CVarArg],
        closure: () -> R
    ) -> R {
        guard isEnabled else {
            return closure()
        }
        // TODO
        return closure()
    }
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

@_transparent
@inline(__always)
// FIXME
func traceRuleBody<R>(_ type: Any.Type, body: () -> R) -> R {
    Signpost.bodyInvoke.traceInterval(
        "%{public}@.body [in %{public}@]",
        [OGTypeID(type).description, Tracing.libraryName(defining: type)]
    ) {
        body()
    }
}
