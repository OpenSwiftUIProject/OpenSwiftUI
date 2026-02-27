//
//  ArchivedView.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

// MARK: - ArchivedViewDelegate

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
public protocol ArchivedViewDelegate {
    mutating func resolveImage(uuid: UUID) throws -> Image.ResolvedUUID
}

// MARK: - AnyArchivedViewDelegate

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
open class AnyArchivedViewDelegate {
    package init() {
        _openSwiftUIEmptyStub()
    }

    @_spi(ForSwiftUIOnly)
    open func resolveImage(uuid: UUID) throws -> Image.ResolvedUUID {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension AnyArchivedViewDelegate: @unchecked Sendable {}
