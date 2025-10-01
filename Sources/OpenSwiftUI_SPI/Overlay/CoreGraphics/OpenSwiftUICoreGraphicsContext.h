//
//  OpenSwiftUICoreGraphicsContext.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.0.87
//  Status: Complete

#ifndef OpenSwiftUICoreGraphicsContext_h
#define OpenSwiftUICoreGraphicsContext_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <CoreGraphics/CoreGraphics.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_SWIFT_NAME(CoreGraphicsContext)
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
