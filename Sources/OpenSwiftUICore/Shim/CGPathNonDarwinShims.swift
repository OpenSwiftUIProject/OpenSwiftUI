//
//  CGPathNonDarwinShims.swift
//  OpenSwiftUICore

#if !canImport(Darwin)
package import Foundation
package import OpenCoreGraphicsShims
import OpenRenderBoxShims

package func _CGPathCreateRoundedRect(
    _ rect: CGRect,
    _ cornerWidth: CGFloat,
    _ cornerHeight: CGFloat,
    _ continuous: Bool
) -> CGPath {
    var cornerWidth = max(cornerWidth, 0.0)
    var cornerHeight = max(cornerHeight, 0.0)
    if cornerWidth == 0.0 || cornerHeight == 0.0 || rect.isEmpty {
        return CGPath(rect: rect, transform: nil)
    }
    if continuous {
        let rbPath = ORBPath(
            roundedRect: rect,
            cornerWidth: cornerWidth,
            cornerHeight: cornerHeight,
            style: .continuous,
            transform: nil
        )
        defer { rbPath.release() }
        return rbPath.cgPath
    }
    let width = rect.width
    let height = rect.height
    if cornerWidth * 2.0 > width {
        cornerWidth = (width * 0.5).nextDown
    }
    if cornerHeight * 2.0 > height {
        cornerHeight = (height * 0.5).nextDown
    }
    if cornerWidth < 0.0 || cornerWidth * 2.0 > width || cornerHeight < 0.0 || cornerHeight * 2.0 > height {
        return CGPath(rect: rect, transform: nil)
    }
    return CGPath(
        roundedRect: rect,
        cornerWidth: cornerWidth,
        cornerHeight: cornerHeight,
        transform: nil
    )
}
#endif
