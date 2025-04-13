//
//  CUIDesignStyling.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef CUIDesignStyling_h
#define CUIDesignStyling_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

typedef OPENSWIFTUI_CLOSED_ENUM(uint64_t, CUIDesignStyling) {
    CUIDesignStyling_0 = 0,
    CUIDesignStyling_1 = 1,
    CUIDesignStyling_2 = 2,
};

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* CUIDesignStyling_h */
