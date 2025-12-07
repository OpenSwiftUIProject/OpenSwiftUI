//
//  CTCompositionLanguage.h
//  OpenSwiftUI_SPI

#pragma once

#include "OpenSwiftUIBase.h"

#if __has_include(<CoreText/CoreText.h>)

#import <CoreText/CoreText.h>
#import <CoreFoundation/CoreFoundation.h>

CF_ASSUME_NONNULL_BEGIN

typedef CF_ENUM(uint8_t, CTCompositionLanguage) {
    kCTCompositionLanguageUnset,
    kCTCompositionLanguageNone,
    kCTCompositionLanguageJapanese,
    kCTCompositionLanguageSimplifiedChinese,
    kCTCompositionLanguageTraditionalChinese,
};

CF_ASSUME_NONNULL_END

#endif /* CoreText.h */
