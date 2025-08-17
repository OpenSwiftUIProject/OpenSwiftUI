//
//  CoreTextSPI.h
//  OpenSwiftUI_SPI

#pragma once

#include "OpenSwiftUIBase.h"

#if __has_include(<CoreText/CoreText.h>)

#include <CoreFoundation/CoreFoundation.h>
#include <CoreText/CoreText.h>

CF_EXTERN_C_BEGIN

CF_ASSUME_NONNULL_BEGIN

CF_IMPLICIT_BRIDGING_ENABLED

typedef CF_OPTIONS(uint32_t, CTFontDescriptorOptions) {
    kCTFontDescriptorOptionSystemUIFont = 1 << 1,
    kCTFontDescriptorOptionPreferAppleSystemFont = kCTFontOptionsPreferSystemFont
};

CTFontDescriptorRef CTFontDescriptorCreateWithAttributesAndOptions(CFDictionaryRef attributes, CTFontDescriptorOptions);

CF_IMPLICIT_BRIDGING_DISABLED

CF_ASSUME_NONNULL_END

CF_EXTERN_C_END

#endif /* CoreText.h */
