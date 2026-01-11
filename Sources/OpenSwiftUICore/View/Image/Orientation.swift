//
//  Orientation.swift
//  OpenSwiftUICore

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
    }
}
