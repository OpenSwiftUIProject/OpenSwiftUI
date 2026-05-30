//
//  Text+DiscreteFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Empty
//  ID: C8A98712CE9284278805F6E671356D1B (SwiftUICore)

package import Foundation

package protocol AttributedStringConvertible {
    var attributedString: AttributedString { get }
}

extension AttributedString: AttributedStringConvertible {
    package var attributedString: AttributedString {
        self
    }
}

extension String: AttributedStringConvertible {
    package var attributedString: AttributedString {
        AttributedString(self)
    }
}
