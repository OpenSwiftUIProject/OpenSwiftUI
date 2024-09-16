//
//  CoreGraphicsContext.h
//  COpenSwiftUI
//  Audited for RELEASE_2024
//  Status: Complete

#ifndef CoreGraphicsContext_h
#define CoreGraphicsContext_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <CoreGraphics/CoreGraphics.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface CoreGraphicsContext : NSObject

@property (class, nonatomic, readonly) CoreGraphicsContext *current;
@property (nonatomic, readonly) CGContextRef CGContext;

- (instancetype)initWithCGContext:(CGContextRef)ctx;
- (void)push;
- (void)pop;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif

#endif /* CoreGraphicsContext_h */
