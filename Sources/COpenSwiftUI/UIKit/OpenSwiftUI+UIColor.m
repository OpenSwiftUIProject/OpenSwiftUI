//
//  OpenSwiftUI+UIColor.m
//  COpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

#import "OpenSwiftUI+UIColor.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

BOOL _UIColorDependsOnTraitCollection(UIColor *color) {
    static IMP UIColor_imp = nil;
    static dispatch_once_t once;

    SEL selector = @selector(resolvedColorWithTraitCollection:);
    dispatch_once(&once, ^{
        UIColor_imp = [UIColor instanceMethodForSelector:selector];
    });
    return [color methodForSelector:selector] != UIColor_imp;
}

@implementation UIColor (OpenSwiftUI)

- (instancetype)initWithColor__openSwiftUI__:(UIColor *)color {
    self = color;
}

@end

#endif
