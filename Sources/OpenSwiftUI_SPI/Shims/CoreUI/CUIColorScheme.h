//
//  CUIColorScheme.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef CUIColorScheme_h
#define CUIColorScheme_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

typedef OPENSWIFTUI_CLOSED_ENUM(uint32_t, CUIColorScheme) {
    CUIColorSchemeLight,
    CUIColorSchemeDark,
};

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* CUIColorScheme_h */
