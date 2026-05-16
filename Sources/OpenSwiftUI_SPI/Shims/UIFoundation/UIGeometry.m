//
//  UIGeometry.m
//  OpenSwiftUI_SPI

#import "UIGeometry.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <objc/runtime.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@implementation NSValue (OpenSwiftUI_UIGeometry)

+ (NSValue *)valueWithCGPoint_openswiftui_safe_wrapper:(CGPoint)point {
    SEL selector = NSSelectorFromString(@"valueWithCGPoint:");
    if ([self respondsToSelector:selector]) {
        typedef NSValue *(*Func)(id, SEL, CGPoint);
        Func func = (Func)class_getMethodImplementation(object_getClass(self), selector);
        if (func != nil) {
            return func(self, selector, point);
        }
    }
    return [self valueWithBytes:&point objCType:@encode(CGPoint)];
}

+ (NSValue *)valueWithCGSize_openswiftui_safe_wrapper:(CGSize)size {
    SEL selector = NSSelectorFromString(@"valueWithCGSize:");
    if ([self respondsToSelector:selector]) {
        typedef NSValue *(*Func)(id, SEL, CGSize);
        Func func = (Func)class_getMethodImplementation(object_getClass(self), selector);
        if (func != nil) {
            return func(self, selector, size);
        }
    }
    return [self valueWithBytes:&size objCType:@encode(CGSize)];
}

+ (NSValue *)valueWithCGRect_openswiftui_safe_wrapper:(CGRect)rect {
    SEL selector = NSSelectorFromString(@"valueWithCGRect:");
    if ([self respondsToSelector:selector]) {
        typedef NSValue *(*Func)(id, SEL, CGRect);
        Func func = (Func)class_getMethodImplementation(object_getClass(self), selector);
        if (func != nil) {
            return func(self, selector, rect);
        }
    }
    return [self valueWithBytes:&rect objCType:@encode(CGRect)];
}

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
