//
//  ArchivesInteractiveControlsEffect.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation
import OpenSwiftUICore

struct ArchivesInteractiveControlsEffect: RendererEffect {
    func effectValue(size: CGSize) -> DisplayList.Effect {
        .properties(.archivesInteractiveControls)
    }
}
