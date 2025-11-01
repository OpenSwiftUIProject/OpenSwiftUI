//
//  NSAttributedString.h
//  OpenSwiftUI_SPI

#ifndef OpenSwiftUI_SPI_NSAttributedString_h
#define OpenSwiftUI_SPI_NSAttributedString_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
// FIXME: OpenSwiftUI_SPI currently will expose UIKit & AppKit which will conflict the following declaration
#else
// This defines currently supported values for NSUnderlineStyleAttributeName and NSStrikethroughStyleAttributeName. These values are or'ed together to produce an underline style.
// Underlines will be drawn with a solid pattern by default, so NSUnderlineStylePatternSolid does not need to be specified.
typedef OPENSWIFTUI_OPTIONS(NSInteger, NSUnderlineStyle) {
    NSUnderlineStyleNone                                    = 0x00,
    NSUnderlineStyleSingle                                  = 0x01,
    NSUnderlineStyleThick API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))      = 0x02,
    NSUnderlineStyleDouble API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))     = 0x09,

    NSUnderlineStylePatternSolid API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))      = 0x0000,
    NSUnderlineStylePatternDot API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))        = 0x0100,
    NSUnderlineStylePatternDash API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))       = 0x0200,
    NSUnderlineStylePatternDashDot API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))    = 0x0300,
    NSUnderlineStylePatternDashDotDot API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0)) = 0x0400,

    NSUnderlineStyleByWord API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))            = 0x8000
} API_AVAILABLE(macos(10.0), ios(6.0), tvos(9.0), watchos(2.0), visionos(1.0));

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* OpenSwiftUI_SPI_NSAttributedString_h */
