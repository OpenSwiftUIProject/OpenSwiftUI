//
//  BackdropEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package struct BackdropEffect {
    package var scale: Float

    package var color: Color.Resolved

    package var filters: [GraphicsFilter]

    #if os(visionOS)
    package var captureOnly: Bool
    #endif

    package init(
        scale: Float = 1,
        color: Color.Resolved = .black,
        filters: [GraphicsFilter] = [],
        captureOnly: Bool = false
    ) {
        self.scale = scale
        self.color = color
        self.filters = filters
        #if os(visionOS)
        self.captureOnly = captureOnly
        #endif
    }
}
