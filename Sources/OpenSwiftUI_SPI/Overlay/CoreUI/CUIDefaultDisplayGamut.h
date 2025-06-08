//
//  CUIDefaultDisplayGamut.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef CUIDefaultDisplayGamut_h
#define CUIDefaultDisplayGamut_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN && OPENSWIFTUI_LINK_COREUI

#include <CoreUI/CUIDisplayGamut.h>

OPENSWIFTUI_EXPORT
CUIDisplayGamut _CUIDefaultDisplayGamut();

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN && OPENSWIFTUI_LINK_COREUI */

#endif /* CUIDefaultDisplayGamut_h */
