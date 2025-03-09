//
//  CoreGlue.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Empty

#if canImport(Darwin)

public import Foundation
package import OpenGraphShims
import OpenSwiftUI_SPI

@_spi(ForOpenSwiftUIOnly)
@objc(OpenSwiftUICoreGlue)
open class CoreGlue: NSObject {
    package static var shared: CoreGlue = _initializeCoreGlue() as! CoreGlue

    open var defaultImplicitRootType: DefaultImplicitRootTypeResult {
        preconditionFailure("")
    }

    open func makeDefaultLayoutComputer() -> MakeDefaultLayoutComputerResult {
        preconditionFailure("")
    }
}

@_spi(ForOpenSwiftUIOnly)
extension CoreGlue {
    public struct DefaultImplicitRootTypeResult {
        package var value: any _VariadicView.AnyImplicitRoot.Type

        package init(_ value: any _VariadicView.AnyImplicitRoot.Type) {
            self.value = value
        }
    }

    public struct MakeDefaultLayoutComputerResult {
        package var value: Attribute<LayoutComputer>
        
        package init(value: Attribute<LayoutComputer>) {
            self.value = value
        }
    }
}
        
#endif
