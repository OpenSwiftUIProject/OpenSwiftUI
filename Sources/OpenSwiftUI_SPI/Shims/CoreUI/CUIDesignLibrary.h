//
//  CUIDesignLibrary.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef CUIDesignLibrary_h
#define CUIDesignLibrary_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
#import <Foundation/Foundation.h>
#include "CUIColorName.h"
#include "CUIColorScheme.h"
#include "CUIColorSchemeContrast.h"
#include "CUIDesignColor.h"
#include "CUIDesignStyling.h"
#include "CUIDisplayGamut.h"

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

typedef struct CUIDesignColorTraits {
    CUIColorName name;
    uint64_t designSystem;
    uint64_t palette;
    CUIColorScheme colorScheme;
    CUIColorSchemeContrast contrast;
    CUIDesignStyling styling;
    CUIDisplayGamut displayGamut;
} CUIDesignColorTraits;

@interface CUIDesignLibrary : NSObject

+ (nullable CUIDesignColor *)colorWithTraits:(CUIDesignColorTraits)traits error:(NSError * _Nullable * _Nullable)error;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* CUIDesignLibrary_h */
