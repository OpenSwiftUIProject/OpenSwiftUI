//
//  ImageOrientation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import OpenCoreGraphicsShims

// MARK: - Image.Orientation

extension Image {
    /// The orientation of an image.
    ///
    /// Many image formats such as JPEG include orientation metadata in the
    /// image data. In other cases, you can specify image orientation
    /// in code. Properly specifying orientation is often important both for
    /// displaying the image and for certain kinds of image processing.
    ///
    /// In OpenSwiftUI, you provide an orientation value when initializing an
    /// ``Image`` from an existing
    /// [CGImage](https://developer.apple.com/documentation/coregraphics/cgimage).
    @frozen
    public enum Orientation: UInt8, CaseIterable, Hashable {
        /// A value that indicates the original pixel data matches the image's
        /// intended display orientation.
        case up = 0

        /// A value that indicates a horizontal flip of the image from the
        /// orientation of its original pixel data.
        case upMirrored = 2

        /// A value that indicates a 180° rotation of the image from the
        /// orientation of its original pixel data.
        case down = 6

        /// A value that indicates a vertical flip of the image from the
        /// orientation of its original pixel data.
        case downMirrored = 4

        /// A value that indicates a 90° counterclockwise rotation from the
        /// orientation of its original pixel data.
        case left = 1

        /// A value that indicates a 90° clockwise rotation and horizontal
        /// flip of the image from the orientation of its original pixel
        /// data.
        case leftMirrored = 3

        /// A value that indicates a 90° clockwise rotation of the image from
        /// the orientation of its original pixel data.
        case right = 7

        /// A value that indicates a 90° counterclockwise rotation and
        /// horizontal flip from the orientation of its original pixel data.
        case rightMirrored = 5

        /// Creates an image orientation from an EXIF orientation value.
        ///
        /// This initializer converts the standard EXIF orientation values (1-8)
        /// to the corresponding `Image.Orientation` cases.
        ///
        /// - Parameter exifValue: An integer representing the EXIF orientation.
        ///   Valid values are 1 through 8, corresponding to the standard EXIF
        ///   orientation values.
        /// - Returns: The corresponding orientation, or `nil` if the provided
        ///   value is not a valid EXIF orientation value.
        @_spi(Private)
        public init?(exifValue: Int) {
            switch exifValue {
            case 1: self = .up
            case 2: self = .upMirrored
            case 3: self = .down
            case 4: self = .downMirrored
            case 5: self = .leftMirrored
            case 6: self = .right
            case 7: self = .rightMirrored
            case 8: self = .left
            default: return nil
            }
        }

        @inline(__always)
        var mirrored: Orientation {
            switch self {
            case .up: .upMirrored
            case .upMirrored: .up
            case .down: .downMirrored
            case .downMirrored: .down
            case .left: .leftMirrored
            case .leftMirrored: .left
            case .right: .rightMirrored
            case .rightMirrored: .right
            }
        }

        @inline(__always)
        var isHorizontal: Bool {
            switch self {
            case .up, .upMirrored, .down, .downMirrored:
                return false
            case .left, .leftMirrored, .right, .rightMirrored:
                return true
            }
        }
    }
}

extension Image.Orientation: ProtobufEnum {}

// MARK: - CoreGraphics + Image.Orientation

extension CGSize {
    package func apply(_ orientation: Image.Orientation) -> CGSize {
        if orientation.isHorizontal {
            return CGSize(width: height, height: width)
        } else {
            return self
        }
    }

    package func unapply(_ orientation: Image.Orientation) -> CGSize {
        apply(orientation)
    }
}

extension CGRect {
    package func apply(_ orientation: Image.Orientation, in size: CGSize) -> CGRect {
        switch orientation {
        case .up:
            self
        case .upMirrored:
            CGRect(x: size.width - x - width, y: y, width: width, height: height)
        case .down:
            CGRect(x: size.width - x - width, y: size.height - y - height, width: width, height: height)
        case .downMirrored:
            CGRect(x: x, y: size.height - y - height, width: width, height: height)
        case .left:
            CGRect(x: size.height - y, y: x, width: height, height: width)
        case .leftMirrored:
            CGRect(x: y - height, y: x, width: height, height: width)
        case .right:
            CGRect(x: y - height, y: size.width - x - width, width: height, height: width)
        case .rightMirrored:
            CGRect(x: size.height - y, y: size.width - x - width, width: height, height: width)
        }
    }

    package func unapply(_ orientation: Image.Orientation, in size: CGSize) -> CGRect {
        switch orientation {
        case .up:
            self
        case .upMirrored:
            CGRect(x: size.width - x - width, y: y, width: width, height: height)
        case .down:
            CGRect(x: size.width - x - width, y: size.height - y - height, width: width, height: height)
        case .downMirrored:
            CGRect(x: x, y: size.height - y - height, width: width, height: height)
        case .left:
            CGRect(x: y, y: size.height - x, width: height, height: width)
        case .leftMirrored:
            CGRect(x: y, y: x + width, width: height, height: width)
        case .right:
            CGRect(x: size.width - y - height, y: x + width, width: height, height: width)
        case .rightMirrored:
            CGRect(x: size.width - y - height, y: size.height - x, width: height, height: width)
        }
    }
}

extension CGAffineTransform {
    package init(orientation: Image.Orientation, in size: CGSize) {
        switch orientation {
        case .up:
            self = .identity
        case .upMirrored:
            self = CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: size.width, ty: 0)
        case .down:
            self = CGAffineTransform(a: -1, b: 0, c: 0, d: -1, tx: size.width, ty: size.height)
        case .downMirrored:
            self = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
        case .left:
            self = CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: 0, ty: size.height)
        case .leftMirrored:
            self = CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0)
        case .right:
            self = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: size.width, ty: 0)
        case .rightMirrored:
            self = CGAffineTransform(a: 0, b: -1, c: -1, d: 0, tx: size.width, ty: size.height)
        }
    }

    package init(orientation: Image.Orientation, in rect: CGRect) {
        let orientationTransform = CGAffineTransform(orientation: orientation, in: rect.size)
        let translateToOrigin = CGAffineTransform(translationX: rect.x, y: rect.y)
        let translateBack = CGAffineTransform(translationX: -rect.x, y: -rect.y)
        self = translateBack.concatenating(orientationTransform).concatenating(translateToOrigin)
    }

    package mutating func apply(_ orientation: Image.Orientation, in size: CGSize) {
        guard orientation != .up else { return }
        let orientationTransform = CGAffineTransform(orientation: orientation, in: size)
        self = orientationTransform.concatenating(self)
    }

    package mutating func apply(_ orientation: Image.Orientation) {
        guard orientation != .up else { return }
        let orientationTransform = CGAffineTransform(orientation: orientation, in: CGSize(width: 1, height: 1))
        self = orientationTransform.concatenating(self)
    }
}
