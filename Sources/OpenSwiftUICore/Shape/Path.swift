//
//  Path.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 31FD92B70C320DDD253E93C7417D779A (SwiftUI)
//  ID: 3591905F51357E95FA93E39751507471 (SwiftUICore)

public import Foundation
package import OpenRenderBoxShims
import OpenSwiftUI_SPI
public import OpenCoreGraphicsShims

// MARK: - Path

/// The outline of a 2D shape.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct Path: Equatable, LosslessStringConvertible, @unchecked Sendable {

    // MARK: - Path.PathBox

    @usableFromInline
    final package class PathBox: Equatable {
        private enum Kind: UInt8 {
            case cgPath
            case rbPath
            case buffer
        }

        private var kind: Kind
        private var data: PathData = PathData()

        private func withStorage<Result>(_ body: (ORBPath.Storage) -> Result) -> Result {
            ManagedBufferPointer<(Kind, PathData), Void>(unsafeBufferObject: self)
                .withUnsafeMutablePointerToHeader {
                    body(ORBPath.Storage($0.pointer(to: \.1)!))
                }
        }

        @inline(__always)
        init(_ body: (UnsafeMutableRawPointer) -> Void) {
            kind = .buffer
            withStorage {
                $0.initialize(capacity: MemoryLayout<PathData>.size, source: nil)
                body(UnsafeMutableRawPointer($0.rawValue))
            }
        }

        @inline(__always)
        convenience init() {
            self.init { _ in }
        }

        @inline(__always)
        init(copying box: PathBox) {
            kind = box.kind
            switch kind {
            case .cgPath:
                data.cgPath = .passRetained(box.data.cgPath!.takeUnretainedValue())
            case .rbPath:
                data.rbPath = box.data.rbPath.retain()
            case .buffer:
                box.withStorage { source in
                    withStorage { dest in
                        dest.initialize(capacity: MemoryLayout<PathData>.size, source: source)
                    }
                }
            }
        }

        @inline(__always)
        init(_ path: CGPath) {
            kind = .cgPath
            data.cgPath = .passRetained(path)
        }

        package init(takingPath path: ORBPath) {
            kind = .rbPath
            data.rbPath = path
        }

        deinit {
            switch kind {
            case .cgPath:
                data.cgPath!.release()
            case .rbPath:
                data.rbPath.release()
            case .buffer:
                withStorage { $0.destroy() }
            }
        }

        private func prepareBuffer() {
            let path: ORBPath
            switch kind {
            case .cgPath:
                path = ORBPath(cgPath: data.cgPath!.takeRetainedValue())
            case .rbPath:
                path = data.rbPath
            case .buffer:
                return
            }
            withStorage {
                $0.initialize(capacity: MemoryLayout<PathData>.size, source: nil)
                _ = $0.append(path: path)
            }
            kind = .buffer
            path.release()
        }

        @inline(__always)
        func withBuffer<Result>(_ body: (UnsafeMutableRawPointer) -> Result) -> Result {
            if kind != .buffer {
                prepareBuffer()
            }
            return withStorage {
                body(UnsafeMutableRawPointer($0.rawValue))
            }
        }

        @inline(__always)
        static func fromOpaque(_ pointer: UnsafeRawPointer) -> PathBox {
            Unmanaged<PathBox>.fromOpaque(pointer).takeUnretainedValue()
        }

        private static let bufferCallbacks: UnsafePointer<ORBPath.Callbacks> = {
            let pointer = UnsafeMutablePointer<ORBPath.Callbacks>.allocate(capacity: 1)
            pointer.initialize(to: .init())
            pointer.pointee.retain = { object in
                UnsafeRawPointer(
                    Unmanaged<PathBox>.fromOpaque(object)
                        .retain()
                        .toOpaque()
                )
            }
            pointer.pointee.release = { object in
                Unmanaged<PathBox>.fromOpaque(object)
                    .release()
            }
            pointer.pointee.apply = { object, info, callback in
                fromOpaque(object).withStorage { $0.apply(info: info, callback: callback) }
            }
            pointer.pointee.isEqual = { lhs, rhs in
                fromOpaque(rhs).withStorage { rhsStorage in
                    fromOpaque(lhs).withStorage { lhsStorage in
                        lhsStorage.isEqual(to: rhsStorage)
                    }
                }
            }
            pointer.pointee.isEmpty = { object in
                fromOpaque(object).withStorage { $0.isEmpty }
            }
            pointer.pointee.isSingleElement = { object in
                fromOpaque(object).withStorage { $0.isSingleElement }
            }
            pointer.pointee.bezierOrder = { object in
                fromOpaque(object).withStorage { $0.bezierOrder }
            }
            pointer.pointee.boundingRect = { object in
                fromOpaque(object).withStorage { $0.boundingRect }
            }
            return UnsafePointer(pointer)
        }()

        @inline(__always)
        func withRBPath<Result>(_ body: (ORBPath) -> Result) -> Result {
            let path: ORBPath
            switch kind {
            case .cgPath:
                path = ORBPath(
                    storage: ORBPath.Storage(data.cgPath!.toOpaque()),
                    callbacks: ORBPath.Callbacks.cgPath
                )
            case .rbPath:
                path = data.rbPath
            case .buffer:
                path = ORBPath(
                    storage: ORBPath.Storage(Unmanaged.passUnretained(self).toOpaque()),
                    callbacks: Self.bufferCallbacks
                )
            }
            return body(path)
        }

        @inline(__always)
        var cgPath: CGPath {
            guard kind != .cgPath else {
                return data.cgPath!.takeUnretainedValue()
            }
            return withRBPath { $0.cgPath }
        }

        @inline(__always)
        var boundingRect: CGRect {
            switch kind {
            case .cgPath:
                return data.cgPath!.takeUnretainedValue().boundingBoxOfPath
            case .rbPath:
                return data.rbPath.boundingRect
            case .buffer:
                return withStorage { $0.boundingRect }
            }
        }

        @usableFromInline
        package static func == (lhs: PathBox, rhs: PathBox) -> Bool {
            lhs.withRBPath { lhsPath in
                rhs.withRBPath { lhsPath.isEqual(to: $0) }
            }
        }
    }

    // MARK: - Path.Storage

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

    package init(_ path: ORBPath) {
        self.init(box: PathBox(takingPath: path.retain()))
    }

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
    @available(OpenSwiftUI_v4_0, *)
    public init(roundedRect rect: CGRect, cornerRadii: RectangleCornerRadii, style: RoundedCornerStyle = .continuous) {
        storage = .empty
        addRoundedRect(in: rect, cornerRadii: cornerRadii, style: style)
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
        let mutablePath = CGMutablePath()
        guard string.withCString({ _CGPathParseString(mutablePath, $0) }) else {
            return nil
        }
        storage = .path(PathBox(mutablePath))
    }

    /// A description of the path that may be used to recreate the path
    /// via `init?(_:)`.
    public var description: String {
        String(cfString: _CGPathCopyDescription(cgPath, 0.0))
    }

    /// An immutable path representing the elements in the path.
    public var cgPath: CGPath {
        switch storage {
        case .empty:
            return CGPath(rect: .null, transform: nil)
        case let .rect(rect):
            return CGPath(rect: rect, transform: nil)
        case let .ellipse(rect):
            return CGPath(ellipseIn: rect, transform: nil)
        case let .roundedRect(fixedRoundedRect):
            return fixedRoundedRect.cgPath
        case .stroked, .trimmed:
            preconditionFailure("obsolete")
        case let .path(pathBox):
            return pathBox.cgPath
        }
    }

    package func retainRBPath() -> ORBPath {
        switch storage {
        case .empty:
            return ORBPath.empty
        case let .rect(rect):
            return ORBPath(rect: rect, transform: nil)
        case let .ellipse(rect):
            return ORBPath(ellipseIn: rect, transform: nil)
        case let .roundedRect(fixedRoundedRect):
            return ORBPath(
                roundedRect: fixedRoundedRect.rect,
                cornerWidth: fixedRoundedRect.cornerSize.width,
                cornerHeight: fixedRoundedRect.cornerSize.height,
                style: fixedRoundedRect.style == .circular ? .circular : .continuous,
                transform: nil
            )
        case .stroked, .trimmed:
            preconditionFailure("obsolete")
        case let .path(pathBox):
            return pathBox.withRBPath { $0.retain() }
        }
    }

    package mutating func withMutableBuffer(do body: (UnsafeMutableRawPointer) -> Void) {
        let box: PathBox
        if case .path(var existing) = storage {
            storage = .empty
            if !isKnownUniquelyReferenced(&existing) {
                existing = PathBox(copying: existing)
            }
            box = existing
        } else {
            box = PathBox()
            box.withBuffer { append(to: $0) }
        }
        storage = .path(box)
        box.withBuffer(body)
    }

    private func append(to buffer: UnsafeMutableRawPointer) {
        let storage = ORBPath.Storage(buffer)
        switch self.storage {
        case .empty:
            break
        case let .rect(rect):
            storage.append(
                element: .rect,
                points: [
                    rect.x,
                    rect.y,
                    rect.size.width,
                    rect.size.height
                ],
                userInfo: nil
            )
        case let .ellipse(rect):
            storage.append(
                element: .ellipse,
                points: [
                    rect.x,
                    rect.y,
                    rect.size.width,
                    rect.size.height
                ],
                userInfo: nil
            )
        case let .roundedRect(roundedRect):
            storage.append(
                element: roundedRect.style == .circular ? .fixedRoundedRectCircular : .fixedRoundedRectContinuous,
                points: [
                    roundedRect.rect.x,
                    roundedRect.rect.y,
                    roundedRect.rect.size.width,
                    roundedRect.rect.size.height,
                    roundedRect.cornerSize.width,
                    roundedRect.cornerSize.height
                ],
                userInfo: nil
            )
        case .stroked, .trimmed:
            preconditionFailure("obsolete")
        case let .path(box):
            box.withRBPath { _ = storage.append(path: $0) }
        }
    }

    /// A Boolean value indicating whether the path contains zero elements.
    public var isEmpty: Bool {
        switch storage {
        case .empty:
            return true
        case let .rect(rect), let .ellipse(rect):
            return rect.isNull
        case let .roundedRect(fixedRoundedRect):
            return fixedRoundedRect.rect.isNull
        case .stroked, .trimmed:
            preconditionFailure("obsolete")
        case let .path(pathBox):
            return pathBox.withRBPath { $0.isEmpty }
        }
    }

    /// A rectangle containing all path segments.
    ///
    /// This is the smallest rectangle completely enclosing all points
    /// in the path but not including control points for Bézier
    /// curves.
    public var boundingRect: CGRect {
        switch storage {
        case .empty:
            return .null
        case let .rect(rect), let .ellipse(rect):
            return rect
        case let .roundedRect(fixedRoundedRect):
            return fixedRoundedRect.rect
        case .stroked, .trimmed:
            preconditionFailure("obsolete")
        case let .path(pathBox):
            return pathBox.boundingRect
        }
    }

    /// Returns true if the path contains a specified point.
    ///
    /// If `eoFill` is true, this method uses the even-odd rule to define which
    /// points are inside the path. Otherwise, it uses the non-zero rule.
    public func contains(_ p: CGPoint, eoFill: Bool = false) -> Bool {
        switch storage {
        case .empty:
            return false
        case let .rect(rect):
            return rect.contains(p)
        case let .ellipse(rect):
            return ellipseContains(in: rect, contains: p)
        case let .roundedRect(rect):
            return rect.contains(p)
        case .stroked, .trimmed:
            preconditionFailure("obsolete")
        case let .path(box):
            return box.withRBPath { $0.contains(point: p, eoFill: eoFill) }
        }
    }

    package func contains(
        points: [PlatformPoint],
        eoFill: Bool = false,
        origin: CGPoint = .zero
    ) -> BitVector64 {
        points.withUnsafeBufferPointer {
            contains(points: $0, eoFill: eoFill, origin: origin)
        }
    }

    package func contains(
        points: UnsafeBufferPointer<PlatformPoint>,
        eoFill: Bool = false,
        origin: CGPoint = .zero
    ) -> BitVector64 {
        guard !points.isEmpty else {
            return BitVector64()
        }
        switch storage {
        case .empty:
            return BitVector64()
        case let .rect(rect):
            return points.mapBool {
                rect.contains(CGPoint($0 - origin))
            }
        case let .ellipse(rect):
            return points.mapBool {
                ellipseContains(in: rect, contains: CGPoint($0 - origin))
            }
        case let .roundedRect(roundedRect):
            var transform = CGAffineTransform(translationX: -origin.x, y: -origin.y)
            return roundedRect.withTemporaryPath { rbPath in
                BitVector64(
                    rawValue: rbPath.containsPoints(
                        count: UInt64(points.count),
                        points: points.baseAddress!,
                        eoFill: false,
                        transform: &transform
                    )
                )
            }
        case .stroked, .trimmed:
            preconditionFailure("obsolete")
        case let .path(box):
            var transform = CGAffineTransform(translationX: -origin.x, y: -origin.y)
            return box.withRBPath { rbPath in
                BitVector64(
                    rawValue: rbPath.containsPoints(
                        count: UInt64(points.count),
                        points: points.baseAddress!,
                        eoFill: eoFill,
                        transform: &transform
                    )
                )
            }
        }
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
        withoutActuallyEscaping(body) { escapingBody in
            struct Context {
                let body: (Path.Element) -> Void
            }
            let rbPath = retainRBPath()
            defer { rbPath.release() }
            var context = Context(body: escapingBody)
            withUnsafeMutablePointer(to: &context) { contextPtr in
                _ = rbPath.applyCGPathElements(transform: nil, info: contextPtr) { info, elementPtr in
                    let context = info.assumingMemoryBound(to: Context.self)
                    switch elementPtr.pointee.type {
                    case .moveToPoint:
                        context.pointee.body(.move(to: elementPtr.pointee.points[0]))
                    case .addLineToPoint:
                        context.pointee.body(.line(to: elementPtr.pointee.points[0]))
                    case .addQuadCurveToPoint:
                        context.pointee.body(
                            .quadCurve(
                                to: elementPtr.pointee.points[1],
                                control: elementPtr.pointee.points[0]
                            )
                        )
                    case .addCurveToPoint:
                        context.pointee.body(
                            .curve(
                                to: elementPtr.pointee.points[2],
                                control1: elementPtr.pointee.points[0],
                                control2: elementPtr.pointee.points[1]
                            )
                        )
                    case .closeSubpath:
                        context.pointee.body(.closeSubpath)
                    @unknown default:
                        break
                    }
                    return true
                }
            }
        }
    }

    /// Returns a stroked copy of the path using `style` to define how the
    /// stroked outline is created.
    public func strokedPath(_ style: StrokeStyle) -> Path {
        guard !isEmpty else { return Path() }
        let rbPath = retainRBPath()
        defer { rbPath.release() }
        return Path(box: PathBox { buffer in
            let storage = ORBPath.Storage(buffer)
            style.dash.withUnsafeBufferPointer { dash in
                let points = [style.lineWidth, style.miterLimit, style.dashPhase]
                var metadata = (
                    style.lineCap.rawValue,
                    style.lineJoin.rawValue,
                    dash.count,
                    dash.baseAddress
                )
                storage.append(element: .stroked, points: points, userInfo: &metadata)
            }
            append(to: buffer)
            storage.append(element: .end, points: nil, userInfo: nil)
        })
    }

    /// Returns a partial copy of the path.
    ///
    /// The returned path contains the region between `from` and `to`, both of
    /// which must be fractions between zero and one defining points
    /// linearly-interpolated along the path.
    public func trimmedPath(from: CGFloat, to: CGFloat) -> Path {
        guard !isEmpty else {
            return Path()
        }
        guard from > 0 || to < 1 else {
            return self
        }
        guard to > from else {
            return Path()
        }
        let rbPath = retainRBPath()
        defer { rbPath.release() }
        return Path(box: PathBox { buffer in
            let storage = ORBPath.Storage(buffer)
            storage.append(element: .trimmed, points: [from, to], userInfo: nil)
            append(to: buffer)
            storage.append(element: .end, points: nil, userInfo: nil)
        })
    }

    package func mix(with rhs: Path, by fraction: CGFloat) -> Path? {
        let p1 = retainRBPath()
        let p2 = rhs.retainRBPath()
        defer {
            p1.release()
            p2.release()
        }
        let mixed = p1.interpolated(to: p2, fraction: Float(fraction))
        guard !mixed.isNull else {
            return nil
        }
        return Path(box: PathBox(takingPath: mixed))
    }

    package func rect() -> CGRect? {
        switch storage {
        case let .rect(rect):
            return rect
        default:
            return nil
        }
    }

    package func roundedRect() -> FixedRoundedRect? {
        switch storage {
        case let .rect(rect):
            return FixedRoundedRect(rect)
        case let .ellipse(rect):
            if rect.size.width == rect.size.height {
                return FixedRoundedRect(
                    rect,
                    cornerRadius: rect.size.width / 2,
                    style: .circular
                )
            } else {
                return nil
            }
        case let .roundedRect(fixedRoundedRect):
            return fixedRoundedRect
        default:
            return nil
        }
    }
}

