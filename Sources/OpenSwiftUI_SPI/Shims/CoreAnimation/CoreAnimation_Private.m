//
//  CoreAnimation_Private.m
//  OpenSwiftUI_SPI

#import "CoreAnimation_Private.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

#import <objc/runtime.h>

@implementation CALayer (OpenSwiftUI_SPI)

- (BOOL)openSwiftUI_hasBeenCommitted {
    typedef BOOL (*Func)(CALayer *, SEL);
    SEL selector = NSSelectorFromString(@"hasBeenCommitted");
    Func func = nil;
    if ([self respondsToSelector:selector]) {
        IMP impl = class_getMethodImplementation([self class], selector);
        func = (Func)impl;
    }
    if (func == nil) {
        return NO;
    }
    return func(self, selector);
}

- (uint64_t)openSwiftUI_viewTestProperties {
    typedef uint64_t (*Func)(CALayer *, SEL);
    SEL selector = NSSelectorFromString(@"swiftUI_viewTestProperties");
    Func func = nil;
    if ([self respondsToSelector:selector]) {
        IMP impl = class_getMethodImplementation([self class], selector);
        func = (Func)impl;
    }
    if (func == nil) {
        return 0;
    }
    return func(self, selector);
}

- (void)setOpenSwiftUI_viewTestProperties:(uint64_t)viewTestProperties {
    typedef void (*Func)(CALayer *, SEL, uint64_t);
    SEL selector = NSSelectorFromString(@"setSwiftUI_viewTestProperties:");
    Func func = nil;
    if ([self respondsToSelector:selector]) {
        IMP impl = class_getMethodImplementation([self class], selector);
        func = (Func)impl;
    }
    if (func == nil) {
        return;
    }
    return func(self, selector, viewTestProperties);
}

@end

#endif /* CoreAnimation.h */
