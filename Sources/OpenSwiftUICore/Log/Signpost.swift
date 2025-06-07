//
//  Signpost.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 34756F646CF7AC3DBE2A8E0B344C962F (SwiftUI)
//  ID: 59349949219F590F26B6A55CEC9D59A2 (SwiftUICore)

import OpenSwiftUI_SPI
import OpenGraphShims
#if canImport(os)
package import os.signpost
#endif

extension Signpost {
    package static let render = Signpost.kdebug(0, "Render").published
    package static let postUpdateActions = Signpost.kdebug(2, "PostUpdateActions").published
    package static let renderUpdate = Signpost.kdebug(3, "RenderUpdate").published
    package static let renderFlattened = Signpost.kdebug(4, "RenderFlattened").published
    package static let bodyInvoke = Signpost.kdebug(5, "BodyInvoke").published
    package static let linkCreate = Signpost.os_log(6, "LinkCreate").published
    package static let linkUpdate = Signpost.os_log(7, "LinkUpdate").published
    package static let linkDestroy = Signpost.os_log(8, "LinkDestroy").published
    package static let viewHost = Signpost.kdebug(9, "ViewHost").published
    package static let platformView = Signpost.os_log(10, "ViewMapping").published
    package static let platformUpdate = Signpost.os_log(11, "PlatformViewUpdate").published
    package static let animationState = Signpost.os_log(12, "AnimationState").published
    package static let eventHandling = Signpost.os_log(13, "EventHandling").published
}

#if canImport(Darwin)
private let _signpostLog = OSLog(subsystem: Log.subsystem, category: "OpenSwiftUI")
#endif

package struct Signpost {
    #if canImport(Darwin) && !OPENSWIFTUI_SWIFT_LOG
    package static let archiving = OSSignposter(logger: Log.archiving)
    package static let metaExtraction = OSSignposter(logger: Log.metadataExtraction)
    #endif
    
    package static let moduleName: String = Tracing.libraryName(defining: Signpost.self)
    
    @inlinable
    package static func os_log(_ code: UInt8, _ name: StaticString) -> Signpost {
        #if OPENSWIFTUI_SIGNPOST_KDEBUG
        Signpost(style: .kdebug(code), stability: .debug)
        #else
        Signpost(style: .os_log(name), stability: .debug)
        #endif
    }
    
    @inlinable
    package static func kdebug(_ code: UInt8, _ name: StaticString?) -> Signpost {
        #if OPENSWIFTUI_SIGNPOST_OS_LOG
        Signpost(style: .os_log(name), stability: .debug)
        #else
        Signpost(style: .kdebug(code), stability: .debug)
        #endif
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
        guard Stability.valid.contains(stability) else {
            return false
        }
        #if canImport(Darwin)
        switch style {
            case let .kdebug(code):
                return kdebug_is_enabled(MISC_INSTRUMENTS_DGB_EVENT_CODE(code: code))
            case .os_log:
                guard kdebug_is_enabled(MISC_INSTRUMENTS_DGB_EVENT_CODE()) else {
                    return false
                }
                return _signpostLog.signpostsEnabled
            }
        #else
        return false
        #endif
    }
    
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
                kdebug_trace(MISC_INSTRUMENTS_DGB_CODE(type: .begin, code: code), id.rawValue, 0, 0, 0)
                defer { kdebug_trace(MISC_INSTRUMENTS_DGB_CODE(type: .end, code: code), id.rawValue, 0, 0, 0) }
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
        object: AnyObject?,
        _ message: StaticString,
        _ args: @autoclosure () -> [any CVarArg],
        closure: () -> T
    ) -> T {
        guard isEnabled else {
            return closure()
        }
        #if canImport(Darwin)
        let id = OSSignpostID.makeExclusiveID(object)
        let args = args()
        switch style {
            case let .kdebug(code):
                 _primitive(.begin, log: _signpostLog, signpostID: id, message, args)
                defer { kdebug_trace(MISC_INSTRUMENTS_DGB_CODE(type: .end, code: code), id.rawValue, 0, 0, 0) }
                return closure()
            case let .os_log(name):
                os_signpost(.begin, log: _signpostLog, name: name, signpostID: id, message, args)
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
            case .kdebug:
                _primitive(type, log: _signpostLog, signpostID: id, message, args)
            case let .os_log(name):
                os_signpost(type, log: _signpostLog, name: name, signpostID: id, message, args)
        }
    }
    #endif
    
    
    #if canImport(Darwin)
    
    @inline(__always)
    private var styleCode: UInt8 {
        switch style {
            case let .kdebug(code): code
            case .os_log: 0
        }
    }
    
    private func _primitive(
        _ type: OSSignpostType,
        log: OSLog,
        signpostID: OSSignpostID,
        _ message: StaticString?,
        _ arguments: [any CVarArg]?
    ) {
        let code = MISC_INSTRUMENTS_DGB_CODE(type: type, code: styleCode)
        var id = signpostID
        var iterator = (arguments ?? []).makeIterator()
        repeat {
            let arg0 = iterator.next()
            let arg1 = iterator.next()
            let arg2 = iterator.next()
            withKDebugValues(code, [arg0, arg1, arg2]) { args in
                kdebug_trace(code, id.rawValue, args[0], args[1], args[2])
            }
            guard arg2 != nil else {
                break
            }
            id = OSSignpostID.continuation
        } while true
    }
    #endif
}

