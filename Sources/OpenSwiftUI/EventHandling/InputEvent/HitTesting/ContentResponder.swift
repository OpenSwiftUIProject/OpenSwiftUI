//
//  ContentResponder.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

import Foundation
internal import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore

protocol ContentResponder {
    func contains(points: [CGPoint], size: CGSize) -> BitVector64
    func contentPath(size: CGSize) -> Path
    func contentPath(size: CGSize, kind: ContentShapeKinds) -> Path
}

extension ContentResponder {
    func contains(points: [CGPoint], size: CGSize) -> BitVector64 {
        guard !points.isEmpty else { return BitVector64() }
        let rect = CGRect(origin: .zero, size: size)
        return points.mapBool { rect.contains($0) }
    }
    
    func contentPath(size: CGSize) -> Path {
        Path(CGRect(origin: .zero, size: size))
    }
    
    func contentPath(size: CGSize, kind: ContentShapeKinds) -> Path {
        if kind == .interaction {
            return contentPath(size: size)
        } else {
            let semantics = Semantics.v3
            let shouldReturnEmptyPath = if let forced = Semantics.forced {
                forced >= semantics
            } else {
                dyld_program_sdk_at_least(.init(semantics: semantics))
            }
            if shouldReturnEmptyPath {
                return Path()
            } else {
                return contentPath(size: size)
            }
        }
    }
}
