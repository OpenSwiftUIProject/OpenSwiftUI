//
//  UIKit_Private.m
//  OpenSwiftUI_SPI
//
//  Status: WIP

#import "UIKit_Private.h"
#import "../OpenSwiftUIShims.h"

#if __has_include(<UIKit/UIKit.h>)

#import <objc/runtime.h>

@implementation UIApplication (OpenSwiftUI_SPI)
- (void)_performBlockAfterCATransactionCommits_openswiftui_safe_wrapper:(void (^)(void))block {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"_performBlockAfterCATransactionCommits:", block(),void (^)(void));
    func(self, selector, block);
}

- (void)startedTest_openswiftui_safe_wrapper:(NSString *)name {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"startedTest:", , NSString *);
    func(self, selector, name);
}

- (void)finishedTest_openswiftui_safe_wrapper:(NSString *)name {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"finishedTest:", , NSString *);
    func(self, selector, name);
}

- (void)failedTest_openswiftui_safe_wrapper:(NSString *)name withFailure:(NSError *)failure {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"failedTest:withFailure:", , NSString *, NSError *);
    func(self, selector, name, failure);
}

- (NSString *)_launchTestName_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(NSString *, @"_launchTestName", nil);
    return func(self, selector);
}
@end

@implementation UIView (OpenSwiftUI_SPI)
- (BOOL)_shouldAnimatePropertyWithKey_openswiftui_safe_wrapper:(NSString *)key {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"_shouldAnimatePropertyWithKey:", NO, NSString *);
    return func(self, selector, key);
}

- (void)_setFocusInteractionEnabled_openswiftui_safe_wrapper:(BOOL)enabled {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"_setFocusInteractionEnabled:", , BOOL);
    func(self, selector, enabled);
}

- (UIViewController *)_viewControllerForAncestor_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(UIViewController *, @"_viewControllerForAncestor", nil);
    return func(self, selector);
}
@end

@implementation UIViewController (OpenSwiftUI_SPI)
- (BOOL)_canShowWhileLocked_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"_canShowWhileLocked", NO);
    return func(self, selector);
}
@end

#if !OPENSWIFTUI_TARGET_OS_VISION || OPENSWIFTUI_INTERNAL_XR_SDK
@implementation UIScreen (OpenSwiftUI_SPI)
- (CGRect)_referenceBounds_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(CGRect, @"_referenceBounds", CGRectZero);
    return func(self, selector);
}
- (CGFloat)_pointsPerInch_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(CGFloat, @"_pointsPerInch", 0.0);
    return func(self, selector);
}
@end
#endif

@implementation UIWindowScene (OpenSwiftUI_SPI)
- (UIUserInterfaceStyle) _systemUserInterfaceStyle_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(UIUserInterfaceStyle, @"_systemUserInterfaceStyle", UIUserInterfaceStyleUnspecified);
    return func(self, selector);
}
@end

@implementation UITraitCollection (OpenSwiftUI_SPI)
- (NSObject *)_environmentWrapper_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(NSObject *, @"_environmentWrapper", nil);
    return func(self, selector);
}
@end

#endif /* __has_include(<UIKit/UIKit.h>) */
