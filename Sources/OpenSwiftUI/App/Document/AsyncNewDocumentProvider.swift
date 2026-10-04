//
//  AsyncNewDocumentProvider.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - AsyncNewDocumentProvider

struct AsyncNewDocumentProvider {
    var provider: (inout any DocumentBaseBox) async throws -> Void
}
