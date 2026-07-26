//
//  CTCompositionLanguage.h
//  OpenSwiftUI_SPI

#pragma once

#include "OpenSwiftUIBase.h"

#if __has_include(<CoreText/CoreText.h>)
#import <CoreText/CoreText.h>
#endif

typedef OPENSWIFTUI_ENUM(uint8_t, CTCompositionLanguage) {
    kCTCompositionLanguageUnset,
    kCTCompositionLanguageNone,
    kCTCompositionLanguageJapanese,
    kCTCompositionLanguageSimplifiedChinese,
    kCTCompositionLanguageTraditionalChinese,
};

OPENSWIFTUI_EXTERN_C_BEGIN

#if __has_include(<CoreText/CoreText.h>)

CTCompositionLanguage CTParagraphStyleGetCompositionLanguageForLanguage(CFStringRef language);

#else

static inline CTCompositionLanguage CTParagraphStyleGetCompositionLanguageForLanguage(CFStringRef language) {
    return kCTCompositionLanguageUnset;
}

#endif

OPENSWIFTUI_EXTERN_C_END
