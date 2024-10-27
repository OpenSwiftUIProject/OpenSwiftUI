//
//  OpenSwiftUICoreGraphicsContext.h
//  COpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

#ifndef OpenSwiftUICoreGraphicsContext_h
#define OpenSwiftUICoreGraphicsContext_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <CoreGraphics/CoreGraphics.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface OpenSwiftUICoreGraphicsContext : NSObject

@property (class, nonatomic, readonly) OpenSwiftUICoreGraphicsContext *current;
@property (nonatomic, readonly) CGContextRef CGContext;

- (instancetype)initWithCGContext:(CGContextRef)ctx;
- (void)push;
- (void)pop;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif

#endif /* OpenSwiftUICoreGraphicsContext_h */
