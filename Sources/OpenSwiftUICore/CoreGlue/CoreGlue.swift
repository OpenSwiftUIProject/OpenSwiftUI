//
//  CoreGlue.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

#if canImport(Darwin)

public import Foundation
public import CoreText
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

@_spi(ForOpenSwiftUIOnly)
@objc(OpenSwiftUICoreGlue2)
open class CoreGlue2: NSObject {
    package static var shared: CoreGlue2 = _initializeCoreGlue2() as! CoreGlue2

    open func initializeTestApp() {
        preconditionFailure("")
    }

    open func isStatusBarHidden() -> Bool? {
        preconditionFailure("")
    }

    open func configureDefaultEnvironment(_: inout EnvironmentValues) {
        preconditionFailure("")
    }

    open func makeRootView(base: AnyView, rootFocusScope: Namespace.ID) -> AnyView {
        preconditionFailure("")
    }

    open var systemDefaultDynamicTypeSize: DynamicTypeSize {
        preconditionFailure("")
    }

    open var codableAttachmentCellType: CoreGlue2.CodableAttachmentCellTypeResult {
        preconditionFailure("")
    }
    
    open func linkURL(_ parameters: LinkURLParameters) -> URL? {
        preconditionFailure("")
    }
    
    package func linkURL(at point: CGPoint, in size: CGSize, stringDrawing: ResolvedStyledText.StringDrawing) -> URL? {
        linkURL(LinkURLParameters(point: point, size: size, stringDrawing: stringDrawing))
    }

    open func transformingEquivalentAttributes(_ attributedString: AttributedString) -> AttributedString {
        preconditionFailure("")
    }

    @objc(makeSummarySymbolHostIsOn:font:foregroundColor:)
    open func makeSummarySymbolHost(isOn: Bool, font: CTFont, foregroundColor: CGColor) -> AnyObject {
        preconditionFailure("")
    }
}

extension CoreGlue2 {
    public struct CodableAttachmentCellTypeResult {
        package var value: (any ProtobufMessage.Type)?

        package init(_ value: (any ProtobufMessage.Type)?) {
            self.value = value
        }
    }

    public struct LinkURLParameters {
        package var point: CGPoint
        package var size: CGSize
        package var stringDrawing: ResolvedStyledText.StringDrawing

        package init(point: CGPoint, size: CGSize, stringDrawing: ResolvedStyledText.StringDrawing) {
            self.point = point
            self.size = size
            self.stringDrawing = stringDrawing
        }
    }
}

@available(*, unavailable)
extension CoreGlue2: Sendable {}

@available(*, unavailable)
extension CoreGlue2.CodableAttachmentCellTypeResult: Sendable {}

@available(*, unavailable)
extension CoreGlue2.LinkURLParameters: Sendable {}

#endif
