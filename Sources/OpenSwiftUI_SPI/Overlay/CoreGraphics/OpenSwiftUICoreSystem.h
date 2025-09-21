//
//  OpenSwiftUICoreSystem.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef OpenSwiftUICoreSystem_h
#define OpenSwiftUICoreSystem_h

#include "OpenSwiftUIBase.h"

typedef OPENSWIFTUI_ENUM(uint8_t, OpenSwiftUICoreSystem) {
    /// UIKit based system (iOS, visionOS, Mac Catalyst)
    OpenSwiftUICoreSystemUIKit,

    /// AppKit based system (macOS)
    OpenSwiftUICoreSystemAppKit,

    /// Placeholder for unsupported platforms (eg. Linux)
    OpenSwiftUICoreSystemUnknown,
} OPENSWIFTUI_SWIFT_NAME(CoreSystem);

#endif /* OpenSwiftUICoreSystem_h */
