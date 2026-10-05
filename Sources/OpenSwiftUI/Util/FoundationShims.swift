//
//  FoundationShims.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if !canImport(Darwin)
import Foundation

extension NSKeyedUnarchiver {
    static func openswiftui_unarchiveTopLevelLNAction(with data: Data) throws -> NSObject? {
        try unarchiveTopLevelObjectWithData(data) as? NSObject
    }
}
#endif
