//
//  CoreGlue.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Empty

#if canImport(Darwin)

public import Foundation
package import OpenGraphShims

@_spi(ForOpenSwiftUIOnly)
@objc(OpenSwiftUICoreGlue)
open class CoreGlue: NSObject {
    package static var shared: CoreGlue = CoreGlue() // FIXME
    
    
    open func makeDefaultLayoutComputer() -> MakeDefaultLayoutComputerResult {
        preconditionFailure("TODO")
    }
}

@_spi(ForOpenSwiftUIOnly)
extension CoreGlue {
    public struct MakeDefaultLayoutComputerResult {
        package var value: Attribute<LayoutComputer>
        
        package init(value: Attribute<LayoutComputer>) {
            self.value = value
        }
    }
}
        
#endif
