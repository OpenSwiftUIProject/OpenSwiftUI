//
//  CUIDefaultDisplayGamut.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef CUIDefaultDisplayGamut_h
#define CUIDefaultDisplayGamut_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

typedef CF_CLOSED_ENUM(uint32_t, CUIDisplayGamut) {
    CUIDisplayGamutSRGB = 0,
    CUIDisplayGamutP3 = 1,
};

CUIDisplayGamut _CUIDefaultDisplayGamut();

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* CUIDefaultDisplayGamut_h */
