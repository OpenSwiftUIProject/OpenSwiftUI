//
//  NSTextGraphicsContext.h
//  OpenSwiftUI_SPI
//
//  Audited for RELEASE_2024
//  Status: Complete

#ifndef NSTextGraphicsContext_h
#define NSTextGraphicsContext_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>

@protocol NSTextGraphicsContext <NSObject>

@required
@property (readonly) CGContextRef CGContext;
@property (readonly, getter=isFlipped) BOOL flipped;
@property (readonly, getter=isDrawingToScreen) BOOL drawingToScreen;
+ (id<NSTextGraphicsContext>)graphicsContextForApplicationFrameworkContext:(id)context NS_SWIFT_NAME(graphicsContext(forApplicationFrameworkContext:));

- (CGContextRef)CGContext;
- (BOOL)isFlipped;
- (BOOL)isDrawingToScreen;
@end

#endif

#endif /* NSTextGraphicsContext_h */
