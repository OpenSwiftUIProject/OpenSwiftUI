//
//  ArchivableView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by ArchivableFactory

public import Foundation
public import OpenSwiftUICore

// MARK: - _ArchivableView [WIP]

protocol _ArchivableView: Codable, View {
    func sizeThatFits(in proposedSize: _ProposedSize) -> CGSize
}

extension _ArchivableView {
    func sizeThatFits(in proposedSize: _ProposedSize) -> CGSize {
        proposedSize.fixingUnspecifiedDimensions()
    }
}
