//
//  TextAlignmentDependentFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation

protocol TextAlignmentDependentFormatStyle: FormatStyle {
    func textAlignment(_ alignment: TextAlignment) -> Self
}
