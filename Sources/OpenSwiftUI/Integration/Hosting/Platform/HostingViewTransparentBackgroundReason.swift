//
//  HostingViewTransparentBackgroundReason.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: Complete

struct HostingViewTransparentBackgroundReason: OptionSet, CustomStringConvertible {
    var rawValue: UInt32
    
    static var catalystSidebar = HostingViewTransparentBackgroundReason(rawValue: 1 << 0)
    static var catalystPresentation = HostingViewTransparentBackgroundReason(rawValue: 1 << 1)
    static var legacyPresentationSPI = HostingViewTransparentBackgroundReason(rawValue: 1 << 2)
    static var containerBackground = HostingViewTransparentBackgroundReason(rawValue: 1 << 3)
    static var listItemBackground = HostingViewTransparentBackgroundReason(rawValue: 1 << 4)
    
    var description: String {
        var description = ""
        if contains(.catalystSidebar) {
            description.append("catalystSidebar, ")
        }
        if contains(.catalystPresentation) {
            description.append("catalystPresentation, ")
        }
        if contains(.legacyPresentationSPI) {
            description.append("legacyPresentationSPI, ")
        }
        if contains(.containerBackground) {
            description.append("containerBackground, ")
        }
        if contains(.listItemBackground) {
            description.append("listItemBackground, ")
        }
        if !description.isEmpty {
            description.removeLast(2)
        }
        return "[\(description)]"
    }
}
