//
//  ArchiveData.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP
//  ID: 60F474399ADB3D48C6ACBFA0577E0FFE

#if canImport(Darwin)
import Foundation
import os

// MARK: - ArchiveWriter

package class ArchiveWriter {
    package static let writerKey = CodingUserInfoKey(rawValue: "org.OpenSwiftUIProject.OpenSwiftUI.ArchiveWriter")
    
    var isFinal: Bool = false
    var attachments: [(offset: UInt64, size: UInt64)] = []
    var attachmentHashes: [StrongHash] = []
    var currentOffset: UInt64 = 0
    var currentHasher: StrongHasher? = nil
    var cache: [AnyHashable: Int] = [:]
    private let signposter: OSSignposter = Signpost.archiving
    
    package init() {}
    
    package func finalize() throws {
        guard !isFinal else { return }
        
        // TODO
        
        isFinal = true
    }
    
    package func append(_ data: Data) throws {
        fatalError("abstract")
    }
    
    package func append<T>(_ buffer: UnsafeBufferPointer<T>) throws {
        fatalError("abstract")
    }
    
    fileprivate func rewind() throws {
        fatalError("abstract")
    }
    
    final package func addAttachment(hash: StrongHash? = nil, from content: (ArchiveWriter) throws -> Void) throws -> Int {
//        let state = OSSignpostIntervalState.beginState(id: signposter.makeSignpostID())
//        signposter.endInterval("", state)
        
        fatalError("TODO")
    }

    final package func addAttachment(data: Data) throws -> Int {
        fatalError("TODO")
    }

//    @objc deinit
}

final package class FileArchiveWriter: ArchiveWriter {
    private let file: FileHandle
    
    package init(file: FileHandle) {
        self.file = file
        super.init()
    }
    
    convenience package init(url: URL) throws {
        var cString = url.path.utf8CString
        let descriptor = open(
            &cString[0],
            O_WRONLY | O_CREAT | O_TRUNC /* 0x601 */,
            0666 /* 0x1b6 */
        )
        guard descriptor >= 0 else {
            throw Error.unableToOpen
        }
        let file = FileHandle(fileDescriptor: descriptor, closeOnDealloc: true)
        self.init(file: file)
    }
    
//  final package func finalize() throws
//  final package func append(_ data: Foundation.Data) throws
//  #if compiler(>=5.3) && $NoncopyableGenerics
//  final package func append<T>(_ buffer: Swift.UnsafeBufferPointer<T>) throws
//  #else
//  final package func append<T>(_ buffer: Swift.UnsafeBufferPointer<T>) throws
//  #endif
//  final package func rewind(to offset: Swift.UInt64) throws
//  @objc deinit
}

private enum Error: Swift.Error {
    case ioError(Int)
    case unableToOpen
    case invalidSize
    case invalidMagic
    case invalidCount
    case invalidAttachment
    case readFailed
}

//@_inheritsConvenienceInitializers final package class DataArchiveWriter : SwiftUICore.ArchiveWriter {
//  final package func finalizeData() throws -> Foundation.Data
//  final package func append(_ data: Foundation.Data) throws
//  #if compiler(>=5.3) && $NoncopyableGenerics
//  final package func append<T>(_ buffer: Swift.UnsafeBufferPointer<T>) throws
//  #else
//  final package func append<T>(_ buffer: Swift.UnsafeBufferPointer<T>) throws
//  #endif
//  final package func rewind(to offset: Swift.UInt64) throws
//  package init()
//  @objc deinit
//}

// MARK: - ArchiveReader




#endif
