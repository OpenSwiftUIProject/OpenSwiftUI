//
//  NSParagraphStyle.m
//  OpenSwiftUI_SPI


#include "NSParagraphStyle.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import "../OpenSwiftUIShims.h"
#import <objc/runtime.h>

@implementation NSMutableParagraphStyle (OpenSwiftUI_SPI)

- (NSCompositionLanguage)compositionLanguage_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(NSCompositionLanguage, @"compositionLanguage", NSCompositionLanguageUnset);
    return func(self, selector);
}

- (void)setCompositionLanguage_openswiftui_safe_wrapper:(NSCompositionLanguage)compositionLanguage {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setCompositionLanguage:", , NSCompositionLanguage);
    func(self, selector, compositionLanguage);
}

- (BOOL)fullyJustified_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"fullyJustified", NO);
    return func(self, selector);
}

- (void)setFullyJustified_openswiftui_safe_wrapper:(BOOL)fullyJustified {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setFullyJustified:", , BOOL);
    func(self, selector, fullyJustified);
}

@end

#endif
