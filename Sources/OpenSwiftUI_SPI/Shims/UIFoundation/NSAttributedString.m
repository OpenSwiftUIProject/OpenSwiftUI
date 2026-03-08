//
//  NSAttributedString.m
//  OpenSwiftUI_SPI

#include "NSAttributedString.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import "../OpenSwiftUIShims.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@implementation NSAttributedString (OpenSwiftUI_SPI)

- (NSAttributedString *)_ui_attributedSubstringFromRange_openswiftui_safe_wrapper:(NSRange)range scaledByScaleFactor:(CGFloat)factor {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(NSAttributedString *, @"_ui_attributedSubstringFromRange:scaledByScaleFactor", nil, NSRange, CGFloat);
    return func(self, selector, range, factor);
}

@end

@implementation NSMutableAttributedString (OpenSwiftUI_SPI)

- (BOOL)isEmptyOrTerminatedByParagraphSeparator_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"isEmptyOrTerminatedByParagraphSeparator:scaledByScaleFactor", false);
    return func(self, selector);
}

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif

