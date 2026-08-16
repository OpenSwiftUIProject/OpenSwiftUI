//
//  StyledFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

package protocol StyledFormatStyle: FormatStyle where FormatOutput == AttributedString {
    mutating func makePlatformAttributes(resolver: inout PlatformAttributeResolver)
}
