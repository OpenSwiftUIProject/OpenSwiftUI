//
//  Path.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 31FD92B70C320DDD253E93C7417D779A RELEASE_2021
//  ID: 3591905F51357E95FA93E39751507471 RELEASE_2024

import Foundation

#if canImport(CoreGraphics)
internal import COpenSwiftUI
import CoreGraphics

@_silgen_name("__CGPathParseString")
private func __CGPathParseString(_ path: CGMutablePath, _ utf8CString: UnsafePointer<CChar>) -> Bool
#endif

// MARK: - Path

/// The outline of a 2D shape.
@frozen
public struct Path/*: Equatable, LosslessStringConvertible*/ {
    var storage: Path.Storage
    
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
        storage = .roundedRect(FixedRoundedRect(rect: rect, cornerSize: cornerSize, style: style))
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
        storage = .roundedRect(FixedRoundedRect(rect: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius), style: style))
    }

    #if OPENSWIFTUI_SUPPORT_2022_API
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
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    public init(roundedRect rect: CGRect, cornerRadii: RectangleCornerRadii, style: RoundedCornerStyle = .continuous) {
        fatalError("TODO")
    }
    #endif
    
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
        guard __CGPathParseString(mutablePath, str) else {
            return nil
        }
        storage = .path(PathBox(mutablePath))
        #else
        return nil
        #endif
    }

    /// A description of the path that may be used to recreate the path
    /// via `init?(_:)`.
    public var description: String {
        fatalError("TODO")
    }

    #if canImport(CoreGraphics)
    /// An immutable path representing the elements in the path.
    public var cgPath: CGPath {
        fatalError("TODO")
    }
    #endif
    
    /// A Boolean value indicating whether the path contains zero elements.
    public var isEmpty: Bool {
        fatalError("TODO")
    }

    /// A rectangle containing all path segments.
    ///
    /// This is the smallest rectangle completely enclosing all points
    /// in the path but not including control points for Bézier
    /// curves.
    public var boundingRect: CGRect {
        fatalError("TODO")
    }
    
    /// Returns true if the path contains a specified point.
    ///
    /// If `eoFill` is true, this method uses the even-odd rule to define which
    /// points are inside the path. Otherwise, it uses the non-zero rule.
    public func contains(_ p: CGPoint, eoFill: Bool = false) -> Bool {
        fatalError("TODO")
    }
    
    /// Calls `body` with each element in the path.
    public func forEach(_ body: (Path.Element) -> Void) {
        fatalError("TODO")
    }

    /// Returns a stroked copy of the path using `style` to define how the
    /// stroked outline is created.
    public func strokedPath(_ style: StrokeStyle) -> Path {
        fatalError("TODO")
    }

    /// Returns a partial copy of the path.
    ///
    /// The returned path contains the region between `from` and `to`, both of
    /// which must be fractions between zero and one defining points
    /// linearly-interpolated along the path.
    public func trimmedPath(from: CGFloat, to: CGFloat) -> Path {
        fatalError("TODO")
    }
}

#if canImport(CoreGraphics)

// MARK: - Path.PathBox

extension Path {
    @usableFromInline
    final package class PathBox: Equatable {
//        #if OPENSWIFTUI_RELEASE_2024 // Also on RELEASE_2023
//        private var kind: Kind
////        var data: PathData
//        private init() {
//            kind = .buffer
//            // TODO
//        }
//        private enum Kind: UInt8 {
//            case cgPath
//            case rbPath
//            case buffer
//        }
//        #elseif OPENSWIFTUI_RELEASE_2021
        let cgPath: CGMutablePath
        var bounds: UnsafeAtomicLazy<CGRect>
        
        init(_ path: CGPath) {
            cgPath = path as! CGMutablePath
            bounds = UnsafeAtomicLazy(cache: nil)
        }
        
        init(_ mutablePath: CGMutablePath) {
            cgPath = mutablePath
            bounds = UnsafeAtomicLazy(cache: nil)
        }
        
        deinit {
            bounds.destroy()
        }
        
        @usableFromInline
        package static func == (lhs: PathBox, rhs: PathBox) -> Bool {
            lhs.cgPath === rhs.cgPath
        }
        
        var boundingRect: CGRect {
            if let cache = bounds.cache {
                return cache
            } else {
                let boundingBox = cgPath.boundingBoxOfPath
                bounds.$cache.withMutableData { rect in
                    if rect == nil {
                        rect = boundingBox
                    }
                }
                return boundingBox
            }
        }
        
        private func clearCache() {
            bounds.cache = nil
        }
//        #endif
    }
}

#endif

// MARK: - Path.Storage

extension Path {
    @usableFromInline
    @frozen enum Storage: Equatable {
        case rect(CGRect)
        case ellipse(CGRect)
        indirect case roundedRect(FixedRoundedRect)
//        indirect case stroked(StrokedPath)
//        indirect case trimmed(TrimmedPath)
        #if canImport(CoreGraphics)
        case path(PathBox)
        #endif
        case empty
    }
}

// MARK: - Path.Element

extension Path {
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
}

// MARK: - CodablePath[WIP]

struct CodablePath: CodableProxy {
    var base: Path

    private enum Error: Swift.Error {
        case invalidPath
    }

    private enum CodingKind: UInt8, Codable {
        case empty
        case rect
        case ellipse
        case roundedRect
        case stroked
        case trimmed
        case data
    }

    private enum CodingKeys: Hashable, CodingKey {
        case kind
        case value
    }

    // TODO:
    func encode(to _: Encoder) throws {}

    // TODO:
    init(from _: Decoder) throws {
        base = Path()
    }

    @inline(__always)
    init(base: Path) {
        self.base = base
    }
}

// MARK: - Path + CodableByProxy

extension Path: CodableByProxy {
    var codingProxy: CodablePath { CodablePath(base: self) }

    static func unwrap(codingProxy: CodablePath) -> Path { codingProxy.base }
}