@available(*, unavailable)
extension Path.Storage: Sendable {}

@available(*, unavailable)
extension Path.PathBox: Sendable {}

// MARK: - Path + Shape

@available(OpenSwiftUI_v1_0, *)
extension Path: Shape {
    nonisolated public func path(in _: CGRect) -> Path { self }
}

// MARK: - Path + ProtobufMessage

extension Path: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        switch storage {
        case .empty:
            break
        case let .rect(rect):
            try encoder.messageField(1, rect)
        case let .ellipse(rect):
            try encoder.messageField(2, rect)
        case let .roundedRect(roundedRect):
            try encoder.messageField(3, roundedRect)
        case .stroked, .trimmed:
            preconditionFailure("obsolete")
        case .path:
            let rbPath = retainRBPath()
            defer { rbPath.release() }
            if let data = rbPath.data {
                encoder.dataField(4, Data(cfData: data))
            }
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var path = Path()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                path.storage = .rect(try decoder.messageField(field))
            case 2:
                path.storage = .ellipse(try decoder.messageField(field))
            case 3:
                path.storage = .roundedRect(try decoder.messageField(field))
            case 4:
                let data = try decoder.dataField(field)
                path.storage = .path(PathBox(takingPath: ORBPath(data: data.cfData)))
            default:
                try decoder.skipField(field)
            }
        }
        self = path
    }
}

