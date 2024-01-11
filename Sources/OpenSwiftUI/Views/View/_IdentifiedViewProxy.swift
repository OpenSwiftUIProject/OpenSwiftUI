#if canImport(Darwin)
import CoreGraphics
#elseif os(Linux)
import Foundation
#endif

public struct _IdentifiedViewProxy {
    var identifier: AnyHashable
    var size: CGSize
    var position: CGPoint
    var transform: ViewTransform
    var adjustment: (inout CGRect) -> ()?
//    var accessibilityNodeStorage: AccessibilityNodeProxy?
}
