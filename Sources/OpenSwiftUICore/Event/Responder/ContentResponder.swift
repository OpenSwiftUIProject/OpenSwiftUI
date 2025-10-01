//
//  ContentResponder.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: WIP

package import Foundation
import OpenSwiftUI_SPI

package protocol ContentResponder {
    func contains(points: [PlatformPoint], size: CGSize) -> BitVector64
    func contentPath(size: CGSize) -> Path
    func contentPath(size: CGSize, kind: ContentShapeKinds) -> Path
}

extension ContentResponder {
    package func contains(points: [CGPoint], size: CGSize) -> BitVector64 {
        guard !points.isEmpty else { return BitVector64() }
        let rect = CGRect(origin: .zero, size: size)
        return points.mapBool { rect.contains($0) }
    }
    
    package func contentPath(size: CGSize) -> Path {
        Path(CGRect(origin: .zero, size: size))
    }
    
    package func contentPath(size: CGSize, kind: ContentShapeKinds) -> Path {
        if kind == .interaction {
            return contentPath(size: size)
        } else {            
            let shouldReturnEmptyPath = _SemanticFeature_v3.isEnabled
            if shouldReturnEmptyPath {
                return Path()
            } else {
                return contentPath(size: size)
            }
        }
    }
}
