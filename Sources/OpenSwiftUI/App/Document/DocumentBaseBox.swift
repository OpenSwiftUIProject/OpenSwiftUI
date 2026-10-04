//
//  DocumentBaseBox.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - DocumentBaseBox

protocol DocumentBaseBox: AnyObject {
    associatedtype Document

    var base: Document? { get set }
}
