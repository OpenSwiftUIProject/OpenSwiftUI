//
//  Initialize.swift
//  OpenSwiftUIUITests
//
//  Created by Kyle on 12/29/25.
//

#if OPENSWIFTUI
@_spi(ForTestOnly)
import OpenSwiftUI
#endif

@_cdecl("OpenSwiftUIUITests_InitializeSwift")
func __initialize() -> () {
    #if OPENSWIFTUI
    Color.Resolved._alignWithSwiftUIImplementation = true
    #endif
}
