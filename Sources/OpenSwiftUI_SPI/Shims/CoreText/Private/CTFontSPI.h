//
//  CTFontSPI.h
//  OpenSwiftUI_SPI
//

#pragma once

#include "OpenSwiftUIBase.h"
#include "Overlay/CoreGraphics/OpenSwiftUICoreSystem.h"

#if __has_include(<CoreText/CoreText.h>)

#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>

static inline CGFloat CoreFontGetLineHeight(OpenSwiftUICoreSystem system, NSObject *font) {
    (void)system;
    return ((CGFloat (*)(id, SEL))objc_msgSend)(font, @selector(lineHeight));
}

static inline CGFloat CoreFontGetLeading(OpenSwiftUICoreSystem system, NSObject *font) {
    (void)system;
    return CTFontGetLeading((__bridge CTFontRef)font);
}

#endif /* CoreText.h */
