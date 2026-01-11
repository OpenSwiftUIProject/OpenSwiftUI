//
//  RenderBoxFix.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_ANY_ATTRIBUTE_FIX
package import OpenRenderBoxShims

// This is a workaround to partially "fix" the Swift compiler bug on non-Darwin platforms for swift_new_type.
// "Fix" here means we do not have to write #if canImport(Darwin) everywhere.
// See #39 for more details.

package struct ORBColorMode: RawRepresentable {
    package var rawValue: Int32

    package init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    package var workingColorSpace: ORBColor.ColorSpace {
        _openSwiftUIUnreachableCode()
    }
}

extension ORBColor {
    package typealias Mode = ORBColorMode
}

#endif
