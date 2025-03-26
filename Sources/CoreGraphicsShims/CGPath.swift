//
//  CGPath.swift
//  CoreGraphicsShims
//
//  License: MIT
//  Modified from https://github.com/PureSwift/Silica/blob/22c72ff508c40ae5e673c16ad39f39235f6ddd01/Sources/Silica/CGPath.swift

#if !canImport(CoreGraphics)

public import Foundation

/// A graphics path is a mathematical description of a series of shapes or lines.
public struct CGPath {

    public typealias Element = PathElement

    public var elements: [Element]

    public init(elements: [Element] = []) {

        self.elements = elements
    }
}

// MARK: - Supporting Types

/// A path element.
public enum PathElement {

    /// The path element that starts a new subpath. The element holds a single point for the destination.
    case moveToPoint(CGPoint)

    /// The path element that adds a line from the current point to a new point.
    /// The element holds a single point for the destination.
    case addLineToPoint(CGPoint)

    /// The path element that adds a quadratic curve from the current point to the specified point.
    /// The element holds a control point and a destination point.
    case addQuadCurveToPoint(CGPoint, CGPoint)

    /// The path element that adds a cubic curve from the current point to the specified point.
    /// The element holds two control points and a destination point.
    case addCurveToPoint(CGPoint, CGPoint, CGPoint)

    /// The path element that closes and completes a subpath. The element does not contain any points.
    case closeSubpath
}

// MARK: - Constructing a Path

public extension CGPath {

    mutating func addRect(_ rect: CGRect) {

        let newElements: [Element] = [.moveToPoint(CGPoint(x: rect.minX, y: rect.minY)),
                                      .addLineToPoint(CGPoint(x: rect.maxX, y: rect.minY)),
                                      .addLineToPoint(CGPoint(x: rect.maxX, y: rect.maxY)),
                                      .addLineToPoint(CGPoint(x: rect.minX, y: rect.maxY)),
                                      .closeSubpath]

        elements.append(contentsOf: newElements)
    }

    mutating func addEllipse(in rect: CGRect) {

        var p = CGPoint()
        var p1 = CGPoint()
        var p2 = CGPoint()

        let hdiff = rect.width / 2 * KAPPA
        let vdiff = rect.height / 2 * KAPPA

        p = CGPoint(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height)
        elements.append(.moveToPoint(p))

        p = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height / 2)
        p1 = CGPoint(x: rect.origin.x + rect.width / 2 - hdiff, y: rect.origin.y + rect.height)
        p2 = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height / 2 + vdiff)
        elements.append(.addCurveToPoint(p1, p2, p))

        p = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y)
        p1 = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height / 2 - vdiff)
        p2 = CGPoint(x: rect.origin.x + rect.size.width / 2 - hdiff, y: rect.origin.y)
        elements.append(.addCurveToPoint(p1, p2, p))

        p = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height / 2)
        p1 = CGPoint(x: rect.origin.x + rect.size.width / 2 + hdiff, y: rect.origin.y)
        p2 = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height / 2 - vdiff)
        elements.append(.addCurveToPoint(p1, p2, p))

        p = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height)
        p1 = CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height / 2 + vdiff)
        p2 = CGPoint(x: rect.origin.x + rect.size.width / 2 + hdiff, y: rect.origin.y + rect.size.height)
        elements.append(.addCurveToPoint(p1, p2, p))
    }

    mutating func move(to point: CGPoint) {

        elements.append(.moveToPoint(point))
    }

    mutating func addLine(to point: CGPoint) {

        elements.append(.addLineToPoint(point))
    }

    mutating func addCurve(to endPoint: CGPoint, control1: CGPoint, control2: CGPoint) {

        elements.append(.addCurveToPoint(control1, control2, endPoint))
    }

    mutating func addQuadCurve(to endPoint: CGPoint, control: CGPoint) {

        elements.append(.addQuadCurveToPoint(control, endPoint))
    }

    mutating func closeSubpath() {

        elements.append(.closeSubpath)
    }
}

// This magic number is 4 *(sqrt(2) -1)/3
private let KAPPA: CGFloat = 0.5522847498

// MARK: - CoreGraphics API

public struct CGPathElement {

    public var type: CGPathElementType

    public var points: (CGPoint, CGPoint, CGPoint)

    public init(type: CGPathElementType, points: (CGPoint, CGPoint, CGPoint)) {

        self.type = type
        self.points = points
    }
}

/// Rules for determining which regions are interior to a path.
///
/// When filling a path, regions that a fill rule defines as interior to the path are painted.
/// When clipping with a path, regions interior to the path remain visible after clipping.
public enum CGPathFillRule: Int {

    /// A rule that considers a region to be interior to a path based on the number of times it is enclosed by path elements.
    case evenOdd

    /// A rule that considers a region to be interior to a path if the winding number for that region is nonzero.
    case winding
}

/// The type of element found in a path.
public enum CGPathElementType {

    /// The path element that starts a new subpath. The element holds a single point for the destination.
    case moveToPoint

    /// The path element that adds a line from the current point to a new point.
    /// The element holds a single point for the destination.
    case addLineToPoint

    /// The path element that adds a quadratic curve from the current point to the specified point.
    /// The element holds a control point and a destination point.
    case addQuadCurveToPoint

    /// The path element that adds a cubic curve from the current point to the specified point.
    /// The element holds two control points and a destination point.
    case addCurveToPoint

    /// The path element that closes and completes a subpath. The element does not contain any points.
    case closeSubpath
}

// MARK: - Silica Conversion

public extension CGPathElement {

    init(_ element: PathElement) {

        switch element {

        case let .moveToPoint(point):

            self.type = .moveToPoint
            self.points = (point, CGPoint(), CGPoint())

        case let .addLineToPoint(point):

            self.type = .addLineToPoint
            self.points = (point, CGPoint(), CGPoint())

        case let .addQuadCurveToPoint(control, destination):

            self.type = .addQuadCurveToPoint
            self.points = (control, destination, CGPoint())

        case let .addCurveToPoint(control1, control2, destination):

            self.type = .addCurveToPoint
            self.points = (control1, control2, destination)

        case .closeSubpath:

            self.type = .closeSubpath
            self.points = (CGPoint(), CGPoint(), CGPoint())
        }
    }
}

public extension PathElement {

    init(_ element: CGPathElement) {

        switch element.type {

        case .moveToPoint: self = .moveToPoint(element.points.0)

        case .addLineToPoint: self = .addLineToPoint(element.points.0)

        case .addQuadCurveToPoint: self = .addQuadCurveToPoint(element.points.0, element.points.1)

        case .addCurveToPoint: self = .addCurveToPoint(element.points.0, element.points.1, element.points.2)

        case .closeSubpath: self = .closeSubpath
        }
    }
}
#endif
