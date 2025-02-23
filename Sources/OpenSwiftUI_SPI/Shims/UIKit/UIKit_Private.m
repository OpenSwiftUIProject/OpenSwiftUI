//
//  UIKit_Private.m
//  OpenSwiftUI_SPI
//
//  Status: WIP

#import "UIKit_Private.h"

#if __has_include(<UIKit/UIKit.h>)

#import <objc/runtime.h>

@implementation UIApplication (OpenSwiftUI_SPI)
- (void)_performBlockAfterCATransactionCommits_openswiftui_safe_wrapper:(void (^)(void))block {
    typedef void (*Func)(UIApplication *, SEL, void (^)(void));
    SEL selector = NSSelectorFromString(@"_performBlockAfterCATransactionCommits:");
    Func func = nil;
    if ([self respondsToSelector:selector]) {
        IMP impl = class_getMethodImplementation([self class], selector);
        func = (Func)impl;
    }
    if (func != nil) {
        func(self, selector, block);
    }
}
@end

#endif /* UIKit.h */
