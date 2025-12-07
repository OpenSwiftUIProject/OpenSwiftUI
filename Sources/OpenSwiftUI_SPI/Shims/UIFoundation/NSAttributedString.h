//
//  NSAttributedString.h
//  OpenSwiftUI_SPI

#pragma once

#include "OpenSwiftUIBase.h"

typedef long NSInteger;

// This defines currently supported values for NSUnderlineStyleAttributeName and NSStrikethroughStyleAttributeName. These values are or'ed together to produce an underline style.
// Underlines will be drawn with a solid pattern by default, so NSUnderlineStylePatternSolid does not need to be specified.
typedef OPENSWIFTUI_OPTIONS(NSInteger, NSUnderlineStyle) {
    NSUnderlineStyleNone                                    = 0x00,
    NSUnderlineStyleSingle                                  = 0x01,
    NSUnderlineStyleThick API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))      = 0x02,
    NSUnderlineStyleDouble API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))     = 0x09,

    NSUnderlineStylePatternSolid API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))      = 0x0000,
    NSUnderlineStylePatternDot API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))        = 0x0100,
    NSUnderlineStylePatternDash API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))       = 0x0200,
    NSUnderlineStylePatternDashDot API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))    = 0x0300,
    NSUnderlineStylePatternDashDotDot API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0)) = 0x0400,

    NSUnderlineStyleByWord API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))            = 0x8000
} API_AVAILABLE(macos(10.0), ios(6.0), tvos(9.0), watchos(2.0), visionos(1.0));

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (OpenSwiftUI_SPI)
- (NSAttributedString *)_ui_attributedSubstringFromRange_openswiftui_safe_wrapper:(NSRange)range scaledByScaleFactor:(CGFloat)factor OPENSWIFTUI_SWIFT_NAME(_ui_attributedSubstring(from:scaledBy:));
@end

@interface NSMutableAttributedString (OpenSwiftUI_SPI)
@property(readonly, assign, nonatomic) BOOL isEmptyOrTerminatedByParagraphSeparator_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(isEmptyOrTerminatedByParagraphSeparator);
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif
