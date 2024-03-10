import Foundation

public struct _IdentifiedViewProxy {
    var identifier: AnyHashable
    var size: CGSize
    var position: CGPoint
    var transform: ViewTransform
    var adjustment: (inout CGRect) -> ()?
//    var accessibilityNodeStorage: AccessibilityNodeProxy?
}
