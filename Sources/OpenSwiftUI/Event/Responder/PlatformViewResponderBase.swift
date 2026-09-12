//
//  PlatformViewResponderBase.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

class PlatformViewResponderBase: ViewResponder {
    weak var hostView: PlatformView?
    var lastResult: PlatformHitTestResult?

    struct PlatformHitTestResult {
        var key: UInt32
        var globalPoint: CGPoint
        weak var hitView: PlatformView?
    }
}