// MARK: - StrokedPath

@available(OpenSwiftUI_v1_0, *)
@available(*, deprecated, message: "obsolete")
@usableFromInline
package struct StrokedPath: Equatable {
    public init(path: Path, style: StrokeStyle) {
        _openSwiftUIEmptyStub()
    }

    @usableFromInline
    package static func == (a: StrokedPath, b: StrokedPath) -> Bool {
        true
    }
}

@available(*, unavailable)
extension StrokedPath: Sendable {}

// MARK: - TrimmedPath

@available(OpenSwiftUI_v1_0, *)
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

// MARK: - Path + Extension

@available(OpenSwiftUI_v1_0, *)
extension Path {
    /// Begins a new subpath at the specified point.
    ///
    /// The specified point becomes the start point of a new subpath.
    /// The current point is set to this start point.
    ///
    /// - Parameter end: The point, in user space coordinates, at which
    ///   to start a new subpath.
    ///
    public mutating func move(to end: CGPoint) {
        withMutableBuffer { buffer in
            ORBPath.Storage(buffer)
                .append(
                    element: .moveToPoint,
                    points: [end.x, end.y],
                    userInfo: nil
                )
        }
    }

    /// Appends a straight line segment from the current point to the
    /// specified point.
    ///
    /// After adding the line segment, the current point is set to the
    /// endpoint of the line segment.
    ///
    /// - Parameter end: The location, in user space coordinates, for the
    ///   end of the new line segment.
    ///
    public mutating func addLine(to end: CGPoint) {
        withMutableBuffer { buffer in
            ORBPath.Storage(buffer)
                .append(
                    element: .addLineToPoint,
                    points: [end.x, end.y],
                    userInfo: nil
                )
        }
    }

