//
//  Path.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: WIP
//  ID: 31FD92B70C320DDD253E93C7417D779A (SwiftUI)
//  ID: 3591905F51357E95FA93E39751507471 (SwiftUICore)

public import Foundation
package import OpenRenderBoxShims
import OpenSwiftUI_SPI
public import OpenCoreGraphicsShims

// MARK: - Path

/// The outline of a 2D shape.
@frozen
public struct Path: Equatable, LosslessStringConvertible, @unchecked Sendable {
    @usableFromInline
    final package class PathBox: Equatable {

        private enum Kind: UInt8 {
            case cgPath
            case obPath
            case buffer
        }

        private var kind: Kind

        #if canImport(CoreGraphics)
        private var data: PathData

        @inline(__always)
        init(_ path: CGPath) {
            kind = .cgPath
            //data = PathData(path)
            _openSwiftUIUnimplementedFailure()
        }
        #endif

        package init(takingPath path: ORBPath) {
            kind = .obPath
            //data = PathData(path)
            _openSwiftUIUnimplementedFailure()
        }

        #if canImport(CoreGraphics)
        private func prepareBuffer() {
            let obPath: ORBPath
            switch kind {
            case .cgPath:
                // data.cgPath
                // let rbPath = ORBPathMakeWithCGPath
                _openSwiftUIUnimplementedFailure()
            case .obPath:
                obPath = data.obPath.assumingMemoryBound(to: ORBPath.self).pointee
            case .buffer:
                return
            }
            // ORBPath.Storage.init
            // storage.appendPath
            obPath.release()
        }
        #endif

        @usableFromInline
        package static func == (lhs: PathBox, rhs: PathBox) -> Bool {
            _openSwiftUIUnimplementedFailure()
        }
    }

    @usableFromInline
    @frozen
    package enum Storage: Equatable {
        case empty
        case rect(CGRect)
        case ellipse(CGRect)
        indirect case roundedRect(FixedRoundedRect)
        @available(*, deprecated, message: "obsolete")
        indirect case stroked(StrokedPath)
        @available(*, deprecated, message: "obsolete")
        indirect case trimmed(TrimmedPath)
        case path(PathBox)
    }

    package var storage: Path.Storage

    package init(storage: Path.Storage) {
        self.storage = storage
    }

    package init(box: Path.PathBox) {
        self.storage = .path(box)
    }

    /// Creates an empty path.
    public init() {
        storage = .empty
    }
    
    #if canImport(CoreGraphics)

    /// Creates a path from an immutable shape path.
    ///
    /// - Parameter path: The immutable CoreGraphics path to initialize
    ///   the new path from.
    ///
    public init(_ path: CGPath) {
        guard !path.isEmpty else {
            storage = .empty
            return
        }
        storage = .path(PathBox(path))
    }
    
    /// Creates a path from a copy of a mutable shape path.
    ///
    /// - Parameter path: The CoreGraphics path to initialize the new
    ///   path from.
    ///
    public init(_ path: CGMutablePath) {
        guard !path.isEmpty else {
            storage = .empty
            return
        }
        storage = .path(PathBox(path.mutableCopy()!))
        _openSwiftUIUnimplementedFailure()
    }
    #endif
    
    /// Creates a path containing a rectangle.
    ///
    /// This is a convenience function that creates a path of a
    /// rectangle. Using this convenience function is more efficient
    /// than creating a path and adding a rectangle to it.
    ///
    /// Calling this function is equivalent to using `minX` and related
    /// properties to find the corners of the rectangle, then using the
    /// `move(to:)`, `addLine(to:)`, and `closeSubpath()` functions to
    /// add the rectangle.
    ///
    /// - Parameter rect: The rectangle to add.
    ///
    public init(_ rect: CGRect) {
        guard !rect.isNull else {
            storage = .empty
            return
        }
        storage = .rect(rect)
    }
    
    /// Creates a path containing a rounded rectangle.
    ///
    /// This is a convenience function that creates a path of a rounded
    /// rectangle. Using this convenience function is more efficient
    /// than creating a path and adding a rounded rectangle to it.
    ///
    /// - Parameters:
    ///   - rect: A rectangle, specified in user space coordinates.
    ///   - cornerSize: The size of the corners, specified in user space
    ///     coordinates.
    ///   - style: The corner style. Defaults to the `continous` style
    ///     if not specified.
    ///
    public init(roundedRect rect: CGRect, cornerSize: CGSize, style: RoundedCornerStyle = .continuous) {
        guard !rect.isNull else {
            storage = .empty
            return
        }
        guard cornerSize != .zero && !rect.isInfinite else {
            storage = .rect(rect)
            return
        }
        storage = .roundedRect(FixedRoundedRect(rect, cornerSize: cornerSize, style: style))
    }

