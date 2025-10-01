//
//  BackdropEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: WIP

package struct BackdropEffect {
    package var scale: Float

    package var color: Color.Resolved

    package var filters: [GraphicsFilter]

    package init(scale: Float = 1, color: Color.Resolved = .black, filters: [GraphicsFilter] = [], captureOnly: Bool = false) {
        self.scale = scale
        self.color = color
        self.filters = filters
    }
}