    /// Adds a quadratic Bézier curve to the path, with the
    /// specified end point and control point.
    ///
    /// This method constructs a curve starting from the path's current
    /// point and ending at the specified end point, with curvature
    /// defined by the control point. After this method appends that
    /// curve to the current path, the end point of the curve becomes
    /// the path's current point.
    ///
    /// - Parameters:
    ///     the curve.
    ///   - control: The control point of the curve, in user space
    ///     coordinates.
    ///
    public mutating func addQuadCurve(
        to end: CGPoint,
        control: CGPoint
    ) {
        withMutableBuffer { buffer in
            ORBPath.Storage(buffer)
                .append(
                    element: .addQuadCurveToPoint,
                    points: [control.x, control.y, end.x, end.y],
                    userInfo: nil
                )
        }
    }

    /// Adds a cubic Bézier curve to the path, with the
    /// specified end point and control points.
    ///
    /// This method constructs a curve starting from the path's current
    /// point and ending at the specified end point, with curvature
    /// defined by the two control points. After this method appends
    /// that curve to the current path, the end point of the curve
    /// becomes the path's current point.
    ///
    /// - Parameters:
    ///     the curve.
    ///   - control1: The first control point of the curve, in user
    ///     space coordinates.
    ///   - control2: The second control point of the curve, in user
    ///     space coordinates.
    ///
    public mutating func addCurve(
        to end: CGPoint,
        control1: CGPoint,
        control2: CGPoint
    ) {
        withMutableBuffer { buffer in
            ORBPath.Storage(buffer)
                .append(
                    element: .addCurveToPoint,
                    points: [control1.x, control1.y, control2.x, control2.y, end.x, end.y],
                    userInfo: nil
                )
        }
    }

    /// Closes and completes the current subpath.
    ///
    /// Appends a line from the current point to the starting point of
    /// the current subpath and ends the subpath.
    ///
    /// After closing the subpath, your application can begin a new
    /// subpath without first calling `move(to:)`. In this case, a new
    /// subpath is implicitly created with a starting and current point
    /// equal to the previous subpath's starting point.
    ///
    public mutating func closeSubpath() {
        withMutableBuffer { buffer in
            ORBPath.Storage(buffer)
                .append(
                    element: .closeSubpath,
                    points: nil,
                    userInfo: nil
                )
        }
    }

    /// Adds a rectangular subpath to the path.
    ///
    /// This is a convenience function that adds a rectangle to a path,
    /// starting by moving to the bottom-left corner and then adding
    /// lines counter-clockwise to create a rectangle, closing the
    /// subpath.
    ///
    /// - Parameters:
    ///   - rect: A rectangle, specified in user space coordinates.
    ///   - transform: An affine transform to apply to the rectangle
    ///     before adding to the path. Defaults to the identity
    ///     transform if not specified.
    ///
    public mutating func addRect(
        _ rect: CGRect,
        transform: CGAffineTransform = .identity
    ) {
        guard !rect.isNull else { return }
        if case .empty = storage, transform.isRectilinear {
            storage = .rect(rect.applying(transform))
            return
        }
        withMutableBuffer { buffer in
            var transform = transform
            ORBPath.Storage(buffer).append(
                element: .rect,
                points: [rect.x, rect.y, rect.size.width, rect.size.height],
                userInfo: &transform
            )
        }
    }

    /// Adds a rounded rectangle to the path.
    ///
    /// This is a convenience function that adds a rounded rectangle to
    /// a path, starting by moving to the center of the right edge and
    /// then adding lines and curves counter-clockwise to create a
    /// rounded rectangle, closing the subpath.
    ///
    /// - Parameters:
    ///   - rect: A rectangle, specified in user space coordinates.
    ///   - cornerSize: The size of the corners, specified in user space
    ///     coordinates.
    ///   - style: The corner style. Defaults to the `continous` style
    ///     if not specified.
    ///   - transform: An affine transform to apply to the rectangle
    ///     before adding to the path. Defaults to the identity
    ///     transform if not specified.
    ///
    public mutating func addRoundedRect(
        in rect: CGRect,
        cornerSize: CGSize,
        style: RoundedCornerStyle = .continuous,
        transform: CGAffineTransform = .identity
    ) {
        guard !rect.isNull else { return }
        if case .empty = storage, transform.isRectilinear {
            let roundedRect = FixedRoundedRect(rect, cornerSize: cornerSize, style: style).applying(transform)
            storage = .roundedRect(roundedRect)
            return
        }
        withMutableBuffer { buffer in
            var transform = transform
            ORBPath.Storage(buffer).append(
                element: style == .circular ? .fixedRoundedRectCircular : .fixedRoundedRectContinuous,
                points: [rect.x, rect.y, rect.size.width, rect.size.height, cornerSize.width, cornerSize.height],
                userInfo: &transform
            )
        }
    }

