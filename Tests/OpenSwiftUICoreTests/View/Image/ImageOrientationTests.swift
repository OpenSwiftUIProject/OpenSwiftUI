//
//  ImageOrientationTests.swift
//  OpenSwiftUICoreTests

#if canImport(ImageIO)
import ImageIO
#endif
import OpenCoreGraphicsShims
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

// MARK: - CGSizeOrientationTests

struct CGSizeOrientationTests {
    private static let input: CGSize = CGSize(width: 100, height: 200)

    private static let reverse: CGSize = CGSize(width: 200, height: 100)

    @Test(arguments: [
       (Image.Orientation.up, input, input),
       (Image.Orientation.upMirrored, input, input),
       (Image.Orientation.down, input, input),
       (Image.Orientation.downMirrored, input, input),
       (Image.Orientation.left, input, reverse),
       (Image.Orientation.leftMirrored, input, reverse),
       (Image.Orientation.rightMirrored, input, reverse),
       (Image.Orientation.right, input, reverse),
    ])
    func apply(_ orientation: Image.Orientation, _ origin: CGSize, _ expected: CGSize) {
        let result = origin.apply(orientation)
        #expect(result == expected)
        #expect(result.unapply(orientation) == origin)
    }
}

// MARK: - CGRectOrientationTests

struct CGRectOrientationTests {
    private static let input: CGRect = CGRect(x: 10, y: 20, width: 100, height: 200)
    private static let size: CGSize = CGSize(width: 300, height: 400)

    @Test(arguments: [
        (Image.Orientation.up, input, size, CGRect(x: 10, y: 20, width: 100, height: 200)),
        (Image.Orientation.upMirrored, input, size, CGRect(x: 190, y: 20, width: 100, height: 200)),
        (Image.Orientation.down, input, size, CGRect(x: 190, y: 180, width: 100, height: 200)),
        (Image.Orientation.downMirrored, input, size, CGRect(x: 10, y: 180, width: 100, height: 200)),
        (Image.Orientation.left, input, size, CGRect(x: 380, y: 10, width: 200, height: 100)),
        (Image.Orientation.leftMirrored, input, size, CGRect(x: -180, y: 10, width: 200, height: 100)),
        (Image.Orientation.right, input, size, CGRect(x: -180, y: 190, width: 200, height: 100)),
        (Image.Orientation.rightMirrored, input, size, CGRect(x: 380, y: 190, width: 200, height: 100)),
    ])
    func apply(_ orientation: Image.Orientation, _ origin: CGRect, _ size: CGSize, _ expected: CGRect) {
        let result = origin.apply(orientation, in: size)
        #expect(result == expected)
        #expect(result.unapply(orientation, in: size) == origin)
    }
}

// MARK: - CGAffineTransformOrientationTests

struct CGAffineTransformOrientationTests {
    private static let input: CGAffineTransform = CGAffineTransform(a: 2, b: 0.5, c: 0.5, d: 2, tx: 10, ty: 20)
    private static let size: CGSize = CGSize(width: 100, height: 200)
    private static let rect: CGRect = CGRect(x: 10, y: 20, width: 100, height: 200)

