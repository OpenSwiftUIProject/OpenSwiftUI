//
//  ImageTests.swift
//  OpenSwiftUICoreTests

#if canImport(ImageIO)
import ImageIO
#endif
@_spi(Private) import OpenSwiftUICore
import Testing

struct ImageOrientationTests {
    @Test(arguments: [
        (Image.Orientation.up, 0),
        (Image.Orientation.upMirrored, 2),
        (Image.Orientation.down, 6),
        (Image.Orientation.downMirrored, 4),
        (Image.Orientation.left, 1),
        (Image.Orientation.leftMirrored, 3),
        (Image.Orientation.right, 7),
        (Image.Orientation.rightMirrored, 5),
    ])
    func rawValue(_ orientation: Image.Orientation, _ expectedRawValue: Int) {
        #expect(orientation.rawValue == expectedRawValue)
    }

    @Test(arguments: [
        (0, Image.Orientation.up),
        (1, Image.Orientation.left),
        (2, Image.Orientation.upMirrored),
        (3, Image.Orientation.leftMirrored),
        (4, Image.Orientation.downMirrored),
        (5, Image.Orientation.rightMirrored),
        (6, Image.Orientation.down),
        (7, Image.Orientation.right),
    ])
    func initFromRawValue(_ rawValue: Int, _ expectedOrientation: Image.Orientation) {
        #expect(Image.Orientation(rawValue: UInt8(rawValue)) == expectedOrientation)
    }

    @Test(arguments: [
        (1, Image.Orientation.up),
        (2, Image.Orientation.upMirrored),
        (3, Image.Orientation.down),
        (4, Image.Orientation.downMirrored),
        (5, Image.Orientation.leftMirrored),
        (6, Image.Orientation.right),
        (7, Image.Orientation.rightMirrored),
        (8, Image.Orientation.left),
    ])
    func initFromExifValue(_ exifValue: Int, _ expectedOrientation: Image.Orientation) {
        #expect(Image.Orientation(exifValue: exifValue) == expectedOrientation)
    }

    #if canImport(ImageIO)
    @Test(arguments: [
        (CGImagePropertyOrientation.up, Image.Orientation.up),
        (CGImagePropertyOrientation.upMirrored, Image.Orientation.upMirrored),
        (CGImagePropertyOrientation.down, Image.Orientation.down),
        (CGImagePropertyOrientation.downMirrored, Image.Orientation.downMirrored),
        (CGImagePropertyOrientation.leftMirrored, Image.Orientation.leftMirrored),
        (CGImagePropertyOrientation.right, Image.Orientation.right),
        (CGImagePropertyOrientation.rightMirrored, Image.Orientation.rightMirrored),
        (CGImagePropertyOrientation.left, Image.Orientation.left),
    ])
    func initFromCGImagePropertyOrientation(
        _ cgImagePropertyOrientation: CGImagePropertyOrientation,
        _ expectedOrientation: Image.Orientation
    ) {
        let orientation = Image.Orientation(exifValue: Int(cgImagePropertyOrientation.rawValue))
        #expect(orientation == expectedOrientation)
    }
    #endif
}
