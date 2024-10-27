//
//  OpenSwiftUICoreGraphicsContext.h
//  COpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

#include "OpenSwiftUICoreGraphicsContext.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
#include <Foundation/Foundation.h>

static _Thread_local __unsafe_unretained OpenSwiftUICoreGraphicsContext * _current = NULL;

IMP _pushContextIMP;
IMP _popContextIMP;

@interface OpenSwiftUICoreGraphicsContext () {
    OpenSwiftUICoreGraphicsContext *_next;
    CGContextRef _ctx;
}
- (id)__createsImages;
@end

@implementation OpenSwiftUICoreGraphicsContext

- (instancetype)initWithCGContext:(CGContextRef)ctx {
    static dispatch_once_t __once;
    dispatch_once(&__once, ^{
        Class renderClass = NSClassFromString(@"UIGraphicsRenderer");
        if (renderClass) {
            _pushContextIMP = [renderClass instanceMethodForSelector:@selector(pushContext:)];
            _popContextIMP = [renderClass instanceMethodForSelector:@selector(popContext:)];
        } else {
            // TODO: CoreTextGraphicsContextProvider.sharedProvider
        }
    });
    self = [super init];
    if (self) {
        _ctx = ctx;
    }
    return self;
}

- (void)push {
    _next = _current;
    _current = self;
    if (_pushContextIMP != NULL && _popContextIMP != NULL) {
        typedef BOOL (*FUNC)(id, SEL, OpenSwiftUICoreGraphicsContext *);
        ((FUNC)(_pushContextIMP))(NULL, @selector(pushContext:), _current);
    }
}

- (void)pop {
    _current = _next;
    if (_pushContextIMP != NULL && _popContextIMP != NULL) {
        typedef BOOL (*FUNC)(id, SEL, OpenSwiftUICoreGraphicsContext *);
        ((FUNC)(_popContextIMP))(NULL, @selector(popContext:), _current);
    }
}

- (id)__createsImages {
    return nil;
}

- (CGContextRef)CGContext {
    return _ctx;
}

+ (OpenSwiftUICoreGraphicsContext *)current {
    return _current;
}

@end
#endif
