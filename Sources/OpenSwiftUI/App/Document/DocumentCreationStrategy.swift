//
//  DocumentCreationStrategy.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

// MARK: - DocumentCreationStrategy

protocol DocumentCreationStrategy: Identifiable where ID == String {
    var id: String { get }

    #if canImport(UniformTypeIdentifiers)
    var preferredContentType: UTType? { get }
    #endif

    var newDocumentProvider: AsyncNewDocumentProvider? { get }

    #if canImport(UniformTypeIdentifiers)
    var allowedContentTypes: [UTType] { get }
    #endif
}
