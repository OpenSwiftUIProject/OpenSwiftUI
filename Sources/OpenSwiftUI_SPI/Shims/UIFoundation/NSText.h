//
//  NSText.h
//  OpenSwiftUI_SPI

#pragma once

#import "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

// Modified based on macOS 27.0 SDK

/*
    NSText.h
    Application Kit
    Copyright (c) 1994-2024, Apple Inc.
    All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "UIFoundationHelper.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

#if !__NSWRITING_DIRECTION_SHARED_SECTION__
#define __NSWRITING_DIRECTION_SHARED_SECTION__ 1
#pragma mark NSWritingDirection
typedef NS_ENUM(NSInteger, NSWritingDirection) {
    NSWritingDirectionNatural       = -1,   // Determines direction using the Unicode Bidi Algorithm rules P2 and P3
    NSWritingDirectionLeftToRight   = 0,    // Left to right writing direction
    NSWritingDirectionRightToLeft   = 1     // Right to left writing direction
} API_AVAILABLE(macos(10.0), ios(6.0), watchos(2.0), tvos(9.0), visionos(1.0));
#endif // !__NSWRITING_DIRECTION_SHARED_SECTION__

#if !__NSTEXT_ALIGNMENT_SHARED_SECTION__
#define __NSTEXT_ALIGNMENT_SHARED_SECTION__ 1
#pragma mark NSTextAlignment
typedef NS_ENUM(NSInteger, NSTextAlignment) {
    NSTextAlignmentLeft      = 0,    // Visually left aligned
#if TARGET_ABI_USES_IOS_VALUES
    NSTextAlignmentCenter    = 1,    // Visually centered
    NSTextAlignmentRight     = 2,    // Visually right aligned
#else /* !TARGET_ABI_USES_IOS_VALUES */
    NSTextAlignmentRight     = 1,    // Visually right aligned
    NSTextAlignmentCenter    = 2,    // Visually centered
#endif
    NSTextAlignmentJustified = 3,    // Fully-justified. The last line in a paragraph is natural-aligned.

    /// Resolved to either ``left`` or ``right`` based on the natural alignment resolution type active in the associated component.
    ///
    /// There are two types of natural alignment resolution behavior. The natural alignment is resolved based on either the UI language or the base writing direction.
    /// The behavior is selected by the ``resolvesNaturalAlignmentWithBaseWritingDirection`` property for ``NSTextLayoutManager``.
    /// ``NSStringDrawingOptions.resolvesNaturalAlignmentWithBaseWritingDirection`` specifies the base writing direction based resolution for ``NSStringDrawing``.
    NSTextAlignmentNatural   = 4
} API_AVAILABLE(macos(10.0), ios(6.0), watchos(2.0), tvos(9.0), visionos(1.0));
#endif // !__NSTEXT_ALIGNMENT_SHARED_SECTION__

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
