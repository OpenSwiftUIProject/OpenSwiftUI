//
//  UIHostingViewDebugLayer.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)
import UIKit

final class UIHostingViewDebugLayer: CALayer {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    override init() {
        super.init()
    }

    override var name: String? {
        get {
            (delegate as? AnyUIHostingView)?.debugName ?? super.name
        }
        set {
            super.name = newValue
        }
    }
}
#endif
