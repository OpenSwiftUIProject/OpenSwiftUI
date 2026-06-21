//
//  ArchivedViewHost.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by ArchiveWriter

public import Foundation
public import OpenCoreGraphicsShims
#if canImport(UniformTypeIdentifiers)
public import UniformTypeIdentifiers
#endif

#if !canImport(CoreGraphics)
public typealias CGDataConsumer = OpaquePointer
#endif

// MARK: - _ArchivedViewHostDelegate

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
public protocol _ArchivedViewHostDelegate {
    mutating func viewDataNeedsUpdate()

    mutating func failedToEncodeView(type: any Any.Type)

    mutating func filteredImage(_ image: CGImage) throws -> CGImage

    #if canImport(UniformTypeIdentifiers)
    func preferredImageType(for image: CGImage) -> UTType?
    #endif
}

// MARK: - ArchivedViewHostStates

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
public protocol ArchivedViewHostStates {
    var count: Int { get }

    mutating func updateState(at index: Int, proxy: ArchivedViewStateProxy) throws

    func auxiliaryData() throws -> Data?
}

// MARK: - ArchivedViewStateProxy [TODO]

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
public struct ArchivedViewStateProxy {
    var writer: ArchiveWriter

    package init(writer: ArchiveWriter) {
        self.writer = writer
    }

    public func addAttachment(data: Data) throws -> Int {
        // TODO: ArchiveWriter
        _openSwiftUIUnimplementedFailure()
    }

    public func addAttachment(encoder: (CGDataConsumer) throws -> Void) throws -> Int {
        // TODO: ArchiveWriter
        _openSwiftUIUnimplementedFailure()
    }
}

@_spi(Private)
@available(*, unavailable)
extension ArchivedViewStateProxy: Sendable {}

// MARK: - ArchiveWriter [FIXME]

package class ArchiveWriter {}

// MARK: - _ArchivedViewHostDelegate + Default implementation

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
extension _ArchivedViewHostDelegate {
    public mutating func failedToEncodeView(type: any Any.Type) {
        Log.externalWarning("Failed to serialize view of type: \(type)")
    }

    public mutating func filteredImage(_ image: CGImage) throws -> CGImage {
        image
    }

    #if canImport(UniformTypeIdentifiers)
    public func preferredImageType(for image: CGImage) -> UTType? {
        nil
    }
    #endif
}

// MARK: - AnyArchivedViewHost

package protocol AnyArchivedViewHost {
    func failedToEncodeView(type: any Any.Type)

    func filteredImage(_ image: CGImage) throws -> CGImage

    #if canImport(UniformTypeIdentifiers)
    var allowedImageTypes: Set<UTType> { get }

    func imageType(for image: CGImage) -> UTType?
    #endif
}

extension _DisplayList_StableIdentityMap {
    package mutating func addIDs(
        from list: DisplayList,
        root: DisplayList.StableIdentityRoot
    ) {
        list.forEachIdentity { identity, _ in
            guard let stableID = root[identity] else {
                Log.internalError("missing stable ID \(identity)")
                return
            }
            map[identity] = stableID
        }
    }
}