    /// Adds a rounded rectangle with uneven corners to the path.
    ///
    /// This is a convenience function that adds a rounded rectangle to
    /// a path, starting by moving to the center of the right edge and
    /// then adding lines and curves counter-clockwise to create a
    /// rounded rectangle, closing the subpath.
    ///
    /// - Parameters:
    ///   - rect: A rectangle, specified in user space coordinates.
    ///   - cornerRadii: The radius of each corner of the rectangle,
    ///     specified in user space coordinates.
    ///   - style: The corner style. Defaults to the `continous` style
    ///     if not specified.
    ///   - transform: An affine transform to apply to the rectangle
    ///     before adding to the path. Defaults to the identity
    ///     transform if not specified.
    ///
    @available(OpenSwiftUI_v4_0, *)
    public mutating func addRoundedRect(
        in rect: CGRect,
        cornerRadii: RectangleCornerRadii,
        style: RoundedCornerStyle = .continuous,
        transform: CGAffineTransform = .identity
    ) {
        guard !rect.isNull else { return }
        withMutableBuffer { buffer in
            var transform = transform
            ORBPath.Storage(buffer).append(
                element: style == .circular ? .unevenRoundedRectCircular : .unevenRoundedRectContinuous,
                points: [
                    rect.x, rect.y, rect.size.width, rect.size.height,
                    cornerRadii.topLeft, cornerRadii.topRight,
                    cornerRadii.bottomRight, cornerRadii.bottomLeft,
                ],
                userInfo: &transform
            )
        }
    }

    /// Adds an ellipse that fits inside the specified rectangle to the
    /// path.
    ///
    /// The ellipse is approximated by a sequence of Bézier
    /// curves. Its center is the midpoint of the rectangle defined by
    /// the `rect` parameter. If the rectangle is square, then the
    /// ellipse is circular with a radius equal to one-half the width
    /// (or height) of the rectangle. If the `rect` parameter specifies
    /// a rectangular shape, then the major and minor axes of the
    /// ellipse are defined by the width and height of the rectangle.
    ///
    /// The ellipse forms a complete subpath of the path—
    /// that is, the ellipse drawing starts with a move-to operation
    /// and ends with a close-subpath operation, with all moves
    /// oriented in the clockwise direction.
    ///
    /// - Parameter:
    ///   - rect: A rectangle that defines the area for the ellipse to
    ///     fit in.
    ///   - transform: An affine transform to apply to the ellipse
    ///     before adding to the path. Defaults to the identity
    ///     transform if not specified.
    ///
    public mutating func addEllipse(
        in rect: CGRect,
        transform: CGAffineTransform = .identity
    ) {
        guard !rect.isNull else { return }
        if case .empty = storage, transform.isRectilinear {
            storage = .ellipse(rect.applying(transform))
            return
        }
        withMutableBuffer { buffer in
            var transform = transform
            ORBPath.Storage(buffer).append(
                element: .ellipse,
                points: [rect.x, rect.y, rect.size.width, rect.size.height],
                userInfo: &transform
            )
        }
    }

    /// Adds a set of rectangular subpaths to the path.
    ///
    /// Calling this convenience method is equivalent to repeatedly
    /// calling the `addRect(_:transform:)` method for each rectangle
    /// in the array.
    ///
    /// - Parameter:
    ///   - rects: An array of rectangles, specified in user space
    ///     coordinates.
    ///   - transform: An affine transform to apply to the ellipse
    ///     before adding to the path. Defaults to the identity
    ///     transform if not specified.
    ///
    public mutating func addRects(
        _ rects: [CGRect],
        transform: CGAffineTransform = .identity
    ) {
        switch rects.count {
        case 0:
            break
        case 1:
            addRect(rects[0], transform: transform)
        default:
            withMutableBuffer { buffer in
                let storage = ORBPath.Storage(buffer)
                for rect in rects {
                    var transform = transform
                    storage.append(
                        element: .rect,
                        points: [rect.x, rect.y, rect.size.width, rect.size.height],
                        userInfo: &transform
                    )
                }
            }
        }
    }

    /// Adds a sequence of connected straight-line segments to the path.
    ///
    /// Calling this convenience method is equivalent to applying the
    /// transform to all points in the array, then calling the
    /// `move(to:)` method with the first value in the `points` array,
    /// then calling the `addLine(to:)` method for each subsequent
    /// point until the array is exhausted. After calling this method,
    /// the path's current point is the last point in the array.
    ///
    /// - Parameter:
    ///   - lines: An array of values that specify the start and end
    ///     points of the line segments to draw. Each point in the
    ///     array specifies a position in user space. The first point
    ///     in the array specifies the initial starting point.
    ///   - transform: An affine transform to apply to the points
    ///     before adding to the path. Defaults to the identity
    ///     transform if not specified.
    ///
    public mutating func addLines(_ lines: [CGPoint]) {
        guard !lines.isEmpty else { return }
        withMutableBuffer { buffer in
            let storage = ORBPath.Storage(buffer)
            let start = lines[0]
            storage.append(element: .moveToPoint, points: [start.x, start.y], userInfo: nil)
            for i in 1 ..< lines.count {
                let point = lines[i]
                storage.append(element: .addLineToPoint, points: [point.x, point.y], userInfo: nil)
            }
        }
    }

    /// Adds an arc of a circle to the path, specified with a radius
    /// and a difference in angle.
    ///
    /// This method calculates starting and ending points using the
    /// radius and angles you specify, uses a sequence of cubic
    /// Bézier curves to approximate a segment of a circle
    /// between those points, and then appends those curves to the
    /// path.
    ///
    /// The `delta` parameter determines both the length of the arc the
    /// direction in which the arc is created; the actual direction of
    /// the final path is dependent on the `transform` parameter and
    /// the current transform of a context where the path is drawn.
    /// However, because OpenSwiftUI by default uses a vertically-flipped
    /// coordinate system (with the origin in the top-left of the
    /// view), specifying a clockwise arc results in a counterclockwise
    /// arc after the transformation is applied.
    ///
    /// If the path ends with an unclosed subpath, this method adds a
    /// line connecting the current point to the starting point of the
    /// arc. If there is no unclosed subpath, this method creates a new
    /// subpath whose starting point is the starting point of the arc.
    /// The ending point of the arc becomes the new current point of
    /// the path.
    ///
    /// - Parameters:
    ///   - center: The center of the arc, in user space coordinates.
    ///   - radius: The radius of the arc, in user space coordinates.
    ///   - startAngle: The angle to the starting point of the arc,
    ///     measured from the positive x-axis.
    ///   - delta: The difference between the starting angle and ending
    ///     angle of the arc. A positive value creates a counter-
    ///     clockwise arc (in user space coordinates), and vice versa.
    ///   - transform: An affine transform to apply to the arc before
    ///     adding to the path. Defaults to the identity transform if
    ///     not specified.
    ///
    public mutating func addRelativeArc(
        center: CGPoint,
        radius: CGFloat,
        startAngle: Angle,
        delta: Angle,
        transform: CGAffineTransform = .identity
    ) {
        withMutableBuffer { buffer in
            var transform = transform
            ORBPath.Storage(buffer).append(
                element: .relativeArc,
                points: [center.x, center.y, radius, CGFloat(startAngle.radians), CGFloat(delta.radians)],
                userInfo: &transform
            )
        }
    }

