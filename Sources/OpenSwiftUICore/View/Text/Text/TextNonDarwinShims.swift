//
//  TextNonDarwinShims.swift
//  OpenSwiftUICore

#if !canImport(Darwin)
package import Foundation

package class NSParagraphStyle {}
package class NSMutableParagraphStyle {}

extension NSMutableAttributedString {
    package var isEmptyOrTerminatedByParagraphSeparator: Bool {
        false
    }
}
#endif
