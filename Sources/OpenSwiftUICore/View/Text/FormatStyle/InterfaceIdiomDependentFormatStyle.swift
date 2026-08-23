//
//  InterfaceIdiomDependentFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation

protocol InterfaceIdiomDependentFormatStyle: FormatStyle {
    func interfaceIdiom(_ idiom: AnyInterfaceIdiom) -> Self
}
