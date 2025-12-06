//
//  NSStringDrawingContext.h
//  OpenSwiftUI_SPI

#pragma once

#import "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSStringDrawingContext : NSObject

@property (nonatomic, assign) CGFloat baselineOffset;
@property (nonatomic, assign) CGFloat firstBaselineOffset;
@property (nonatomic, assign) BOOL wrapsForTruncationMode;
@property (nonatomic, assign) BOOL wantsBaselineOffset;
@property (nonatomic, assign) BOOL wantsScaledLineHeight;
@property (nonatomic, assign) BOOL wantsScaledBaselineOffset;
@property (nonatomic, assign) BOOL cachesLayout;

@end

void _NSStringDrawingContextSetBaselineOffset(NSStringDrawingContext *context, CGFloat offset);
void _NSStringDrawingContextSetFirstBaselineOffset(NSStringDrawingContext *context, CGFloat offset);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif
