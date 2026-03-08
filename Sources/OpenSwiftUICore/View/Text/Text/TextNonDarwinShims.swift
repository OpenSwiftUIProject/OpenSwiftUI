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

package class NSTextLineFragment: NSObject {
    package init(attributedString: NSAttributedString, range: NSRange) {
        self.attributedString = attributedString
        self.range = range
    }

    private(set) package var attributedString: NSAttributedString
    private var range: NSRange
}
#endif
