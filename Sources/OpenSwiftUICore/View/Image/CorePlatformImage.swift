//
//  CorePlatformImage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if canImport(Darwin)
import Foundation
package import OpenSwiftUI_SPI

@objc(OpenSwiftUICorePlatformImage)
package final class CorePlatformImage: NSObject {
    package var system: CoreSystem
    package var kitImage: NSObject
    package var isTemplate: Bool
    
    package init(system: CoreSystem, kitImage: NSObject) {
        self.system = system
        self.kitImage = kitImage
        self.isTemplate = _CorePlatformImageIsTemplate(system: system, kitImage: kitImage)
        super.init()
    }
    
    convenience package init(system: CoreSystem, cgImage: CGImage, scale: CGFloat, orientation: UInt8){
        self.init(
            system: system,
            kitImage: _CorePlatformImageMakeKitImage(system: system, cgImage: cgImage, scale: scale, orientation: orientation)
        )
    }
    
    package var cgImage: CGImage? {
        _CorePlatformImageGetCGImage(system: system, kitImage: kitImage)
    }
    
    package var size: CGSize {
        _CorePlatformImageGetSize(system: system, kitImage: kitImage)
    }
    
    package var scale: CGFloat {
        _CorePlatformImageGetScale(system: system, kitImage: kitImage)
    }
    
    package var imageOrientation: UInt8 {
        _CorePlatformImageGetImageOrientation(system: system, kitImage: kitImage)
    }
    
    package var baselineOffsetFromBottom: CGFloat {
        _CorePlatformImageGetBaselineOffsetFromBottom(system: system, kitImage: kitImage)
    }
    
    package var alignmentRect: CGRect {
        get { _CorePlatformImageGetAlignmentRect(system: system, kitImage: kitImage) }
        set { _CorePlatformImageSetAlignmentRect(system: system, kitImage: kitImage, newValue) }
    }
}
#endif
