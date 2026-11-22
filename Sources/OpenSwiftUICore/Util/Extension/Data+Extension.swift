//
//  Data+Extension.swift
//  OpenSwiftUICore

package import CoreFoundation
package import Foundation

/* OpenSwiftUI Addition Begin */

// MARK: - Data + CFData

extension Data {
    @inline(__always)
    package init(cfData: CFData) {
        #if canImport(Darwin)
        self = cfData as Data
        #else
        self = unsafeBitCast(cfData, to: NSData.self) as Data
        #endif
    }

    @inline(__always)
    package var cfData: CFData {
        #if canImport(Darwin)
        self as CFData
        #else
        unsafeBitCast(self as NSData, to: CFData.self)
        #endif
    }
}

/* OpenSwiftUI Addition End */