    /// Adds an arc of a circle to the path, specified with a radius
    /// and angles.
    ///
    /// This method calculates starting and ending points using the
    /// radius and angles you specify, uses a sequence of cubic
    /// Bézier curves to approximate a segment of a circle
    /// between those points, and then appends those curves to the
    /// path.
    ///
    /// The `clockwise` parameter determines the direction in which the
    /// arc is created; the actual direction of the final path is
    /// dependent on the `transform` parameter and the current
    /// transform of a context where the path is drawn. However,
    /// because OpenSwiftUI by default uses a vertically-flipped coordinate
    /// system (with the origin in the top-left of the view),
    /// specifying a clockwise arc results in a counterclockwise arc
    /// after the transformation is applied.
    ///
    /// If the path ends with an unclosed subpath, this method adds a
    /// line connecting the current point to the starting point of the
    /// arc. If there is no unclosed subpath, this method creates a new
    /// subpath whose starting point is the starting point of the arc.
    /// The ending point of the arc becomes the new current point of
    /// the path.
    ///
    /// - Parameters:
    ///   - center: The center of the arc, in user space coordinates.
    ///   - radius: The radius of the arc, in user space coordinates.
    ///   - startAngle: The angle to the starting point of the arc,
    ///     measured from the positive x-axis.
    ///   - endAngle: The angle to the end point of the arc, measured
    ///     from the positive x-axis.
    ///   - clockwise: true to make a clockwise arc; false to make a
    ///     counterclockwise arc.
    ///   - transform: An affine transform to apply to the arc before
    ///     adding to the path. Defaults to the identity transform if
    ///     not specified.
    ///
    public mutating func addArc(
        center: CGPoint,
        radius: CGFloat,
        startAngle: Angle,
        endAngle: Angle,
        clockwise: Bool,
        transform: CGAffineTransform = .identity
    ) {
        withMutableBuffer { buffer in
            var transform = transform
            ORBPath.Storage(buffer).append(
                element: clockwise ? .arc : .arcCounterclockwise,
                points: [center.x, center.y, radius, CGFloat(startAngle.radians), CGFloat(endAngle.radians)],
                userInfo: &transform
            )
        }
    }

    /// Adds an arc of a circle to the path, specified with a radius
    /// and two tangent lines.
    ///
    /// This method calculates two tangent lines—the first
    /// from the current point to the tangent1End point, and the second
    /// from the `tangent1End` point to the `tangent2End`
    /// point—then calculates the start and end points for a
    /// circular arc of the specified radius such that the arc is
    /// tangent to both lines. Finally, this method approximates that
    /// arc with a sequence of cubic Bézier curves and appends
    /// those curves to the path.
    ///
    /// If the starting point of the arc (that is, the point where a
    /// circle of the specified radius must meet the first tangent line
    /// in order to also be tangent to the second line) is not the
    /// current point, this method appends a straight line segment from
    /// the current point to the starting point of the arc.
    ///
    /// The ending point of the arc (that is, the point where a circle
    /// of the specified radius must meet the second tangent line in
    /// order to also be tangent to the first line) becomes the new
    /// current point of the path.
    ///
    /// - Parameters:
    ///   - tangent1End:The end point, in user space coordinates, for
    ///     the first tangent line to be used in constructing the arc.
    ///     (The start point for this tangent line is the path's
    ///     current point.)
    ///   - tangent2End: The end point, in user space coordinates, for
    ///     the second tangent line to be used in constructing the arc.
    ///     (The start point for this tangent line is the tangent1End
    ///     point.)
    ///   - radius: The radius of the arc, in user space coordinates.
    ///   - transform: An affine transform to apply to the arc before
    ///     adding to the path. Defaults to the identity transform if
    ///     not specified.
    ///
    public mutating func addArc(
        tangent1End: CGPoint,
        tangent2End: CGPoint,
        radius: CGFloat,
        transform: CGAffineTransform = .identity
    ) {
        withMutableBuffer { buffer in
            var transform = transform
            ORBPath.Storage(buffer).append(
                element: .arcTo,
                points: [tangent1End.x, tangent1End.y, tangent2End.x, tangent2End.y, radius],
                userInfo: &transform
            )
        }
    }

    /// Appends another path value to this path.
    ///
    /// If the `path` parameter is a non-empty empty path, its elements
    /// are appended in order to this path. Afterward, the start point
    /// and current point of this path are those of the last subpath in
    /// the `path` parameter.
    ///
    /// - Parameters:
    ///   - path: The path to add.
    ///   - transform: An affine transform to apply to the path
    ///     parameter before adding to this path. Defaults to the
    ///     identity transform if not specified.
    ///
    public mutating func addPath(
        _ path: Path,
        transform: CGAffineTransform = .identity
    ) {
        if case .empty = storage {
            self = path.applying(transform)
            return
        }
        guard !path.isEmpty else { return }
        withMutableBuffer { buffer in
            if transform.isIdentity {
                path.append(to: buffer)
            } else {
                let storage = ORBPath.Storage(buffer)
                var transform = transform
                storage.append(element: .transformed, points: nil, userInfo: &transform)
                path.append(to: buffer)
                storage.append(element: .end, points: nil, userInfo: nil)
            }
        }
    }

    /// Returns the last point in the path, or nil if the path contains
    /// no points.
    public var currentPoint: CGPoint? {
        switch storage {
        case let .rect(rect):
            return rect.origin
        case .empty:
            return nil
        default:
            let path = cgPath
            return path.isEmpty ? nil : path.currentPoint
        }
    }

    package func dilatedGlyphPath(with size: CGSize) -> Path {
        guard size != .zero else { return self }
        return Path(box: PathBox { buffer in
            let storage = ORBPath.Storage(buffer)
            storage.append(element: .dilateGlyph, points: [size.width, size.height], userInfo: nil)
            append(to: buffer)
            storage.append(element: .end, points: nil, userInfo: nil)
        })
    }

