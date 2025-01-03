//
//  _IdentifiedViewProxy.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

public import Foundation

public struct _IdentifiedViewProxy {
    public var identifier: AnyHashable
    package var size: CGSize
    package var position: CGPoint
    package var transform: ViewTransform
    package var adjustment: ((inout CGRect) -> ())?
    package var accessibilityNodeStorage: Any?
    package var platform: _IdentifiedViewProxy.Platform
    
    package init(identifier: AnyHashable, size: CGSize, position: CGPoint, transform: ViewTransform, accessibilityNode: Any?, platform: _IdentifiedViewProxy.Platform) {
        self.identifier = identifier
        self.size = size
        self.position = position
        self.transform = transform
        self.accessibilityNodeStorage = accessibilityNode
        self.platform = platform
    }
        
    public var boundingRect: CGRect {        
        var transform = transform
        transform.appendTranslation(CGSize(
            width: transform.positionAdjustment.width - position.x,
            height: transform.positionAdjustment.height - position.y
        ))
        transform.positionAdjustment = CGSize(width: position.x, height: position.y)
        
        var rect: CGRect
        let originSizeRect = CGRect(origin: .zero, size: size)
        if originSizeRect.isValid {
            let points = originSizeRect.cornerPoints
            
            transform
            // TODO
            rect = .zero
        } else {
            rect = originSizeRect
        }
        
        // TODO: ViewTransform
        if let adjustment {
            adjustment(&rect)
        }
        
        return rect
    }
}

@available(*, unavailable)
extension _IdentifiedViewProxy: Sendable {}

package struct IdentifiedViewPlatformInputs {
    package init(inputs: _ViewInputs, outputs: _ViewOutputs) {}
}

extension _IdentifiedViewProxy {
  package struct Platform {
      package init(_ inputs: IdentifiedViewPlatformInputs) {}
  }
}
