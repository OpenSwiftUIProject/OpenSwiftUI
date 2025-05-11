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

- (void)startedTest_openswiftui_safe_wrapper:(NSString *)name {
    typedef void (*Func)(UIApplication *, SEL, NSString *);
    SEL selector = NSSelectorFromString(@"startedTest:");
    Func func = nil;
    if ([self respondsToSelector:selector]) {
        IMP impl = class_getMethodImplementation([self class], selector);
        func = (Func)impl;
    }
    if (func != nil) {
        func(self, selector, name);
    }
}

- (void)finishedTest_openswiftui_safe_wrapper:(NSString *)name {
    typedef void (*Func)(UIApplication *, SEL, NSString *);
    SEL selector = NSSelectorFromString(@"finishedTest:");
    Func func = nil;
    if ([self respondsToSelector:selector]) {
        IMP impl = class_getMethodImplementation([self class], selector);
        func = (Func)impl;
    }
    if (func != nil) {
        func(self, selector, name);
    }
}

- (void)failedTest_openswiftui_safe_wrapper:(NSString *)name withFailure:(NSError *)failure {
    typedef void (*Func)(UIApplication *, SEL, NSString *, NSError *);
    SEL selector = NSSelectorFromString(@"failedTest:withFailure:");
    Func func = nil;
    if ([self respondsToSelector:selector]) {
        IMP impl = class_getMethodImplementation([self class], selector);
        func = (Func)impl;
    }
    if (func != nil) {
        func(self, selector, name, failure);
    }
}

- (NSString *)_launchTestName_openswiftui_safe_wrapper {
    typedef NSString* (*Func)(UIApplication *, SEL);
    SEL selector = NSSelectorFromString(@"_launchTestName");
    Func func = nil;
    if ([self respondsToSelector:selector]) {
        IMP impl = class_getMethodImplementation([self class], selector);
        func = (Func)impl;
    }
    if (func != nil) {
        return func(self, selector);
    }
    return nil;
}
@end

@implementation UIView (OpenSwiftUI_SPI)
- (BOOL)_shouldAnimatePropertyWithKey_openswiftui_safe_wrapper:(NSString *)key {
    typedef BOOL (*Func)(UIView *, SEL, NSString *);
    SEL selector = NSSelectorFromString(@"_shouldAnimatePropertyWithKey:");
    Func func = nil;
    if ([self respondsToSelector:selector]) {
        IMP impl = class_getMethodImplementation([self class], selector);
        func = (Func)impl;
    }
    if (func != nil) {
        return func(self, selector, key);
    }
    return NO;
}
@end

@implementation UIViewController (OpenSwiftUI_SPI)
- (BOOL)_canShowWhileLocked_openswiftui_safe_wrapper {
    typedef BOOL (*Func)(UIViewController *, SEL);
    SEL selector = NSSelectorFromString(@"_canShowWhileLocked");
    Func func = nil;
    if ([self respondsToSelector:selector]) {
        IMP impl = class_getMethodImplementation([self class], selector);
        func = (Func)impl;
    }
    if (func != nil) {
        return func(self, selector);
    }
    return NO;
}
@end

#endif /* UIKit.h */