    /// Returns a new weakly-simple copy of this path.
    ///
    /// - Parameters:
    ///   - eoFill: Whether to use the even-odd rule for determining
    ///       which areas to treat as the interior of the paths (if true),
    ///       or the non-zero rule (if false).
    /// - Returns: A new path.
    ///
    /// The returned path is a weakly-simple path, has no
    /// self-intersections, and has a normalized orientation. The
    /// result of filling this path using either even-odd or non-zero
    /// fill rules is identical.
    @available(OpenSwiftUI_v5_0, *)
    public func normalized(eoFill: Bool = true) -> Path {
        Path(box: PathBox { buffer in
            let storage = ORBPath.Storage(buffer)
            var info = (false, eoFill)
            storage.append(element: .boolean, points: nil, userInfo: &info)
            append(to: buffer)
            storage.append(element: .end, points: nil, userInfo: nil)
        })
    }

    // FIXME: Add a enum type for op instead of op
    @inline(__always)
    private func booleanOperation(_ other: Path, eoFill: Bool, op: UInt8) -> Path {
        Path(box: PathBox { buffer in
            let storage = ORBPath.Storage(buffer)
            var info = (op, eoFill)
            storage.append(element: .boolean, points: nil, userInfo: &info)
            append(to: buffer)
            storage.append(element: .booleanSeparator, points: nil, userInfo: nil)
            other.append(to: buffer)
            storage.append(element: .end, points: nil, userInfo: nil)
        })
    }

    /// Returns a new path with filled regions common to both paths.
    ///
    /// - Parameters:
    ///   - other: The path to intersect.
    ///   - eoFill: Whether to use the even-odd rule for determining
    ///       which areas to treat as the interior of the paths (if true),
    ///       or the non-zero rule (if false).
    /// - Returns: A new path.
    ///
    /// The filled region of the resulting path is the overlapping area
    /// of the filled region of both paths.  This can be used to clip
    /// the fill of a path to a mask.
    ///
    /// Any unclosed subpaths in either path are assumed to be closed.
    /// The result of filling this path using either even-odd or
    /// non-zero fill rules is identical.
    @available(OpenSwiftUI_v5_0, *)
    public func intersection(
        _ other: Path,
        eoFill: Bool = false
    ) -> Path {
        booleanOperation(other, eoFill: eoFill, op: 1)
    }

    /// Returns a new path with filled regions in either this path or
    /// the given path.
    ///
    /// - Parameters:
    ///   - other: The path to union.
    ///   - eoFill: Whether to use the even-odd rule for determining
    ///       which areas to treat as the interior of the paths (if true),
    ///       or the non-zero rule (if false).
    /// - Returns: A new path.
    ///
    /// The filled region of resulting path is the combination of the
    /// filled region of both paths added together.
    ///
    /// Any unclosed subpaths in either path are assumed to be closed.
    /// The result of filling this path using either even-odd or
    /// non-zero fill rules is identical.
    @available(OpenSwiftUI_v5_0, *)
    public func union(
        _ other: Path,
        eoFill: Bool = false
    ) -> Path {
        booleanOperation(other, eoFill: eoFill, op: 2)
    }

    /// Returns a new path with filled regions from this path that are
    /// not in the given path.
    ///
    /// - Parameters:
    ///   - other: The path to subtract.
    ///   - eoFill: Whether to use the even-odd rule for determining
    ///       which areas to treat as the interior of the paths (if true),
    ///       or the non-zero rule (if false).
    /// - Returns: A new path.
    ///
    /// The filled region of the resulting path is the filled region of
    /// this path with the filled region `other` removed from it.
    ///
    /// Any unclosed subpaths in either path are assumed to be closed.
    /// The result of filling this path using either even-odd or
    /// non-zero fill rules is identical.
    @available(OpenSwiftUI_v5_0, *)
    public func subtracting(
        _ other: Path,
        eoFill: Bool = false
    ) -> Path {
        booleanOperation(other, eoFill: eoFill, op: 3)
    }

    /// Returns a new path with filled regions either from this path or
    /// the given path, but not in both.
    ///
    /// - Parameters:
    ///   - other: The path to difference.
    ///   - eoFill: Whether to use the even-odd rule for determining
    ///       which areas to treat as the interior of the paths (if true),
    ///       or the non-zero rule (if false).
    /// - Returns: A new path.
    ///
    /// The filled region of the resulting path is the filled region
    /// contained in either this path or `other`, but not both.
    ///
    /// Any unclosed subpaths in either path are assumed to be closed.
    /// The result of filling this path using either even-odd or
    /// non-zero fill rules is identical.
    @available(OpenSwiftUI_v5_0, *)
    public func symmetricDifference(
        _ other: Path,
        eoFill: Bool = false
    ) -> Path {
        booleanOperation(other, eoFill: eoFill, op: 4)
    }

    /// Returns a new path with a line from this path that overlaps the
    /// filled regions of the given path.
    ///
    /// - Parameters:
    ///   - other: The path to intersect.
    ///   - eoFill: Whether to use the even-odd rule for determining
    ///       which areas to treat as the interior of the paths (if true),
    ///       or the non-zero rule (if false).
    /// - Returns: A new path.
    ///
    /// The line of the resulting path is the line of this path that
    /// overlaps the filled region of `other`.
    ///
    /// Intersected subpaths that are clipped create open subpaths.
    /// Closed subpaths that do not intersect `other` remain closed.
    @available(OpenSwiftUI_v5_0, *)
    public func lineIntersection(
        _ other: Path,
        eoFill: Bool = false
    ) -> Path {
        booleanOperation(other, eoFill: eoFill, op: 5)
    }

    /// Returns a new path with a line from this path that does not
    /// overlap the filled region of the given path.
    ///
    /// - Parameters:
    ///   - other: The path to subtract.
    ///   - eoFill: Whether to use the even-odd rule for determining
    ///       which areas to treat as the interior of the paths (if true),
    ///       or the non-zero rule (if false).
    /// - Returns: A new path.
    ///
    /// The line of the resulting path is the line of this path that
    /// does not overlap the filled region of `other`.
    ///
    /// Intersected subpaths that are clipped create open subpaths.
    /// Closed subpaths that do not intersect `other` remain closed.
    @available(OpenSwiftUI_v5_0, *)
    public func lineSubtraction(
        _ other: Path,
        eoFill: Bool = false
    ) -> Path {
        booleanOperation(other, eoFill: eoFill, op: 6)
    }

