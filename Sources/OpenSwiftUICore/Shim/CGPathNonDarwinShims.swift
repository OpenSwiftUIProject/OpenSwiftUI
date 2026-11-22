//
//  CGPathNonDarwinShims.swift
//  OpenSwiftUICore

#if !canImport(Darwin)
package import CoreFoundation
package import Foundation
package import OpenCoreGraphicsShims
import OpenRenderBoxShims
#if canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif os(WASI)
import WASILibc
#elseif os(Windows)
import ucrt
#endif

package func _CGPathParseString(
    _ path: CGMutablePath,
    _ utf8CString: UnsafePointer<CChar>
) -> Bool {
    var ptr = utf8CString
    var numbers = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    return withUnsafeMutablePointer(to: &numbers) { tuplePtr in
        tuplePtr.withMemoryRebound(to: Double.self, capacity: 6) { nums in
            var numCount = 0
            var currentX: CGFloat = 0.0
            var currentY: CGFloat = 0.0
            var lastControlX: CGFloat = 0.0
            var lastControlY: CGFloat = 0.0
            while true {
                var c = UInt8(bitPattern: ptr.pointee)
                while c <= 0x1f {
                    switch c {
                    case 0:
                        return true
                    case 9, 10, 12, 13:
                        ptr = ptr.advanced(by: 1)
                        c = UInt8(bitPattern: ptr.pointee)
                    default:
                        return false
                    }
                }
                var isNumberStart = false
                switch c {
                case UInt8(ascii: " "):
                    break
                case UInt8(ascii: "+"),
                     UInt8(ascii: "-"),
                     UInt8(ascii: "."),
                     UInt8(ascii: "0") ... UInt8(ascii: "9"),
                     UInt8(ascii: "E"),
                     UInt8(ascii: "P"),
                     UInt8(ascii: "X"),
                     UInt8(ascii: "e"),
                     UInt8(ascii: "p"),
                     UInt8(ascii: "x"):
                    isNumberStart = true
                case UInt8(ascii: "I"):
                    if UInt8(bitPattern: ptr[1]) == UInt8(ascii: "n"),
                       UInt8(bitPattern: ptr[2]) == UInt8(ascii: "f") {
                        isNumberStart = true
                    }
                case UInt8(ascii: "m"):
                    guard numCount == 2 else { return false }
                    let x = CGFloat(nums[0]), y = CGFloat(nums[1])
                    path.move(to: CGPoint(x: x, y: y))
                    currentX = x; lastControlX = x
                    currentY = y; lastControlY = y
                    numCount = 0
                case UInt8(ascii: "l"):
                    guard numCount == 2 else { return false }
                    let x = CGFloat(nums[0]), y = CGFloat(nums[1])
                    path.addLine(to: CGPoint(x: x, y: y))
                    currentX = x; lastControlX = x
                    currentY = y; lastControlY = y
                    numCount = 0
                case UInt8(ascii: "c"):
                    guard numCount == 6 else { return false }
                    let cp1x = CGFloat(nums[0]), cp1y = CGFloat(nums[1])
                    let cp2x = CGFloat(nums[2]), cp2y = CGFloat(nums[3])
                    let x = CGFloat(nums[4]), y = CGFloat(nums[5])
                    path.addCurve(
                        to: CGPoint(x: x, y: y),
                        control1: CGPoint(x: cp1x, y: cp1y),
                        control2: CGPoint(x: cp2x, y: cp2y)
                    )
                    lastControlX = cp2x
                    lastControlY = cp2y
                    currentX = x
                    currentY = y
                    numCount = 0
                case UInt8(ascii: "q"):
                    guard numCount == 4 else { return false }
                    let cpx = CGFloat(nums[0]), cpy = CGFloat(nums[1])
                    let x = CGFloat(nums[2]), y = CGFloat(nums[3])
                    path.addQuadCurve(
                        to: CGPoint(x: x, y: y),
                        control: CGPoint(x: cpx, y: cpy)
                    )
                    lastControlX = cpx
                    lastControlY = cpy
                    currentX = x
                    currentY = y
                    numCount = 0
                case UInt8(ascii: "t"):
                    guard numCount == 2 else { return false }
                    let reflectedX = currentX * 2.0 - lastControlX
                    let reflectedY = currentY * 2.0 - lastControlY
                    let x = CGFloat(nums[0]), y = CGFloat(nums[1])
                    path.addQuadCurve(
                        to: CGPoint(x: x, y: y),
                        control: CGPoint(x: reflectedX, y: reflectedY)
                    )
                    lastControlX = reflectedX
                    lastControlY = reflectedY
                    currentX = x
                    currentY = y
                    numCount = 0
                case UInt8(ascii: "v"):
                    guard numCount == 4 else { return false }
                    let cp2x = CGFloat(nums[0]), cp2y = CGFloat(nums[1])
                    let x = CGFloat(nums[2]), y = CGFloat(nums[3])
                    path.addCurve(
                        to: CGPoint(x: x, y: y),
                        control1: CGPoint(x: currentX, y: currentY),
                        control2: CGPoint(x: cp2x, y: cp2y)
                    )
                    lastControlX = cp2x
                    lastControlY = cp2y
                    currentX = x
                    currentY = y
                    numCount = 0
                case UInt8(ascii: "y"):
                    guard numCount == 4 else { return false }
                    let cp1x = CGFloat(nums[0]), cp1y = CGFloat(nums[1])
                    let x = CGFloat(nums[2]), y = CGFloat(nums[3])
                    let end = CGPoint(x: x, y: y)
                    path.addCurve(
                        to: end,
                        control1: CGPoint(x: cp1x, y: cp1y),
                        control2: end
                    )
                    currentX = x
                    currentY = y
                    numCount = 0
                case UInt8(ascii: "h"):
                    guard numCount == 0 else { return false }
                    path.closeSubpath()
                    currentX = 0.0
                    currentY = 0.0
                case UInt8(ascii: "r"):
                    guard UInt8(bitPattern: ptr[1]) == UInt8(ascii: "e"),
                          numCount == 4 else {
                        return false
                    }
                    let x = CGFloat(nums[0]), y = CGFloat(nums[1])
                    let w = CGFloat(nums[2]), h = CGFloat(nums[3])
                    path.addRect(CGRect(x: x, y: y, width: w, height: h))
                    currentX = w
                    currentY = h
                    ptr = ptr.advanced(by: 1)
                    numCount = 0
                default:
                    return false
                }
                if isNumberStart {
                    guard numCount < 6 else { return false }
                    var endPtr: UnsafeMutablePointer<CChar>?
                    nums[numCount] = strtod(ptr, &endPtr)
                    numCount += 1
                    if let endPtr {
                        ptr = UnsafePointer(endPtr)
                    }
                } else {
                    ptr = ptr.advanced(by: 1)
                }
            }
        }
    }
}

package func _CGPathCopyDescription(_ path: CGPath, _ step: CGFloat) -> CFString {
    var description = ""
    let inverseStep = 1.0 / step
    path.applyWithBlock { elementPtr in
        let element = elementPtr.pointee
        let command: Character
        let pointCount: Int
        switch element.type {
        case .moveToPoint:
            command = "m"
            pointCount = 1
        case .addLineToPoint:
            command = "l"
            pointCount = 1
        case .addQuadCurveToPoint:
            command = "q"
            pointCount = 2
        case .addCurveToPoint:
            command = "c"
            pointCount = 3
        case .closeSubpath:
            command = "h"
            pointCount = 0
        @unknown default:
            return
        }
        if !description.isEmpty {
            description.append(" ")
        }
        for i in 0..<pointCount {
            let point = element.points[i]
            for raw in [point.x, point.y] {
                var value = raw
                if step != 0.0 {
                    value = step * (value * inverseStep).rounded(.toNearestOrAwayFromZero)
                }
                description.append(String(format: "%g ", locale: nil, Double(value)))
            }
        }
        description.append(command)
    }
    return description.cfString
}

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
