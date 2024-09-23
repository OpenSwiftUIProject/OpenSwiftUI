//
//  Signpost.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 34756F646CF7AC3DBE2A8E0B344C962F (RELEASE_2021)
//  ID: 59349949219F590F26B6A55CEC9D59A2 (RELEASE_2024)

internal import COpenSwiftUICore
internal import OpenGraphShims
#if canImport(Darwin)
import os.signpost
#endif

extension Signpost {
    package static let render = Signpost.kdebug(0, "Render")
    package static let postUpdateActions = Signpost.kdebug(2, "PostUpdateActions")
    package static let renderUpdate = Signpost.kdebug(3, "RenderUpdate")
    package static let renderFlattened = Signpost.kdebug(4, "RenderFlattened")
    package static let bodyInvoke = Signpost.kdebug(5, "BodyInvoke")
    package static let linkCreate = Signpost.os_log(6, "LinkCreate")
    package static let linkUpdate = Signpost.os_log(7, "LinkUpdate")
    package static let linkDestroy = Signpost.os_log(8, "LinkDestroy")
    package static let viewHost = Signpost.kdebug(9, "ViewHost")
    package static let platformView = Signpost.os_log(10, "ViewMapping")
    package static let platformUpdate = Signpost.os_log(11, "PlatformViewUpdate")
    package static let animationState = Signpost.os_log(12, "AnimationState")
    package static let eventHandling = Signpost.os_log(13, "EventHandling")
}

#if canImport(Darwin)
private let _signpostLog = OSLog(subsystem: Log.subsystem, category: "OpenSwiftUI")
#endif

package struct Signpost {
    #if canImport(Darwin)
    package static let archiving = OSSignposter(logger: Log.archiving)
    package static let metaExtraction = OSSignposter(logger: Log.metadataExtraction)
    #endif
    
    package static let moduleName: String = Tracing.libraryName(defining: Signpost.self)
    
    @inlinable
    package static func os_log(_: UInt8, _ name: StaticString) -> Signpost {
        Signpost(style: .os_log(name), stability: .debug)
    }
    
    @inlinable
    package static func kdebug(_ code: UInt8, _: StaticString?) -> Signpost {
        Signpost(style: .kdebug(code), stability: .debug)
    }

    package static func kdebug(_ code: UInt8) -> Signpost {
        Signpost(style: .kdebug(code), stability: .debug)
    }
    
    private enum Style {
        case kdebug(UInt8)
        case os_log(StaticString)
    }
    
    private enum Stability: Hashable {
        case disabled
        case verbose
        case debug
        case published
        
        @inline(__always)
        static var valid: [Stability] {
            #if DEBUG
            [.debug, .published]
            #else
            [.published]
            #endif
        }
    }
    
    private let style: Style
    private let stability: Stability
    
    @inlinable
    package var disabled: Signpost {
        Signpost(style: style, stability: .disabled)
    }
    
    @inlinable
    package var verbose: Signpost {
        Signpost(style: style, stability: .verbose)
    }
    
    @inlinable
    package var published: Signpost {
        Signpost(style: style, stability: .published)
    }
    
    package var isEnabled: Bool {
        guard Stability.valid.contains(where: { $0 == stability }) else {
            return false
        }
        #if canImport(Darwin)
        switch style {
        case let .kdebug(code):
            return kdebug_is_enabled(UInt32(OSSignpostType.event.rawValue & 0xfc) | (UInt32(code) << 2) & 0x3fc | 0x14110000)
        case .os_log:
            guard kdebug_is_enabled(UInt32(OSSignpostType.event.rawValue & 0xfc) | 0x14110000) else {
                return false
            }
            return _signpostLog.signpostsEnabled
        }
        #else
        return true
        #endif
    }
    
    // TODO
    @_transparent
    package func traceInterval<T>(
        object: AnyObject?,
        _ message: StaticString?,
        closure: () -> T
    ) -> T {
        guard isEnabled else {
            return closure()
        }
        #if canImport(Darwin)
        let id = OSSignpostID.makeExclusiveID(object)
        switch style {
        case let .kdebug(code):
            kdebug_trace(UInt32(code) << 2 | (UInt32(OSSignpostType.begin.rawValue & 0xfc) | 0x14110000), id.rawValue, 0, 0, 0)
            defer { kdebug_trace(UInt32(code) << 2 | (UInt32(OSSignpostType.end.rawValue & 0xfc) | 0x14110000), id.rawValue, 0, 0, 0) }
            return closure()
        case let .os_log(name):
            if let message {
                os_signpost(.begin, log: _signpostLog, name: name, signpostID: id, message, [])
            } else {
                os_signpost(.begin, log: _signpostLog, name: name, signpostID: id)
            }
            defer { os_signpost(.end, log: _signpostLog, name: name, signpostID: id) }
            return closure()
        }
        #else
        return closure()
        #endif
    }
    
    @_transparent
    package func traceInterval<T>(
        object: AnyObject? = nil,
        _ message: StaticString,
        _ args: @autoclosure () -> [any CVarArg],
        closure: () -> T
    ) -> T {
        guard isEnabled else {
            return closure()
        }
        #if canImport(Darwin)
        let id = OSSignpostID.makeExclusiveID(object)
        switch style {
        case let .kdebug(code):
            // FIXME: _primitive
            print(code)
            return closure()
        case let .os_log(name):
            os_signpost(.begin, log: _signpostLog, name: name, signpostID: id, message, args())
            defer { os_signpost(.end, log: _signpostLog, name: name, signpostID: id) }
            return closure()
        }
        #else
        return closure()
        #endif
    }
    
    #if canImport(Darwin)
    @_transparent
    package func traceEvent(
        type: OSSignpostType,
        object: AnyObject?,
        _ message: StaticString,
        _ args: @autoclosure () -> [any CVarArg]
    ) {
        guard isEnabled else {
            return
        }
        let id = OSSignpostID.makeExclusiveID(object)
        let args = args()

        switch style {
        case let .kdebug(code):
            // FIXME: _primitive
            print(code)
            return
        case let .os_log(name):
            os_signpost(type, log: _signpostLog, name: name, signpostID: id, message, args)
        }
    }
    #endif
    
    #if canImport(Darwin)
    private func _primitive(
        _ type: OSSignpostType,
        log: OSLog,
        signpostID: OSSignpostID,
        _ message: StaticString?,
        _ arguments: [any CVarArg]?
    ) {
        // TODO
    }
    #endif
}

#if canImport(Darwin)
extension OSSignpostID {
    private static let continuation = OSSignpostID(0x0ea89ce2)
    
    @inline(__always)
    static func makeExclusiveID(_ object: AnyObject?) -> OSSignpostID {
        if let object {
            OSSignpostID(log: _signpostLog, object: object)
        } else {
            .exclusive
        }
    }
}
#endif

private func withKDebugValues(_ code: UInt32, _ args: [(any CVarArg)?], closure: (([UInt64]) -> Void)) {
    // TODO
}
