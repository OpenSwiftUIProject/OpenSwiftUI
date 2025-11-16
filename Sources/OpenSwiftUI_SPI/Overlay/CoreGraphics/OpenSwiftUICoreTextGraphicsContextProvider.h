//
//  OpenSwiftUICoreTextGraphicsContextProvider.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.0.87
//  Status: Complete

#ifndef OpenSwiftUICoreTextGraphicsContextProvider_h
#define OpenSwiftUICoreTextGraphicsContextProvider_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

@import UIFoundation_Private;

void InitializeCoreTextGraphicsContextProvider(void);

OPENSWIFTUI_SWIFT_NAME(CoreTextGraphicsContextProvider)
@interface OpenSwiftUICoreTextGraphicsContextProvider : NSObject<NSTextGraphicsContextProvider, NSTextGraphicsContext>

@property (readonly) CGContextRef CGContext;
@property (readonly, getter=isFlipped) BOOL flipped;
@property (readonly, getter=isDrawingToScreen) BOOL drawingToScreen;

+ (instancetype)sharedProvider;
+ (id<NSTextGraphicsContext>)graphicsContextForApplicationFrameworkContext:(id)context;
+ (Class)colorClassForApplicationFrameworkContext:(id)context;

- (BOOL)isFlipped;
- (BOOL)isDrawingToScreen;
- (CGContextRef)CGContext;
- (void)saveGraphicsState;
- (void)restoreGraphicsState;
- (void)becomeCurrentGraphicsContextDuringBlock:(void (^)(void))block;

@end

#endif

#endif /* OpenSwiftUICoreTextGraphicsContextProvider_h */
