//
//  StdoutApp.swift
//  OpenSwiftUI

#if !OPENSWIFTUI_SWIFTUI_RENDERER
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif os(WASI)
import WASILibc
#endif
import Foundation
@_spi(StdoutRenderer)
import OpenSwiftUICore

// MARK: - runStdoutApp

func runStdoutApp(
    _ app: some App,
    options: _RendererConfiguration.StdoutOptions
) -> Never {
    renderHeadlessApp(
        app,
        surface: options.surface,
        configuration: .stdout(options)
    )
    exit(0)
}
#endif