    /// Creates a path containing a rounded rectangle.
    ///
    /// This is a convenience function that creates a path of a rounded
    /// rectangle. Using this convenience function is more efficient
    /// than creating a path and adding a rounded rectangle to it.
    ///
    /// - Parameters:
    ///   - rect: A rectangle, specified in user space coordinates.
    ///   - cornerRadius: The radius of all corners of the rectangle,
    ///     specified in user space coordinates.
    ///   - style: The corner style. Defaults to the `continous` style
    ///     if not specified.
    ///
    public init(roundedRect rect: CGRect, cornerRadius: CGFloat, style: RoundedCornerStyle = .continuous) {
        guard !rect.isNull else {
            storage = .empty
            return
        }
        guard cornerRadius != .zero && !rect.isInfinite else {
            storage = .rect(rect)
            return
        }
        storage = .roundedRect(FixedRoundedRect(rect, cornerRadius: cornerRadius, style: style))
    }

    /// Creates a path as the given rounded rectangle, which may have
    /// uneven corner radii.
    ///
    /// This is a convenience function that creates a path of a rounded
    /// rectangle. Using this function is more efficient than creating
    /// a path and adding a rounded rectangle to it.
    ///
    /// - Parameters:
    ///   - rect: A rectangle, specified in user space coordinates.
    ///   - cornerRadii: The radius of each corner of the rectangle,
    ///     specified in user space coordinates.
    ///   - style: The corner style. Defaults to the `continous` style
    ///     if not specified.
    ///
    public init(roundedRect rect: CGRect, cornerRadii: RectangleCornerRadii, style: RoundedCornerStyle = .continuous) {
        guard !rect.isNull else {
            storage = .empty
            return
        }
        _openSwiftUIUnimplementedFailure()
    }

    /// Creates a path as an ellipse within the given rectangle.
    ///
    /// This is a convenience function that creates a path of an
    /// ellipse. Using this convenience function is more efficient than
    /// creating a path and adding an ellipse to it.
    ///
    /// The ellipse is approximated by a sequence of Bézier
    /// curves. Its center is the midpoint of the rectangle defined by
    /// the rect parameter. If the rectangle is square, then the
    /// ellipse is circular with a radius equal to one-half the width
    /// (or height) of the rectangle. If the rect parameter specifies a
    /// rectangular shape, then the major and minor axes of the ellipse
    /// are defined by the width and height of the rectangle.
    ///
    /// The ellipse forms a complete subpath of the path—that
    /// is, the ellipse drawing starts with a move-to operation and
    /// ends with a close-subpath operation, with all moves oriented in
    /// the clockwise direction. If you supply an affine transform,
    /// then the constructed Bézier curves that define the
    /// ellipse are transformed before they are added to the path.
    ///
    /// - Parameter rect: The rectangle that bounds the ellipse.
    ///
    public init(ellipseIn rect: CGRect) {
        guard !rect.isNull else {
            storage = .empty
            return
        }
        storage = rect.isInfinite ? .rect(rect) : .ellipse(rect)
    }
    
    /// Creates an empty path, then executes a closure to add its
    /// initial elements.
    ///
    /// - Parameter callback: The Swift function that will be called to
    ///   initialize the new path.
    ///
    public init(_ callback: (inout Path) -> ()) {
        storage = .empty
        callback(&self)
    }
    

    /// Initializes from the result of a previous call to
    /// `Path.stringRepresentation`. Fails if the `string` does not
    /// describe a valid path.
    public init?(_ string: String) {
        #if canImport(CoreGraphics)
        let mutablePath = CGMutablePath()
        let nsString = string as NSString
        guard let str = nsString.utf8String else {
            return nil
        }
        guard _CGPathParseString(mutablePath, str) else {
            return nil
        }
        storage = .path(PathBox(mutablePath))
        _openSwiftUIUnimplementedFailure()
        #else
        return nil
        #endif
    }

    /// A description of the path that may be used to recreate the path
    /// via `init?(_:)`.
    public var description: String {
        _openSwiftUIUnimplementedFailure()
    }