#if canImport(os)
extension OSSignpostID {
    fileprivate static let continuation = OSSignpostID(0x0ea89ce2)
    
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

#if canImport(Darwin)

// MARK: - kdebug

private func withKDebugValues(_ code: UInt32, _ args: [(any CVarArg)?], closure: (([UInt64]) -> Void)) {
    let values = args.map { $0?.kdebugValue(code) }
    closure(values.map { $0?.arg ?? 0 })
    values.forEach { $0?.destructor?() }
}

private protocol KDebuggableCVarArg: CVarArg {
    var kdebugableCVarArgValue: String { get }
}

extension String: KDebuggableCVarArg {
    var kdebugableCVarArgValue: String { self }
}

extension CVarArg {
    fileprivate func kdebugValue(_ code: UInt32) -> (arg: UInt64, destructor: (() -> Void)?) {
        if let kdebuggableCVarArg = self as? KDebuggableCVarArg {
            let description = kdebuggableCVarArg.kdebugableCVarArgValue
            if description == Signpost.moduleName {
                return (0, nil)
            } else {
                return description.withCString { pointer in
                    let stringID = kdebug_trace_string(code & KDBG_CSC_MASK, 0, pointer)
                    return (stringID, {
                        kdebug_trace_string((code << 0x8) & KDBG_CSC_MASK, stringID, nil)
                    })
                }
            }
        } else {
            let encoding = _cVarArgEncoding
            if encoding.count == 1 {
                return (UInt64(bitPattern: Int64(encoding[0])), nil)
            } else {
                let description = String(describing: self)
                if description == Signpost.moduleName {
                    return (0, nil)
                } else {
                    return description.withCString { pointer in
                        let stringID = kdebug_trace_string(code & KDBG_CSC_MASK, 0, pointer)
                        return (stringID, {
                            kdebug_trace_string((code << 0x8) & KDBG_CSC_MASK, stringID, nil)
                        })
                    }
                }
            }
        }
    }
}

// MARK: - kdebug macro helper

@_transparent
func KDBG_EVENTID(_ class: UInt32, _ subclass: UInt32, _ code: UInt32) -> UInt32 {
    ((`class` & UInt32(KDBG_CLASS_MAX)) << KDBG_CLASS_OFFSET) |
    ((subclass & UInt32(KDBG_SUBCLASS_MAX)) << KDBG_SUBCLASS_OFFSET) |
    ((code & UInt32(KDBG_CODE_MAX)) << KDBG_CODE_OFFSET)
}

@_transparent
func KDBG_DEBUGID(_ class: UInt32, _ subclass: UInt32, _ code: UInt32, _ function: UInt32) -> UInt32 {
    KDBG_EVENTID(`class`, subclass, code) | (function & UInt32(KDBG_FUNC_MASK))
}

@_transparent
func KDBG_EXTRACT_CLASS(_ debugid: UInt32) -> UInt32 {
    (debugid & KDBG_CLASS_MASK) >> KDBG_CLASS_OFFSET
}

@_transparent
func KDBG_EXTRACT_SUBCLASS(_ debugid: UInt32) -> UInt32 {
    (debugid & UInt32(bitPattern: KDBG_SUBCLASS_MASK)) >> KDBG_SUBCLASS_OFFSET
}

@_transparent
func KDBG_EXTRACT_CODE(_ debugid: UInt32) -> UInt32 {
    (debugid & UInt32(bitPattern: KDBG_CODE_MASK)) >> KDBG_CODE_OFFSET
}

@_transparent
func KDBG_CLASS_ENCODE(_ class: UInt32, _ subclass: UInt32) -> UInt32 {
    KDBG_EVENTID(`class`, subclass, 0)
}

@_transparent
func KDBG_CLASS_DECODE(_ debugid: UInt32) -> UInt32 {
    debugid & KDBG_CSC_MASK
}

@_transparent
func MISC_INSTRUMENTS_DGB_EVENT_CODE(code: UInt8 = 0) -> UInt32 {
    KDBG_EVENTID(UInt32(bitPattern: DBG_MISC), UInt32(bitPattern: DBG_MISC_INSTRUMENTS), UInt32(OSSignpostType.event.rawValue >> 2 | code))
}

@_transparent
func MISC_INSTRUMENTS_DGB_CODE(type: OSSignpostType, code: UInt8 = 0) -> UInt32 {
    KDBG_DEBUGID(UInt32(bitPattern: DBG_MISC), UInt32(bitPattern: DBG_MISC_INSTRUMENTS), UInt32(type.rawValue >> 2 | code), UInt32(type.rawValue))
}

#endif
