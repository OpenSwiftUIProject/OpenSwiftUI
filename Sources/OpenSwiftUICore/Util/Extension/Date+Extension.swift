//
//  Date+Extension.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import Foundation

// MARK: - Date + Extension [6.5.4]

extension Date {
   package var nextUp: Date {
       Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate.nextUp)
   }

   package var nextDown: Date {
       Date(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate.nextDown)
   }
}
