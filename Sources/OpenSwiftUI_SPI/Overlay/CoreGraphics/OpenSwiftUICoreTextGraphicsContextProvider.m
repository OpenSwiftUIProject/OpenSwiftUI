//
//  OpenSwiftUICoreTextGraphicsContextProvider.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.0.87
//  Status: Complete

#include "OpenSwiftUICoreTextGraphicsContextProvider.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include "OpenSwiftUICoreColor.h"
#include "OpenSwiftUICoreGraphicsContext.h"

void InitializeCoreTextGraphicsContextProvider(void) {
    (void)OpenSwiftUICoreTextGraphicsContextProvider.sharedProvider;
}

@implementation OpenSwiftUICoreTextGraphicsContextProvider

+ (instancetype)sharedProvider {
    static OpenSwiftUICoreTextGraphicsContextProvider *sharedPvdr = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedPvdr = [[OpenSwiftUICoreTextGraphicsContextProvider alloc] init];
        [NSTextGraphicsContextProvider setTextGraphicsContextProviderClass:OpenSwiftUICoreTextGraphicsContextProvider.class];
    });
    return sharedPvdr;
}

+ (id<NSTextGraphicsContext>)graphicsContextForApplicationFrameworkContext:(id)context {
    return OpenSwiftUICoreTextGraphicsContextProvider.sharedProvider;
}

+ (Class)colorClassForApplicationFrameworkContext:(id)context {
    return OpenSwiftUICoreColor.class;
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)isDrawingToScreen {
    return YES;
}

- (CGContextRef)CGContext {
    return OpenSwiftUICoreGraphicsContext.current.CGContext;
}

- (void)saveGraphicsState {
    CGContextRef context = OpenSwiftUICoreGraphicsContext.current.CGContext;
    if (context) {
        CGContextSaveGState(context);
    }
}

- (void)restoreGraphicsState {
    CGContextRef context = OpenSwiftUICoreGraphicsContext.current.CGContext;
    if (context) {
        CGContextRestoreGState(context);
    }
}

- (void)becomeCurrentGraphicsContextDuringBlock:(void (^)(void))block {
    block();
}

@end

#endif
