//
//  BodyLabelGroupStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: BodyLabelGroupStyle

struct BodyLabelGroupStyle: LabelGroupStyle_v0 {
    func font(at level: Int) -> Font {
        switch level {
        case 0: .body
        case 1: .subheadline
        case 2: .footnote
        default: .footnote
        }
    }

    func foregroundStyle(at level: Int) -> HierarchicalShapeStyle {
        switch level {
        case 0: .primary
        case 1, 2: .secondary
        default: .tertiary
        }
    }
}
