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
import Foundation

package let isDebuggerAttached: Bool = {
    guard let statusData = try? Data(contentsOf: URL(fileURLWithPath: "/proc/self/status")),
          let statusString = String(data: statusData, encoding: .utf8) else {
        return false
    }

    for line in statusString.components(separatedBy: .newlines) {
        if line.hasPrefix("TracerPid:") {
            let components = line.components(separatedBy: .whitespaces)
            if components.count >= 2,
               let tracerPid = Int(components[1]),
               tracerPid != 0 {
                return true
            }
            break
        }
    }

    return false
}()
#endif
