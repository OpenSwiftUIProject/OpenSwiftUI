//
//  AccessibilityCore.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation
import OpenSwiftUI_SPI

// MARK: - AccessibilityCore

package enum AccessibilityCore {}

// MARK: - _ViewInputs/_GraphInputs + needsAccessibility

extension _GraphInputs {
    package var needsAccessibility: Bool {
        get { options.contains(.needsAccessibility) }
        set { options.setValue(newValue, for: .needsAccessibility) }
    }
}

extension _ViewInputs {
    package var needsAccessibility: Bool {
        get { base.needsAccessibility }
        set { base.needsAccessibility = newValue }
    }
}

// MARK: - WithinAccessibilityRotor

package struct WithinAccessibilityRotor: ViewInputBoolFlag {
    package init() {
        _openSwiftUIEmptyStub()
    }
}

extension _ViewInputs {
    @inline(__always)
    package var withinAccessibilityRotor: Bool {
        get { self[WithinAccessibilityRotor.self] }
        set { self[WithinAccessibilityRotor.self] = newValue }
    }
}

// MARK: - PlatformAccessibilityElementProtocol

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
#if canImport(ObjectiveC)
@objc
#endif
public protocol PlatformAccessibilityElementProtocol: NSObjectProtocol {
    #if os(macOS)
    @objc dynamic var knownRepresentedElement: PlatformAccessibilityElement { get }
    @objc dynamic var rotorOwnerElement: PlatformAccessibilityElement { get }
    #endif
}

// MARK: - PlatformAccessibilityElement

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public typealias PlatformAccessibilityElement = NSObject & PlatformAccessibilityElementProtocol

// MARK: - NSObject + PlatformAccessibilityElementProtocol

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
extension NSObject: PlatformAccessibilityElementProtocol {
    #if canImport(ObjectiveC)
    @objc
    #endif
    dynamic open var knownRepresentedElement: PlatformAccessibilityElement {
        self
    }

    #if canImport(ObjectiveC)
    @objc
    #endif
    dynamic open var rotorOwnerElement: PlatformAccessibilityElement {
        self
    }
}

// MARK: - AccessibilityLayoutRole

package enum AccessibilityLayoutRole: Hashable {
    case stack
    case grid
}

// MARK: - Locale.bcp47LanguageCode

extension Locale {
    package var bcp47LanguageCode: String? {
        guard let languageCode = language.languageCode?.identifier,
              !languageCode.isEmpty else {
            return nil
        }
        return language.maximalIdentifier
    }
}

// MARK: - AccessibilityCore + description

extension AccessibilityCore {
    package static func description(
        for symbolName: String,
        in environment: EnvironmentValues
    ) -> String? {
        #if canImport(Darwin)
        let description = soft_AXSSAccessibilityDescriptionForSymbolName(
            symbolName,
            environment.locale.identifier
        )
        guard !description.isEmpty else {
            return nil
        }
        return description.capitalized(with: environment.locale)
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}
