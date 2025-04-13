//
//  CUIColorSchemeContrast.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef CUIColorSchemeContrast_h
#define CUIColorSchemeContrast_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

typedef OPENSWIFTUI_CLOSED_ENUM(uint32_t, CUIColorSchemeContrast) {
    CUIColorSchemeContrastStandard,
    CUIColorSchemeContrastIncreased,
};

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* CUIColorSchemeContrast_h */