    package mutating func formTrivialUnion(_ path: Path) {
        guard !path.isEmpty else {
            return
        }
        if let lhs = roundedRect(), let rhs = path.roundedRect() {
            if lhs.contains(rhs) {
                return
            }
            if rhs.contains(lhs) {
                self = path
                return
            }
        }
        addPath(path)
    }

    /// Returns a path constructed by applying the transform to all
    /// points of the path.
    ///
    /// - Parameter transform: An affine transform to apply to the path.
    ///
    /// - Returns: a new copy of the path with the transform applied to
    ///   all points.
    ///
    public func applying(_ transform: CGAffineTransform) -> Path {
        guard !transform.isIdentity else {
            return self
        }
        switch storage {
        case .empty:
            return self
        case let .rect(rect) where transform.isRectilinear:
            return Path(rect.applying(transform))
        case let .ellipse(rect) where transform.isRectilinear:
            return Path(ellipseIn: rect.applying(transform))
        case let .roundedRect(fixedRoundedRect) where transform.isRectilinear:
            return Path(storage: .roundedRect(fixedRoundedRect.applying(transform)))
        case .stroked, .trimmed:
            preconditionFailure("obsolete")
        default:
            return Path(box: PathBox { buffer in
                let storage = ORBPath.Storage(buffer)
                var transform = transform
                storage.append(element: .transformed, points: nil, userInfo: &transform)
                append(to: buffer)
                storage.append(element: .end, points: nil, userInfo: nil)
            })
        }
    }

    /// Returns a path constructed by translating all its points.
    ///
    /// - Parameters:
    ///   - dx: The offset to apply in the horizontal axis.
    ///   - dy: The offset to apply in the vertical axis.
    ///
    /// - Returns: a new copy of the path with the offset applied to
    ///   all points.
    ///
    public func offsetBy(
        dx: CGFloat,
        dy: CGFloat
    ) -> Path {
        guard dx != 0 || dy != 0 else {
            return self
        }
        return applying(CGAffineTransform(translationX: dx, y: dy))
    }

    package func mapPoints(_ body: (inout [CGPoint]) -> ()) -> Path {
        switch storage {
        case .empty:
            return Path()
        case let .rect(rect):
            var points = rect.cornerPoints
            body(&points)
            if let rect = CGRect(exactCornerPoints: points) {
                return Path(rect)
            }
            var path = Path()
            path.move(to: points[0])
            for index in 1 ..< 4 {
                path.addLine(to: points[index])
            }
            path.closeSubpath()
            return path
        case let .ellipse(rect):
            var points = rect.cornerPoints
            body(&points)
            if let mapped = CGRect(exactCornerPoints: points),
               mapped.width == rect.width,
               mapped.height == rect.height {
                return Path(ellipseIn: mapped)
            }
        case let .roundedRect(rect):
            var points = rect.rect.cornerPoints
            body(&points)
            if let mapped = CGRect(exactCornerPoints: points),
               mapped.width == rect.rect.width,
               mapped.height == rect.rect.height {
                return Path(storage: .roundedRect(FixedRoundedRect(
                    mapped,
                    cornerSize: rect.cornerSize,
                    style: rect.style
                )))
            }
        default:
            break
        }
        var points: [CGPoint] = []
        forEach { element in
            switch element {
            case let .move(point), let .line(point):
                points.append(point)
            case let .quadCurve(point, control):
                points.append(point)
                points.append(control)
            case let .curve(point, control1, control2):
                points.append(point)
                points.append(control1)
                points.append(control2)
            case .closeSubpath:
                break
            }
        }
        body(&points)
        let result = CGMutablePath()
        var index = 0
        forEach { element in
            switch element {
            case .move:
                result.move(to: points[index])
                index += 1
            case .line:
                result.addLine(to: points[index])
                index += 1
            case .quadCurve:
                result.addQuadCurve(to: points[index], control: points[index + 1])
                index += 2
            case .curve:
                result.addCurve(to: points[index], control1: points[index + 1], control2: points[index + 2])
                index += 3
            case .closeSubpath:
                result.closeSubpath()
            }
        }
        return Path(result as CGPath)
    }
}

private func ellipseContains(in rect: CGRect, contains point: CGPoint) -> Bool {
    var rect = rect
    var point = point
    if rect.width != rect.height {
        let scale = rect.height / rect.width
        rect.origin.x *= scale
        rect.size.width *= scale
        point.x *= scale
    }
    let dx = point.x - (rect.origin.x + rect.width / 2)
    let dy = point.y - (rect.origin.y + rect.height / 2)
    let radius = rect.width / 2
    return dx * dx + dy * dy < radius * radius
}

// MARK: - ORB Helper

private let temporaryPathCallbacks: UnsafePointer<ORBPath.Callbacks> = {
    let pointer = UnsafeMutablePointer<ORBPath.Callbacks>.allocate(capacity: 1)
    pointer.initialize(to: .init())
    pointer.pointee.retain = { _ in
        _openSwiftUIUnreachableCode()
    }
    pointer.pointee.release = { _ in
        _openSwiftUIUnreachableCode()
    }
    pointer.pointee.apply = { object, info, callback in
        ORBPath.Storage(object).apply(info: info, callback: callback)
    }
    pointer.pointee.isEqual = { lhs, rhs in
        ORBPath.Storage(lhs).isEqual(to: ORBPath.Storage(rhs))
    }
    pointer.pointee.isEmpty = { object in
        ORBPath.Storage(object).isEmpty
    }
    pointer.pointee.isSingleElement = { object in
        ORBPath.Storage(object).isSingleElement
    }
    pointer.pointee.boundingRect = { object in
        ORBPath.Storage(object).boundingRect
    }
    pointer.pointee.cgPath = { object in
        ORBPath.Storage(object).cgPath.map { .passUnretained($0) }
    }
    return UnsafePointer(pointer)
}()

extension ORBPath {
    static func withTemporaryPath<R>(
        do body: (ORBPath) -> R,
        builder: (UnsafeMutableRawPointer) -> Void
    ) -> R {
        withUnsafeTemporaryAllocation(of: UInt8.self, capacity: 128) { bufferPointer in
            let pointer = UnsafeMutableRawPointer(bufferPointer.baseAddress!)
            let storage = ORBPath.Storage(pointer)
            storage.initialize(capacity: bufferPointer.count, source: nil)
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

extension ORBPath.Storage {
    @inline(__always)
    init(@_nonEphemeral _ pointer: UnsafeRawPointer) {
        self.init(OpaquePointer(pointer))
    }
}
