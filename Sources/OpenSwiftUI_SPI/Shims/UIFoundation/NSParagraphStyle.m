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

- (NSTextHorizontalAlignment)horizontalAlignment_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(NSTextHorizontalAlignment, @"horizontalAlignment", NSTextHorizontalAlignmentNatural);
    return func(self, selector);
}

- (void)setHorizontalAlignment_openswiftui_safe_wrapper:(NSTextHorizontalAlignment)horizontalAlignment {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setHorizontalAlignment:", , NSTextHorizontalAlignment);
    func(self, selector, horizontalAlignment);
}

- (BOOL)spansAllLines_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"spansAllLines", NO);
    return func(self, selector);
}

- (void)setSpansAllLines_openswiftui_safe_wrapper:(BOOL)spansAllLines {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setSpansAllLines:", , BOOL);
    func(self, selector, spansAllLines);
}

- (NSLineBreakMode)secondaryLineBreakMode_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(NSLineBreakMode, @"secondaryLineBreakMode", NSLineBreakByWordWrapping);
    return func(self, selector);
}

- (void)setSecondaryLineBreakMode_openswiftui_safe_wrapper:(NSLineBreakMode)secondaryLineBreakMode {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setSecondaryLineBreakMode:", , NSLineBreakMode);
    func(self, selector, secondaryLineBreakMode);
}

@end

#endif
