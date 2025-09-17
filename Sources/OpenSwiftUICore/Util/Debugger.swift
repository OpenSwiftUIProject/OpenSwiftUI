//
//  Debugger.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if canImport(Darwin)
import Darwin
import os
#endif

#if canImport(Darwin)
package let isDebuggerAttached: Bool = {
    var info = kinfo_proc()
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    var size = MemoryLayout.stride(ofValue: info)

    let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)

    guard result == 0 else {
        os_log(.error, "sysctl(3) failed: %{errno}d", errno)
        return false
    }
    return (info.kp_proc.p_flag & P_TRACED) != 0
}()
#else
package let isDebuggerAttached: Bool = false
#endif
