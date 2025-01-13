//
//  IdentifiedViewProxy.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

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
        var rect = CGRect(origin: .zero, size: size)
        rect.convert(to: .global, transform: transform.withPosition(position))
        adjustment?(&rect)
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

package protocol IdentifierProvider {
    func matchesIdentifier<I>(_ identifier: I) -> Bool where I: Hashable
}
