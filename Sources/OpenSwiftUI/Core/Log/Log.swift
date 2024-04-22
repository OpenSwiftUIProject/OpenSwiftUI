//
//  Log.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#if OPENSWIFTUI_SWIFT_LOG
import Logging
#else
import os
#if DEBUG
public let dso = { () -> UnsafeMutableRawPointer in
    let count = _dyld_image_count()
    for i in 0 ..< count {
        if let name = _dyld_get_image_name(i) {
            let swiftString = String(cString: name)
            if swiftString.hasSuffix("/SwiftUI") {
                if let header = _dyld_get_image_header(i) {
                    return UnsafeMutableRawPointer(mutating: UnsafeRawPointer(header))
                }
            }
        }
    }
    return UnsafeMutableRawPointer(mutating: #dsohandle)
}()
#endif
#endif

@usableFromInline
enum Log {
    static func internalWarning(
        _ message: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        print("\(message()) at \(file):\(line)")
    }

    #if OPENSWIFTUI_SWIFT_LOG
    @usableFromInline
    static let runtimeIssuesLog = Logger(label: "OpenSwiftUI")
    
    @_transparent
    static func runtimeIssues(
        _ message: @autoclosure () -> StaticString,
        _ args: @autoclosure () -> [CVarArg] = []
    ) {
        runtimeIssuesLog.log(level: .critical, "\(message())")
    }
    #else
    
    // Audited for RELEASE_2023
    @usableFromInline
    static var runtimeIssuesLog = OSLog(subsystem: "com.apple.runtime-issues", category: "OpenSwiftUI")
    
    @_transparent
    static func runtimeIssues(
        _ message: @autoclosure () -> StaticString,
        _ args: @autoclosure () -> [CVarArg] = []
    ) {
        #if DEBUG
        unsafeBitCast(
            os_log as (OSLogType, UnsafeRawPointer, OSLog, StaticString, CVarArg...) -> Void,
            to: ((OSLogType, UnsafeRawPointer, OSLog, StaticString, [CVarArg]) -> Void).self
        )(.fault, dso, runtimeIssuesLog, message(), args())
        #else
        os_log(.fault, log: runtimeIssuesLog, message(), args())
        #endif
    }
    #endif
}
