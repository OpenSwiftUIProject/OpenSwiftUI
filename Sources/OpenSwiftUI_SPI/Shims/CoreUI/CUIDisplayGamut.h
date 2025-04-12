//
//  CUIDisplayGamut.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef CUIDisplayGamut_h
#define CUIDisplayGamut_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

typedef OPENSWIFTUI_CLOSED_ENUM(uint32_t, CUIDisplayGamut) {
    CUIDisplayGamutSRGB = 0,
    CUIDisplayGamutP3 = 1,
};

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* CUIDisplayGamut_h */