    @Test(arguments: [
        (Image.Orientation.up, size, CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)),
        (Image.Orientation.upMirrored, size, CGAffineTransform(a: -1.0, b: -0.0, c: 0.0, d: 1.0, tx: 100.0, ty: 0.0)),
        (Image.Orientation.down, size, CGAffineTransform(a: -1.0, b: -0.0, c: -0.0, d: -1.0, tx: 100.0, ty: 200.0)),
        (Image.Orientation.downMirrored, size, CGAffineTransform(a: 1.0, b: 0.0, c: -0.0, d: -1.0, tx: 0.0, ty: 200.0)),
        (Image.Orientation.left, size, CGAffineTransform(a: -0.0, b: -1.0, c: 1.0, d: 0.0, tx: 0.0, ty: 200.0)),
        (Image.Orientation.leftMirrored, size, CGAffineTransform(a: 0.0, b: 1.0, c: 1.0, d: 0.0, tx: 0.0, ty: 0.0)),
        (Image.Orientation.right, size, CGAffineTransform(a: 0.0, b: 1.0, c: -1.0, d: -0.0, tx: 100.0, ty: 0.0)),
        (Image.Orientation.rightMirrored, size, CGAffineTransform(a: -0.0, b: -1.0, c: -1.0, d: -0.0, tx: 100.0, ty: 200.0)),
    ])
    func initWithOrientationInSize(_ orientation: Image.Orientation, _ size: CGSize, _ expected: CGAffineTransform) {
        let result = CGAffineTransform(orientation: orientation, in: size)
        #expect(result == expected)
    }

    @Test(arguments: [
        (Image.Orientation.up, rect, CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0)),
        (Image.Orientation.upMirrored, rect, CGAffineTransform(a: -1.0, b: 0.0, c: 0.0, d: 1.0, tx: 120.0, ty: 0.0)),
        (Image.Orientation.down, rect, CGAffineTransform(a: -1.0, b: -0.0, c: -0.0, d: -1.0, tx: 120.0, ty: 240.0)),
        (Image.Orientation.downMirrored, rect, CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -1.0, tx: 0.0, ty: 240.0)),
        (Image.Orientation.left, rect, CGAffineTransform(a: 0.0, b: -1.0, c: 1.0, d: 0.0, tx: -10.0, ty: 230.0)),
        (Image.Orientation.leftMirrored, rect, CGAffineTransform(a: 0.0, b: 1.0, c: 1.0, d: 0.0, tx: -10.0, ty: 10.0)),
        (Image.Orientation.right, rect, CGAffineTransform(a: 0.0, b: 1.0, c: -1.0, d: 0.0, tx: 130.0, ty: 10.0)),
        (Image.Orientation.rightMirrored, rect, CGAffineTransform(a: -0.0, b: -1.0, c: -1.0, d: -0.0, tx: 130.0, ty: 230.0)),
    ])
    func initWithOrientationInRect(_ orientation: Image.Orientation, _ rect: CGRect, _ expected: CGAffineTransform) {
        let result = CGAffineTransform(orientation: orientation, in: rect)
        #expect(result == expected)
    }

    @Test(arguments: [
        (Image.Orientation.up, input, size, CGAffineTransform(a: 2.0, b: 0.5, c: 0.5, d: 2.0, tx: 10.0, ty: 20.0)),
        (Image.Orientation.upMirrored, input, size, CGAffineTransform(a: -2.0, b: -0.5, c: 0.5, d: 2.0, tx: 210.0, ty: 70.0)),
        (Image.Orientation.down, input, size, CGAffineTransform(a: -2.0, b: -0.5, c: -0.5, d: -2.0, tx: 310.0, ty: 470.0)),
        (Image.Orientation.downMirrored, input, size, CGAffineTransform(a: 2.0, b: 0.5, c: -0.5, d: -2.0, tx: 110.0, ty: 420.0)),
        (Image.Orientation.left, input, size, CGAffineTransform(a: -0.5, b: -2.0, c: 2.0, d: 0.5, tx: 110.0, ty: 420.0)),
        (Image.Orientation.leftMirrored, input, size, CGAffineTransform(a: 0.5, b: 2.0, c: 2.0, d: 0.5, tx: 10.0, ty: 20.0)),
        (Image.Orientation.right, input, size, CGAffineTransform(a: 0.5, b: 2.0, c: -2.0, d: -0.5, tx: 210.0, ty: 70.0)),
        (Image.Orientation.rightMirrored, input, size, CGAffineTransform(a: -0.5, b: -2.0, c: -2.0, d: -0.5, tx: 310.0, ty: 470.0)),
    ])
    func applyWithSize(_ orientation: Image.Orientation, _ origin: CGAffineTransform, _ size: CGSize, _ expected: CGAffineTransform) {
        var result = origin
        result.apply(orientation, in: size)
        #expect(result == expected)
    }

    @Test(arguments: [
        (Image.Orientation.up, input, CGAffineTransform(a: 2.0, b: 0.5, c: 0.5, d: 2.0, tx: 10.0, ty: 20.0)),
        (Image.Orientation.upMirrored, input, CGAffineTransform(a: -2.0, b: -0.5, c: 0.5, d: 2.0, tx: 12.0, ty: 20.5)),
        (Image.Orientation.down, input, CGAffineTransform(a: -2.0, b: -0.5, c: -0.5, d: -2.0, tx: 12.5, ty: 22.5)),
        (Image.Orientation.downMirrored, input, CGAffineTransform(a: 2.0, b: 0.5, c: -0.5, d: -2.0, tx: 10.5, ty: 22.0)),
        (Image.Orientation.left, input, CGAffineTransform(a: -0.5, b: -2.0, c: 2.0, d: 0.5, tx: 10.5, ty: 22.0)),
        (Image.Orientation.leftMirrored, input, CGAffineTransform(a: 0.5, b: 2.0, c: 2.0, d: 0.5, tx: 10.0, ty: 20.0)),
        (Image.Orientation.right, input, CGAffineTransform(a: 0.5, b: 2.0, c: -2.0, d: -0.5, tx: 12.0, ty: 20.5)),
        (Image.Orientation.rightMirrored, input, CGAffineTransform(a: -0.5, b: -2.0, c: -2.0, d: -0.5, tx: 12.5, ty: 22.5)),
    ])
    func apply(_ orientation: Image.Orientation, _ origin: CGAffineTransform, _ expected: CGAffineTransform) {
        var result = origin
        result.apply(orientation)
        #expect(result == expected)
    }
}