    #if canImport(CoreGraphics)
    /// An immutable path representing the elements in the path.
    public var cgPath: CGPath {
        _openSwiftUIUnimplementedFailure()
    }
    #endif

    package func retainORBPath() -> ORBPath {
        _openSwiftUIUnimplementedFailure()
    }

    package mutating func withMutableBuffer(do body: (UnsafeMutableRawPointer) -> Void) {
        _openSwiftUIUnimplementedFailure()
    }

    /// A Boolean value indicating whether the path contains zero elements.
    public var isEmpty: Bool {
        _openSwiftUIUnimplementedFailure()
    }

    /// A rectangle containing all path segments.
    ///
    /// This is the smallest rectangle completely enclosing all points
    /// in the path but not including control points for Bézier
    /// curves.
    public var boundingRect: CGRect {
        _openSwiftUIUnimplementedFailure()
    }
    
    /// Returns true if the path contains a specified point.
    ///
    /// If `eoFill` is true, this method uses the even-odd rule to define which
    /// points are inside the path. Otherwise, it uses the non-zero rule.
    public func contains(_ p: CGPoint, eoFill: Bool = false) -> Bool {
        _openSwiftUIUnimplementedFailure()
    }

    package func contains(points: [CGPoint], eoFill: Bool = false, origin: CGPoint = .zero) -> BitVector64 {
        _openSwiftUIUnimplementedFailure()
    }

    /// An element of a path.
    @frozen
    public enum Element: Equatable {
        /// A path element that terminates the current subpath (without closing
        /// it) and defines a new current point.
        case move(to: CGPoint)

        /// A line from the previous current point to the given point, which
        /// becomes the new current point.
        case line(to: CGPoint)

        /// A quadratic Bézier curve from the previous current point to the
        /// given end-point, using the single control point to define the curve.
        ///
        /// The end-point of the curve becomes the new current point.
        case quadCurve(to: CGPoint, control: CGPoint)

        /// A cubic Bézier curve from the previous current point to the given
        /// end-point, using the two control points to define the curve.
        ///
        /// The end-point of the curve becomes the new current point.
        case curve(to: CGPoint, control1: CGPoint, control2: CGPoint)

        /// A line from the start point of the current subpath (if any) to the
        /// current point, which terminates the subpath.
        ///
        /// After closing the subpath, the current point becomes undefined.
        case closeSubpath
    }

    /// Calls `body` with each element in the path.
    public func forEach(_ body: (Path.Element) -> Void) {
        _openSwiftUIUnimplementedFailure()
    }

    /// Returns a stroked copy of the path using `style` to define how the
    /// stroked outline is created.
    public func strokedPath(_ style: StrokeStyle) -> Path {
        _openSwiftUIUnimplementedFailure()
    }

    /// Returns a partial copy of the path.
    ///
    /// The returned path contains the region between `from` and `to`, both of
    /// which must be fractions between zero and one defining points
    /// linearly-interpolated along the path.
    public func trimmedPath(from: CGFloat, to: CGFloat) -> Path {
        _openSwiftUIUnimplementedFailure()
    }

    package func rect() -> CGRect? {
        _openSwiftUIUnimplementedFailure()
    }

    package func roundedRect() -> FixedRoundedRect? {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(*, unavailable)
extension Path.Storage: Sendable {}

@available(*, unavailable)
extension Path.PathBox: Sendable {}

// MARK: - Path + Shape

extension Path: Shape {
    nonisolated public func path(in _: CGRect) -> Path { self }

    public typealias AnimatableData = EmptyAnimatableData

    public typealias Body = _ShapeView<Path, ForegroundStyle>
}

// MARK: - Path + ProtobufMessage

extension Path: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - StrokedPath

@available(*, deprecated, message: "obsolete")
@usableFromInline
package struct StrokedPath: Equatable {
    public init(path: Path, style: StrokeStyle) {}

    @usableFromInline
    package static func == (a: StrokedPath, b: StrokedPath) -> Bool {
        true
    }
}

@available(*, unavailable)
extension StrokedPath: Sendable {}

// MARK: - TrimmedPath

@available(*, deprecated, message: "obsolete")
@usableFromInline
package struct TrimmedPath: Equatable {
    @usableFromInline
    package static func == (a: TrimmedPath, b: TrimmedPath) -> Swift.Bool {
        true
    }
}

@available(*, unavailable)
extension TrimmedPath: Sendable {}
