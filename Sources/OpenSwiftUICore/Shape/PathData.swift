//
//  PathData.swift
//  OpenSwiftUICore

#if !OPENSWIFTUI_CF_CGTYPES

package import OpenCoreGraphicsShims
package import OpenRenderBoxShims

// MARK: - PathData

/// A union-like structure matching the C PathData union layout.
/// Size: 0x60 (96) bytes to match the buffer size.
///
/// C definition:
///
///     typedef union PathData {
///         CGPathRef cgPath;    // 8 bytes (pointer)
///         ORBPath rbPath;      // 16 bytes (2 pointers)
///         uint8_t buffer[0x60]; // 96 bytes
///     } PathData;
package struct PathData {
    // 96 bytes of raw storage (0x60)
    package typealias Buffer = (
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
        UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
    )

    private var storage: Buffer = (
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
    )

    package init() {}

    // MARK: - CGPath access

    package init(cgPath: Unmanaged<CGPath>) {
        self.cgPath = cgPath
    }

    package var cgPath: Unmanaged<CGPath> {
        get {
            withUnsafeBytes(of: storage) { buffer in
                buffer.load(as: Unmanaged<CGPath>.self)
            }
        }
        set {
            withUnsafeMutableBytes(of: &storage) { buffer in
                buffer.storeBytes(of: newValue, as: Unmanaged<CGPath>.self)
            }
        }
    }

    // MARK: - ORBPath access

    package init(rbPath: ORBPath) {
        self.rbPath = rbPath
    }

    package var rbPath: ORBPath {
        get {
            withUnsafeBytes(of: storage) { buffer in
                buffer.load(as: ORBPath.self)
            }
        }
        set {
            withUnsafeMutableBytes(of: &storage) { buffer in
                buffer.storeBytes(of: newValue, as: ORBPath.self)
            }
        }
    }

    // MARK: - Buffer access

    package init(buffer: Buffer) {
        self.storage = buffer
    }

    package var buffer: Buffer {
        get { storage }
        set { storage = newValue }
    }
}

#endif
