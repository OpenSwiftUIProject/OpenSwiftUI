//
//  DisplayListPlatformEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

extension DisplayList {
    package enum PlatformEffect {
        case identity
        package var features: DisplayList.Features { [] }
        package func encode(to encoder: any Encoder) throws {}
        package init(from decoder: any Decoder) throws { self = .identity }
        package func print(into sexp: inout SExpPrinter) {}
    }
}
extension DisplayList.PlatformEffect: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {}
    package init(from decoder: inout ProtobufDecoder) throws { self = .identity }
}

extension DisplayList.ViewUpdater {
    package struct PlatformViewInfo {
        struct Seeds {}
    }
}
extension DisplayList.ViewUpdater.Platform {
    package typealias PlatformViewInfo = DisplayList.ViewUpdater.PlatformViewInfo
    package struct PlatformState {
    }
}
