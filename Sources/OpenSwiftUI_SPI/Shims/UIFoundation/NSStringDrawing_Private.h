//
//  NSStringDrawing_Private.h
//  OpenSwiftUI_SPI

#pragma once

#import "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
#import "NSStringDrawing.h"

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSStringDrawingContext (OpenSwiftUI_SPI)
@property (nonatomic, assign) CGFloat baselineOffset;
@property (nonatomic, assign) CGFloat firstBaselineOffset;
@property (nonatomic, assign) CGFloat scaledLineHeight;
@property (nonatomic, assign) CGFloat scaledBaselineOffset;
@property (nonatomic, assign) BOOL wrapsForTruncationMode;
@property (nonatomic, assign) BOOL wantsBaselineOffset;
@property (nonatomic, assign) BOOL wantsScaledLineHeight;
@property (nonatomic, assign) BOOL wantsScaledBaselineOffset;
@property (nonatomic, assign) BOOL cachesLayout;
@property (nonatomic, assign) NSInteger maximumNumberOfLines;
@property (nonatomic, assign) BOOL wantsNumberOfLineFragments;
@property (nonatomic, assign) NSInteger activeRenderers;
@property (nullable, nonatomic, strong) id layout;
@property (readonly, nonatomic, assign) NSInteger numberOfLineFragments;
@property (readonly, nonatomic, assign) BOOL hasTruncatedRanges;
@property (nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id> * _Nullable (^linkTextAttributesProvider)(NSDictionary<NSAttributedStringKey, id> * _Nullable, NSInteger);
@end

void _NSStringDrawingContextSetBaselineOffset(NSStringDrawingContext *context, CGFloat offset);
void _NSStringDrawingContextSetFirstBaselineOffset(NSStringDrawingContext *context, CGFloat offset);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif
