//
//  OpenSwiftUICoreGraphicsContext.h
//  OpenSwiftUI_SPI
//
//  Audited for RELEASE_2024
//  Status: Complete

#include "OpenSwiftUICoreGraphicsContext.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
#include <Foundation/Foundation.h>
#include "OpenSwiftUICoreTextGraphicsContextProvider.h"
#include "Shims/UIFoundation/NSTextGraphicsContextInternal.h"

#if OPENSWIFTUI_TARGET_OS_OSX
#include <AppKit/AppKit.h>
#endif

static _Thread_local __unsafe_unretained OpenSwiftUICoreGraphicsContext * _current = NULL;

dispatch_once_t _once;
#if OPENSWIFTUI_TARGET_OS_OSX
Class _nsGraphicsContextClass;
#else
IMP _pushContextIMP;
IMP _popContextIMP;
#endif

@interface OpenSwiftUICoreGraphicsContext () {
    OpenSwiftUICoreGraphicsContext *_next;
    CGContextRef _ctx;
}
#if !OPENSWIFTUI_TARGET_OS_OSX
- (id)__createsImages;
#endif
@end

@implementation OpenSwiftUICoreGraphicsContext

- (instancetype)initWithCGContext:(CGContextRef)ctx {
    dispatch_once(&_once, ^{
        #if OPENSWIFTUI_TARGET_OS_OSX
        _nsGraphicsContextClass = NSClassFromString(@"NSGraphicsContext");
        #else
        Class renderClass = NSClassFromString(@"UIGraphicsRenderer");
        if (renderClass) {
            _pushContextIMP = [renderClass instanceMethodForSelector:@selector(pushContext:)];
            _popContextIMP = [renderClass instanceMethodForSelector:@selector(popContext:)];
        } else {
            InitializeCoreTextGraphicsContextProvider();
        }
        #endif
    });
    self = [super init];
    if (self) {
        _ctx = ctx;
    }
    return self;
}

- (void)push {
    #if OPENSWIFTUI_TARGET_OS_OSX
    _next = _current;
    _current = self;
    if (_nsGraphicsContextClass) {
        [_nsGraphicsContextClass saveGraphicsState];
        [_nsGraphicsContextClass graphicsContextWithCGContext: _ctx flipped: YES];
        NSGraphicsContext *graphicsContext = [_nsGraphicsContextClass graphicsContextWithCGContext: _ctx flipped: YES];
        [_nsGraphicsContextClass setCurrentContext: graphicsContext];
    }
    #else
    _next = _current;
    _current = self;
    if (_pushContextIMP != NULL && _popContextIMP != NULL) {
        typedef BOOL (*FUNC)(id, SEL, OpenSwiftUICoreGraphicsContext *);
        ((FUNC)(_pushContextIMP))(NULL, @selector(pushContext:), _current);
    }
    #endif
}

- (void)pop {
    #if OPENSWIFTUI_TARGET_OS_OSX
    _current = _next;
    [_nsGraphicsContextClass restoreGraphicsState];
    #else
    _current = _next;
    if (_pushContextIMP != NULL && _popContextIMP != NULL) {
        typedef BOOL (*FUNC)(id, SEL, OpenSwiftUICoreGraphicsContext *);
        ((FUNC)(_popContextIMP))(NULL, @selector(popContext:), _current);
    }
    #endif
}

#if !OPENSWIFTUI_TARGET_OS_OSX
- (id)__createsImages {
    return nil;
}
#endif

- (CGContextRef)CGContext {
    return _ctx;
}

+ (OpenSwiftUICoreGraphicsContext *)current {
    return _current;
}

@end
#endif
