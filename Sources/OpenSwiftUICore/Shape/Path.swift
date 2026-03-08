//
//  Path.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 31FD92B70C320DDD253E93C7417D779A (SwiftUI)
//  ID: 3591905F51357E95FA93E39751507471 (SwiftUICore)

public import Foundation
package import OpenRenderBoxShims
import OpenSwiftUI_SPI
public import OpenCoreGraphicsShims

// MARK: - Path [WIP]

/// The outline of a 2D shape.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct Path: Equatable, LosslessStringConvertible, @unchecked Sendable {

    // MARK: - Path.PathBox

    @usableFromInline
    final package class PathBox: Equatable {
        private enum Kind: UInt8 {
            #if canImport(CoreGraphics) || !OPENSWIFTUI_CF_CGTYPES
            case cgPath
            #endif
            case rbPath
            case buffer
        }

        private var kind: Kind
        private var data: PathData

        #if canImport(CoreGraphics) || !OPENSWIFTUI_CF_CGTYPES
        @inline(__always)
        init(_ path: CGPath) {
            kind = .cgPath
            data = PathData(cgPath: .passUnretained(path))
        }
        #endif

        package init(takingPath path: ORBPath) {
            kind = .rbPath
            data = PathData(rbPath: path)
        }

        private func prepareBuffer() {
            let path: ORBPath
            switch kind {
            #if canImport(CoreGraphics) || !OPENSWIFTUI_CF_CGTYPES
            case .cgPath:
                path = ORBPath(cgPath: data.cgPath.takeRetainedValue())
            #endif
            case .rbPath:
                path = data.rbPath
            case .buffer:
                return
            }
            withUnsafeMutablePointer(to: &data) { pointer in
                let storage = unsafeBitCast(pointer, to: ORBPath.Storage.self)
                storage.initialize(capacity: 96, source: nil)
                storage.append(path: path)
                kind = .buffer
                path.release()
            }
        }

        private static let bufferCallbacks: UnsafePointer<ORBPath.Callbacks> = {
            let pointer = UnsafeMutablePointer<ORBPath.Callbacks>.allocate(capacity: 1)
            var callbacks = ORBPath.empty.callbacks.pointee
            callbacks.retain = { object in
                UnsafeRawPointer(
                    Unmanaged<PathBox>.fromOpaque(object)
                    .retain()
                    .toOpaque()
                )
            }
            callbacks.release = { object in
                Unmanaged<PathBox>.fromOpaque(object)
                    .release()
            }
            callbacks.apply = { object, info, callback in
                let box = object.assumingMemoryBound(to: PathBox.self).pointee
                let storage = withUnsafeMutablePointer(to: &box.data) {
                    unsafeBitCast($0, to: ORBPath.Storage.self)
                }
                return storage.apply(info: info, callback: callback)
            }
            callbacks.isEqual = { lhs, rhs in
                let lhsBox = lhs.assumingMemoryBound(to: PathBox.self).pointee
                let rhsBox = rhs.assumingMemoryBound(to: PathBox.self).pointee
                let lhsStorage = withUnsafeMutablePointer(to: &lhsBox.data) {
                    unsafeBitCast($0, to: ORBPath.Storage.self)
                }
                let rhsStorage = withUnsafeMutablePointer(to: &rhsBox.data) {
                    unsafeBitCast($0, to: ORBPath.Storage.self)
                }
                return lhsStorage.isEqual(to: rhsStorage)
            }
            callbacks.isEmpty = { object in
                let box = object.assumingMemoryBound(to: PathBox.self).pointee
                let storage = withUnsafeMutablePointer(to: &box.data) {
                    unsafeBitCast($0, to: ORBPath.Storage.self)
                }
                return storage.isEmpty
            }
            callbacks.isSingleElement = { object in
                let box = object.assumingMemoryBound(to: PathBox.self).pointee
                let storage = withUnsafeMutablePointer(to: &box.data) {
                    unsafeBitCast($0, to: ORBPath.Storage.self)
                }
                return storage.isEmpty
            }
            callbacks.bezierOrder = { object in
                let box = object.assumingMemoryBound(to: PathBox.self).pointee
                let storage = withUnsafeMutablePointer(to: &box.data) {
                    unsafeBitCast($0, to: ORBPath.Storage.self)
                }
                return storage.bezierOrder
            }
            callbacks.boundingRect = { object in
                let box = object.assumingMemoryBound(to: PathBox.self).pointee
                let storage = withUnsafeMutablePointer(to: &box.data) {
                    unsafeBitCast($0, to: ORBPath.Storage.self)
                }
                return storage.boundingRect
            }
            pointer.initialize(to: callbacks)
            return UnsafePointer(pointer)
        }()

        #if canImport(CoreGraphics) || !OPENSWIFTUI_CF_CGTYPES
        @inline(__always)
        fileprivate var cgPath: CGPath {
            let rbPath: ORBPath
            switch kind {
            case .cgPath:
                return data.cgPath.takeUnretainedValue()
            case .rbPath:
                rbPath = data.rbPath
            case .buffer:
                let storage = unsafeBitCast(self, to: ORBPath.Storage.self)
                rbPath = ORBPath(storage: storage, callbacks: Self.bufferCallbacks)
            }
            return rbPath.cgPath
        }
        #endif

        @inline(__always)
        fileprivate var rbPath: ORBPath {
            switch kind {
            case .cgPath:
                return ORBPath(cgPath: data.cgPath.takeUnretainedValue())
            case .rbPath:
                return data.rbPath
            case .buffer:
                let storage = unsafeBitCast(self, to: ORBPath.Storage.self)
                return ORBPath(storage: storage, callbacks: Self.bufferCallbacks)
            }
        }

        @inline(__always)
        fileprivate func retainRBPath() -> ORBPath {
            let rbPath = rbPath
            rbPath.retain()
            return rbPath
        }

        @usableFromInline
        package static func == (lhs: PathBox, rhs: PathBox) -> Bool {
            return lhs.rbPath.isEqual(to: rhs.rbPath)
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

    #if canImport(CoreGraphics) || !OPENSWIFTUI_CF_CGTYPES
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
        // TODO: addRoundedRect
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
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return nil
        #endif
    }

    /// A description of the path that may be used to recreate the path
    /// via `init?(_:)`.
    public var description: String {
        #if canImport(Darwin)
        _CGPathCopyDescription(cgPath, 0.0)
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }

    #if canImport(CoreGraphics) || !OPENSWIFTUI_CF_CGTYPES
    /// An immutable path representing the elements in the path.
    public var cgPath: CGPath {
        #if canImport(Darwin)
        switch storage {
        case .empty:
            CGPath(rect: .null, transform: nil)
        case let .rect(rect):
            CGPath(rect: rect, transform: nil)
        case let .ellipse(rect):
            CGPath(ellipseIn: rect, transform: nil)
        case let .roundedRect(fixedRoundedRect):
            fixedRoundedRect.cgPath
        case .stroked, .trimmed:
            _openSwiftUIUnreachableCode()
        case let .path(pathBox):
            pathBox.cgPath
        }
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
    #endif

    package func retainRBPath() -> ORBPath {
        switch storage {
        case .empty:
            ORBPath.empty
        case let .rect(rect):
            ORBPath(rect: rect, transform: nil)
        case let .ellipse(rect):
            ORBPath(ellipseIn: rect, transform: nil)
        case let .roundedRect(fixedRoundedRect):
            ORBPath(
                roundedRect: fixedRoundedRect.rect,
                cornerWidth: fixedRoundedRect.cornerSize.width,
                cornerHeight: fixedRoundedRect.cornerSize.height,
                style: fixedRoundedRect.style == .circular ? .circular : .continuous,
                transform: nil
            )
        case .stroked, .trimmed:
            _openSwiftUIUnreachableCode()
        case let .path(pathBox):
            pathBox.retainRBPath()
        }
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
        switch storage {
        case let .rect(rect):
            rect
        default:
            nil
        }
    }

    package func roundedRect() -> FixedRoundedRect? {
        switch storage {
        case let .rect(rect):
            FixedRoundedRect(rect)
        case let .ellipse(rect):
            if rect.width == rect.height {
                FixedRoundedRect(
                    rect,
                    cornerRadius: rect.width / 2,
                    style: .circular
                )
            } else {
                nil
            }
        case let .roundedRect(fixedRoundedRect):
            fixedRoundedRect
        default:
            nil
        }
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

// MARK: - Path + Extension [WIP]

@available(OpenSwiftUI_v1_0, *)
extension Path {
    public mutating func move(to end: CGPoint) {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func addLine(to end: CGPoint) {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func addQuadCurve(
        to end: CGPoint,
        control: CGPoint
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func addCurve(
        to end: CGPoint,
        control1: CGPoint,
        control2: CGPoint
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func closeSubpath() {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func addRect(
        _ rect: CGRect,
        transform: CGAffineTransform = .identity
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func addRoundedRect(
        in rect: CGRect,
        cornerSize: CGSize,
        style: RoundedCornerStyle = .continuous,
        transform: CGAffineTransform = .identity
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v4_0, *)
    public mutating func addRoundedRect(
        in rect: CGRect,
        cornerRadii: RectangleCornerRadii,
        style: RoundedCornerStyle = .continuous,
        transform: CGAffineTransform = .identity
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func addEllipse(
        in rect: CGRect,
        transform: CGAffineTransform = .identity
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func addRects(
        _ rects: [CGRect],
        transform: CGAffineTransform = .identity
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func addLines(_ lines: [CGPoint]) {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func addRelativeArc(
        center: CGPoint,
        radius: CGFloat,
        startAngle: Angle,
        delta: Angle,
        transform: CGAffineTransform = .identity
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func addArc(
        center: CGPoint,
        radius: CGFloat,
        startAngle: Angle,
        endAngle: Angle,
        clockwise: Bool,
        transform: CGAffineTransform = .identity
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func addArc(
        tangent1End: CGPoint,
        tangent2End: CGPoint,
        radius: CGFloat,
        transform: CGAffineTransform = .identity
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    public mutating func addPath(
        _ path: Path,
        transform: CGAffineTransform = .identity
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    public var currentPoint: CGPoint? {
        get { _openSwiftUIUnimplementedFailure() }
    }

    @available(OpenSwiftUI_v5_0, *)
    public func normalized(eoFill: Bool = true) -> Path {
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v5_0, *)
    public func intersection(
        _ other: Path,
        eoFill: Bool = false
    ) -> Path {
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v5_0, *)
    public func union(
        _ other: Path,
        eoFill: Bool = false
    ) -> Path {
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v5_0, *)
    public func subtracting(
        _ other: Path,
        eoFill: Bool = false
    ) -> Path {
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v5_0, *)
    public func symmetricDifference(
        _ other: Path,
        eoFill: Bool = false
    ) -> Path {
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v5_0, *)
    public func lineIntersection(
        _ other: Path,
        eoFill: Bool = false
    ) -> Path {
        _openSwiftUIUnimplementedFailure()
    }

    @available(OpenSwiftUI_v5_0, *)
    public func lineSubtraction(
        _ other: Path,
        eoFill: Bool = false
    ) -> Path {
        _openSwiftUIUnimplementedFailure()
    }

    package mutating func formTrivialUnion(_ path: Path) {
        _openSwiftUIUnimplementedFailure()
    }

    public func applying(_ transform: CGAffineTransform) -> Path {
        _openSwiftUIUnimplementedFailure()
    }

    public func offsetBy(
        dx: CGFloat,
        dy: CGFloat
    ) -> Path {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - RenderBox

private let temporaryPathCallbacks: UnsafePointer<ORBPath.Callbacks> = {
    let pointer = UnsafeMutablePointer<ORBPath.Callbacks>.allocate(capacity: 1)
    var callbacks = ORBPath.empty.callbacks.pointee
    callbacks.retain = { _ in
        _openSwiftUIUnreachableCode()
    }
    callbacks.release = { _ in
        _openSwiftUIUnreachableCode()
    }
    callbacks.apply = { object, info, callback in
        let storage = unsafeBitCast(object, to: ORBPath.Storage.self)
        return storage.apply(info: info, callback: callback)
    }
    callbacks.isEqual = { lhs, rhs in
        let lhs = unsafeBitCast(lhs, to: ORBPath.Storage.self)
        let rhs = unsafeBitCast(rhs, to: ORBPath.Storage.self)
        return lhs.isEqual(to: rhs)
    }
    callbacks.isEmpty = { object in
        let storage = unsafeBitCast(object, to: ORBPath.Storage.self)
        return storage.isEmpty
    }
    callbacks.isSingleElement = { object in
        let storage = unsafeBitCast(object, to: ORBPath.Storage.self)
        return storage.isSingleElement
    }
    callbacks.boundingRect = { object in
        let storage = unsafeBitCast(object, to: ORBPath.Storage.self)
        return storage.boundingRect
    }
    callbacks.cgPath = { object in
        let storage = unsafeBitCast(object, to: ORBPath.Storage.self)
        let cgPath = storage.cgPath
        return cgPath.map { .passUnretained($0) }
    }
    pointer.initialize(to: callbacks)
    return UnsafePointer(pointer)
}()

extension ORBPath {
    static func withTemporaryPath<R>(
        do body: (ORBPath) -> R,
        builder: (UnsafeMutableRawPointer) -> ()
    ) -> R {
        return withUnsafeTemporaryAllocation(
            of: UInt8.self,
            capacity: 128
        ) { bufferPointer in
            let pointer = UnsafeMutableRawBufferPointer(
                mutating: UnsafeRawBufferPointer(bufferPointer)
            ).baseAddress!
            let storage: ORBPath.Storage = unsafeBitCast(pointer, to: ORBPath.Storage.self)
            storage.initialize(capacity: 128, source: nil)
            builder(pointer)
            let path = ORBPath(
                storage: storage,
                callbacks: temporaryPathCallbacks
            )
            let result = body(path)
            storage.destroy()
            return result
        }
    }
}
