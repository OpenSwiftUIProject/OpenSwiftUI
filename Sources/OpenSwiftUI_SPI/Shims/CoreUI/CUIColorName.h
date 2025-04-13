//
//  CUIColorName.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: WIP

#ifndef CUIColorName_h
#define CUIColorName_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

// TOOD: 29 cases
typedef OPENSWIFTUI_CLOSED_ENUM(uint64_t, CUIColorName) {
    CUIColorNameRed = 0,
    CUIColorNameOrange = 1,
    CUIColorNameYellow = 2,
    CUIColorNameGreen = 3,
    CUIColorNameTeal = 4,
    CUIColorNameMint = 5,
    CUIColorNameCyan = 6,
    CUIColorNameBlue = 7,
    CUIColorNameIndigo = 8,
    CUIColorNamePurple = 9,
    CUIColorNamePink = 10,
    CUIColorNameGray = 13,
    CUIColorNameBrown = 14,
    CUIColorNamePrimary = 15,
    CUIColorNameSecondary = 16,
    CUIColorNameTertiary = 17,
    CUIColorNameQuaternary = 18,
    CUIColorNameQuinary = 19
};

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* CUIColorName_h */
